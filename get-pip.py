#!/usr/bin/env python
#
# Hi There!
# You may be wondering what this giant blob of binary data here is, you might
# even be worried that we're up to something nefarious (good for you for being
# paranoid!). This is a base85 encoding of a zip file, this zip file contains
# an entire copy of pip (version 19.1).
#
# Pip is a thing that installs packages, pip itself is a package that someone
# might want to install, especially if they're looking to run this get-pip.py
# script. Pip has a lot of code to deal with the security of installing
# packages, various edge cases on various platforms, and other such sort of
# "tribal knowledge" that has been encoded in its code base. Because of this
# we basically include an entire copy of pip inside this blob. We do this
# because the alternatives are attempt to implement a "minipip" that probably
# doesn't do things correctly and has weird edge cases, or compress pip itself
# down into a single file.
#
# If you're wondering how this is created, it is using an invoke task located
# in tasks/generate.py called "installer". It can be invoked by using
# ``invoke generate.installer``.

import os.path
import pkgutil
import shutil
import sys
import struct
import tempfile

# Useful for very coarse version differentiation.
PY2 = sys.version_info[0] == 2
PY3 = sys.version_info[0] == 3

if PY3:
    iterbytes = iter
else:
    def iterbytes(buf):
        return (ord(byte) for byte in buf)

try:
    from base64 import b85decode
except ImportError:
    _b85alphabet = (b"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
                    b"abcdefghijklmnopqrstuvwxyz!#$%&()*+-;<=>?@^_`{|}~")

    def b85decode(b):
        _b85dec = [None] * 256
        for i, c in enumerate(iterbytes(_b85alphabet)):
            _b85dec[c] = i

        padding = (-len(b)) % 5
        b = b + b'~' * padding
        out = []
        packI = struct.Struct('!I').pack
        for i in range(0, len(b), 5):
            chunk = b[i:i + 5]
            acc = 0
            try:
                for c in iterbytes(chunk):
                    acc = acc * 85 + _b85dec[c]
            except TypeError:
                for j, c in enumerate(iterbytes(chunk)):
                    if _b85dec[c] is None:
                        raise ValueError(
                            'bad base85 character at position %d' % (i + j)
                        )
                raise
            try:
                out.append(packI(acc))
            except struct.error:
                raise ValueError('base85 overflow in hunk starting at byte %d'
                                 % i)

        result = b''.join(out)
        if padding:
            result = result[:-padding]
        return result


def bootstrap(tmpdir=None):
    # Import pip so we can use it to install pip and maybe setuptools too
    import pip._internal
    from pip._internal.commands.install import InstallCommand
    from pip._internal.req.constructors import install_req_from_line

    # Wrapper to provide default certificate with the lowest priority
    class CertInstallCommand(InstallCommand):
        def parse_args(self, args):
            # If cert isn't specified in config or environment, we provide our
            # own certificate through defaults.
            # This allows user to specify custom cert anywhere one likes:
            # config, environment variable or argv.
            if not self.parser.get_default_values().cert:
                self.parser.defaults["cert"] = cert_path  # calculated below
            return super(CertInstallCommand, self).parse_args(args)

    pip._internal.commands_dict["install"] = CertInstallCommand

    implicit_pip = True
    implicit_setuptools = True
    implicit_wheel = True

    # Check if the user has requested us not to install setuptools
    if "--no-setuptools" in sys.argv or os.environ.get("PIP_NO_SETUPTOOLS"):
        args = [x for x in sys.argv[1:] if x != "--no-setuptools"]
        implicit_setuptools = False
    else:
        args = sys.argv[1:]

    # Check if the user has requested us not to install wheel
    if "--no-wheel" in args or os.environ.get("PIP_NO_WHEEL"):
        args = [x for x in args if x != "--no-wheel"]
        implicit_wheel = False

    # We only want to implicitly install setuptools and wheel if they don't
    # already exist on the target platform.
    if implicit_setuptools:
        try:
            import setuptools  # noqa
            implicit_setuptools = False
        except ImportError:
            pass
    if implicit_wheel:
        try:
            import wheel  # noqa
            implicit_wheel = False
        except ImportError:
            pass

    # We want to support people passing things like 'pip<8' to get-pip.py which
    # will let them install a specific version. However because of the dreaded
    # DoubleRequirement error if any of the args look like they might be a
    # specific for one of our packages, then we'll turn off the implicit
    # install of them.
    for arg in args:
        try:
            req = install_req_from_line(arg)
        except Exception:
            continue

        if implicit_pip and req.name == "pip":
            implicit_pip = False
        elif implicit_setuptools and req.name == "setuptools":
            implicit_setuptools = False
        elif implicit_wheel and req.name == "wheel":
            implicit_wheel = False

    # Add any implicit installations to the end of our args
    if implicit_pip:
        args += ["pip"]
    if implicit_setuptools:
        args += ["setuptools"]
    if implicit_wheel:
        args += ["wheel"]

    # Add our default arguments
    args = ["install", "--upgrade", "--force-reinstall"] + args

    delete_tmpdir = False
    try:
        # Create a temporary directory to act as a working directory if we were
        # not given one.
        if tmpdir is None:
            tmpdir = tempfile.mkdtemp()
            delete_tmpdir = True

        # We need to extract the SSL certificates from requests so that they
        # can be passed to --cert
        cert_path = os.path.join(tmpdir, "cacert.pem")
        with open(cert_path, "wb") as cert:
            cert.write(pkgutil.get_data("pip._vendor.certifi", "cacert.pem"))

        # Execute the included pip and use it to install the latest pip and
        # setuptools from PyPI
        sys.exit(pip._internal.main(args))
    finally:
        # Remove our temporary directory
        if delete_tmpdir and tmpdir:
            shutil.rmtree(tmpdir, ignore_errors=True)


def main():
    tmpdir = None
    try:
        # Create a temporary working directory
        tmpdir = tempfile.mkdtemp()

        # Unpack the zipfile into the temporary directory
        pip_zip = os.path.join(tmpdir, "pip.zip")
        with open(pip_zip, "wb") as fp:
            fp.write(b85decode(DATA.replace(b"\n", b"")))

        # Add the zipfile to sys.path so that we can import it
        sys.path.insert(0, pip_zip)

        # Run the bootstrap
        bootstrap(tmpdir=tmpdir)
    finally:
        # Clean up our temporary working directory
        if tmpdir:
            shutil.rmtree(tmpdir, ignore_errors=True)


DATA = b"""
P)h>@6aWAK2mmD%m`<4gN^}<h000#L000jF003}la4%n9X>MtBUtcb8d5e!POD!tS%+HIDSFlx3GPKk
)RN?{vP)h>@6aWAK2mmD%m`-N@Pvb`c003_S000jF003}la4%n9ZDDC{Utcb8d0kO4Zo@DP-1Q0q8SE
6P(>Xwfj$MoHf@(`KQCU(&8g71HO0ki&o<#cYNZz>|C(zo>JZGyl;FMx!FrO6t%vRrOrPh9=?L}8oY6
ou)77Hd@$a4r7F5rryfn~JTAHWO)@Mv!(a4fto86JiEF(QHSJ}y)-GntEpbmcJyNSL0Vx@Gi7c>xAuL
EgIxovfWq|0NvR`+SC`IVq5DSMEVyuc5y>N3AD=LF+DESFFQK3<Kt1CJTKTLYy%XL<h|yp*aBAK8E2A
C<u{lR;_nSv*%($xv)$xXH{VlyW4<F*1MJTS{*X{Xbw;;w)Q4$fyk7KuYb>yL&bIL-tGT-b6~%(tWCE
QA8qFL<xqw8O4YPPywe!i3fXTH%iUlIssUwDBx#@MOXAo;h~GxtLMQ{*1U9$UB+6L(gWT43E6e->P)h
>@6aWAK2mmD%m`<{zTe%hm001@%000>P003}la4%nJZggdGZeeUMUtei%X>?y-E^v93R&8(FHW2=<Uv
YC#L<Sty?uKp%W?);Jp#jn)h`aSeQ3$kjmf6yzN>X;*U%xw2l%3W6Py<0o>h8I>=Z-x4>3Qeu^QF|!Q
E#E$`?b;8%9;(7<*M_Y#j*ssX^r(Dmd>coV;T2Z)}Jd=35ADU(@5Q<t#N6!6IRm)H|V)Nt<T`aboTOM
`toA-D=dYz`#)-2N}&s5n@i}dQgZn-%!=7BAnF=xFs+wH3k9xg1J24=aHjg~CWN-^JjfMDy)~anIF|(
$eE?XGCm_iYsT4@(Is}ot0&l?i8m(pRfJR`_>2r#EE2I)jML=NjONY)o=yYXtEu$-H-<xpB;d2*3fTX
;YO9I=Nx>Gm-+BOZ^V00~A@_@kKt#R;YX;F~+>#O^V-@pfx`4TJ9IRvvJI8Va8$ENdb=f@y)O)kTy&U
t8+keW`k*)triwXqw@TIWQ=kz7M<IJ%wCp5Y9qw|81N*dqn54Oy{JV~e^*UF}1zTiH$+jQ|LR^@FxjW
_J-i;?(Kj;gSCn0*}6N;Ve2ABo5)X^^zo&a<IXenl(A%4ObP}TcrQw00zCpuNC`KY%5np-tw;8lE20l
eK87rtT3>~CAHT>NbjTlEYY)AN#)U|Z9b9>#fqZ|RKjCp?0)`@@)+QZGV(<*pWow<6RAI8<%7GiZm__
Ldg`4O+Qpu7fWi`gXwe$yB+-oX<ky1pzb8D4E3{+`9Wc=;Zy^v`?^tLpwg`LEfuO{ob_8Fu?Qkyr1lD
GUTdLv?3Cw7+mE5aMOmknWN;r&$cX&=<w$p)%M#Dx_cZ<L;7F1GGZxPxZ<zcb7VbXbHz^LA`t|^LlH;
e78c#(O#zs!JssqLN0VnN_KoLpIJY!qpQa~Ud!aeD@@*2sip+9hMNVp`1DskiJ@L|*YQDTwo)BsVah!
>AT^C-o>eO(u)G`>R`0FaN!ISX|%Tmbd@B{p;!heuwGfY&xCN-zpmA-{5oleV1B&e-FWh`ubGg0izE%
KZ<w)cZ;wXKQ$F{Fz5}rNWcGCC?dy7sl6$Cr}A-j)C=?lEe)xnQnC=8H<j763b`GI$$mJ+?`dvmo|LV
yj;PeDg<VOC8%pv?z4&S9y0kBAS@}~6-!|&KY(tVxNq1hVL6C-&rTNIpr(|hBB*})mVuP0QD21Z2)Ge
t$xT_{~1AP_34(<E{6XjaR$~?pyB8`=d??X!2JY9@MgZ?I*<z=bGhA!AKkBv97j)UzqP-I|l{zrz@X*
e>O)wlw#YA$T!=C?FodnQsl@e#K*pC0%ZPUoT5Xu16`yZo4?Mm2gR8?r;Ukv%TPaPRYIpgHc4htJxYu
31A&PNe&h4w2e<x=_kqw~TVk>)^%_UDMf<j;%IzNbMx7das|bHN-s5j#@JjEsW&H>Hx;k#%rzESxFX0
R}T+&50~)Fjo=x}j=wK!TtU+k9kx$}@KO4FHcr{QMdYUqkGc4oVwSXF^3yn{;cse6L;km*aWLjY?u`B
1>(cZ-(H2Eg3N2sONIU#CQ@u5ZKCbfq;O15N=grLo&d;ADssDON)B))X1`r}2Jv~}VIMtf&o5~8eW>)
o|`KIcquJn2mN`9rQ<lqk1xu6$d*W{yXCNpy%gS}_;R$8NGJDyJ?8gU(?k9}#W)KBKjhs1`Dxugdy^+
i3;M;8}qGvW*;o{S?D4cN}=gcD|8K8R%h0Z>Z=1QY-O00;mj6qrs-OWq+R2><}#8~^|s0001RX>c!JX
>N37a&BR4FJg6RY-C?$Zgwtkd7T+uZ`(NX-M@mHK1jk!!gU{w^8(#8-4@qNf;PQHVHkoU(GEAVs3R#m
z9RqqW=K&YB{}V`Uu;qH#rdA`#l^*MEvrg$RUeq(^`6#>w33!&%LQSQSGi)mCS@yFy(6+@QjvSafXBt
f#l>R5_6-+`RD8F?v+j{g`%9kspNc-IqsW`ZR`5M3cvaB?$xG4!+=!A2TE1n4GBC)mRjiUJkSTb*Wjh
PIqbh4o>Vel;#qJIGJW#G4<iY?ntVy#2txGP_=5dz^DtRjk+Dq_>{<md<q8?)MA1Wk>cL^jb5Gf{qaP
bJ2{7ltA&thiTmQ^&%NG|a>t9YSx=P+iqqN2{L)Ld!LWMQ$3ys9$U-Zz4SH1a%>qWdN*nXrg=@cb4eE
)*B17tl@(8n8q9_t)F6+2#AI%YS8`zFc2_xc>b-X3H!VZ)lxKpi@%;cHhpBSuO~CG%cUwUE5SNCZM^P
d;t3SJwDzvsG+=y$wx5sfa}Y_>XJTLLbrMGnD6L2JOnAw?WiCt>whU&{G&b#v#iedV326BSQJ$*CCP3
D-Lj|ULUStV7L3Mfrm`%QwA#i5T_rMiz|SkZ1YMF)DiM+7S8~m3+P_7V6fuB1e)%sXRc!-r-sP1X;oP
%YTW~eFXV^pFC#Y3GK)+n3cm=XrnIj6MNYHS}p0Y+?C5S!5LoVd%TX3IC8Z5O?F~CC%J15UQMzjuOAy
}hiuyO8u%@y1k>4ReX01TYqQXC~G>VZ0F5QHKZC(T0=$;s{M_5>*e;#{D6Rwp9c25m^ow8v{&K>^e1q
L1egr3PoC1>3S>rL`CnbLo{f(?9|se}KfDXwOjqRrhkNEWM?tS#3BtMZ-y8weAoG#i4P23@5fMHoa%+
B<$qikl+6aI_rE9^6aIcxq>v6*CpBKHADdZ?lLr_YwF~0Fb}Jxf{bEPHF$a>Euk~MKj-ylTt4el(8|v
~A>_t#b)k7CAkam01~D!4ZNg|V0x;I0s4S-xgno2{7!$D#<`9Aet(pGGSsjk}m<T}lD2hBHSl)DOv6_
TI&BZ>i0tgm<prXo8!2lgir0n8Xn{+ei3scw{GR0;D?s~wB;3$*P07@k&hys;3tN<|d^^+d*s--f7Tg
|v!FJPKCkh06rpxL|=&0ts=Q>f4mhCOyv@QPfvQt>_eA0?703f|_rP6D1N!Ocn9Kw`v-2!0BW5R)9t=
|MJlMex_Wz><e<3n>O{XXrL2(aS-b`elYMQJ3GmYgjKpOBRsqLIjJnN;Ne!vxk76@28w7{%c5>WJWlH
x}Qgmfr52$^nE7|5IXR3R?St9NT0w<WatwfIS0V*AK`cm)dL+F*bJ-uTu@o?PL#rWLE1pHz~M27u=Uw
CKGSWJ9tFUMw)sm-T4IKqC^iU!$ywh`#@dXr?j|QtugE)aQs^v7!JE!c65}V3aCLsvRVkfda>1Z$$f5
N*$*im8@KaxYz1&RTA8UTBP02<`s={ajqr(_UfzN$&o%Sd3yqrMe2j8Z7S>iX^$5`CqwQ_z>8FoBesb
<+sV#Ke4=kCz!qe90RD=eDP(v;?$p4YRS^-Gui1a%h8bW1bW(@|n>(JN^}VR{97X^hQ@05cBwnL=+=#
ssX0oe=a*rYJHx<8`l0lEn77Pm?-JcHO_*AlZ-SRW>i5^(g2mD8vokeQd@b_Q0tX#}OK(TP&PVog6P;
xeqb1qOSZxW2>rZL@2iU(@vyIJo$kF#9@;2v3@Vn>|OJNy?@snVAt|e!M}ZT_a4jr?bo~aH`muUUp`-
b`uySUYB<vnZtfoX%`Q!NrPfUryecyf$lhRW_zsZhwH>f;$1bPqT5KUw*;Gu~)GTS^b|$7G*~s!U_GS
Qcl+`vR_F%qBjetusFfk=S`$Iee9qVpMg4e+;&^fBT&<^cq-!q<^@r*td88%Pm*8%57eRS{m4B8pSAm
aw8I^8Pi0Pt*)f^zoILHT;`4AS99?MKrHbF|p-ChXZwy>2=b`1tD%cY}GxG9K<<R5Y*K=5KfCsU_g(w
0NM!V<v_@hwQWqM{<sd9oKcUsyXUmehsty+WdkSP?_QFMo;(}aBy-MIzGWLENb!#)+XueBOyh%Ucq$e
inT;&!nY*srWp$P^_WAdC?hQ_QOI46$nBYwXGtNND_H;AVvUQsE8O@UGxYrX9I*rsd!lfZ_9i(AD41@
4Ob9<poaXa8us+Ik3-ea!Y^)%<U}6Y?RurB0-qDpY?Q4_?AjB4J)OZVqP2L%*j<PgW+?#|@SHw=P|FK
DP>AD>ZFVp6F_Tx}_y>SOQVcg1L8{1nA{@yu{@9|!|3}S5cRw*8w-`_S3d<RkvuooypX4a!r2A79pEn
<%V2ZIAb-3Ly?OS>BzsLcgunx@kv&<&BR(Nw)2i!uo5_6uh8)BCFt#eS)UW6pRI@#4)htTEHT3k*4F|
FAouPcT&|vl+C_90U#K$I#uV;<V9ObzE+egza$9O!}086+KC6p0sd7^I%tJ_Ex&x9@7DgBjo19Y{(MJ
+hO?PEDuUCt4VB1uC`lTbRXzP7<enl+W#E(m2a<p`|`W5FI12n-Gk)dbRn29Ov{yl(<{L%yT8CjBo`;
W!l<j0eH@iHgDcIdELRX$#^Y0;Xgp#PO~vba6Ob<n$j>AAR8Sa;3mOKQ)_Cwzqz7@(jhT8i7+M+Os^5
ZTjVUa6j@+;Z-F9N@&2ZL=O3rAo6LB3R45XM~Kt|e3(=i~4JnJ^j^$gbQ<z|}vM*I>@CDB+3U<I*D*W
o&C4}9CB7iyf54^*svbi~8249{LxLxOOLh6`d%W8;&}V)DRoj?Nt75`t3D%uGSwVW30{y?>b?mB0|&%
-IbhlOHq8$