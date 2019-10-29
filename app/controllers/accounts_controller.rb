class AccountsController < ApplicationController
  before_action :check_login, except:[:signup,:create_account,:login,:create_login,:logout]
  def signup
  	@account = Account.new
  end

  def create_account
  	@account = Account.new
  	#取出param中的name、email等元素
    name = params[:account][:name]
    email = params[:account][:email]
    password = params[:account][:password]
    password_confirmation = params[:account][:password_confirmation]
    role = params[:account][:role]
    #status为0，代表账号是激活状态；为1，代表账号是未激活状态
    status = 0
    #role角色 0普通用户 1管理员 2超级管理员
    #角色为管理员的时候，账号要被设为未激活状态，经过超级管理员管理员审核通过，才可变为激活状态
    #其他角色注册账号，状态默认为激活状态
    if role.to_i == 1
      status = 1
    end
    #从账户表中查找是否有相同的email，有相同的email说明该邮箱已经被注册过了
    account = Account.where(email:email).first
    if name.blank? || email.blank?
      flash.notice = "用户名或者邮箱不能为空"
      render :signup
    elsif name.length > 5
    	flash.notice = "用户名长度不能大于5"
    	render :signup
    elsif account
      flash.notice = "邮箱已注册"
      render :signup
    elsif password != password_confirmation
      flash.notice = "两次密码输入不一致"
      render :signup
    else
      @account.status = status
      @account.name = name
      @account.email = email
      @account.password = Des.des_encode(password)
      @account.role = role
      boolean = @account.save
      puts "====boolean======#{boolean}===="
      #boolean为true时说明account保存成功
      if boolean
      	# UserMailer.welcome_email(@account).deliver
        subject = "#{name}您好，欢迎加入宠物之家"
        html = "#{name}您好，您已注册成功，在宠物之家论坛可以畅所欲言啦~"
        response = SendMail.send_mail(email,subject,html)
        flash.notice = "注册成功！请登录"
        redirect_to :login
      else
        flash.notice = "注册失败！请重新注册"
        render :signup
      end
    end
  end

  def login
  end

  def create_login
  	#从哈希params中取email、password的值
  	#strip是去除字符串头部和尾部的空格
    email = params[:email].strip
    password_html = params[:password].strip
    #先查找这个用户，where查出来返回的结果类型是ActiveRecord_Relation，不能直接调用实例方法，得加first才能使用
    account = Account.find_by(email:email)
    #如果用户存在
    if account
      #用户的身份为管理员，状态为激活，密码正确，可以登录成功
      if account.role == 1 && account.status == 0
        #数据库存储的密码解密与用户输入的密码作对比
        if Des.des_decode(account.password).to_s == password_html
          if params[:remember_me]
      		  cookies.permanent[:auth_token] = account.auth_token
      		else 
      		  cookies[:auth_token] = account.auth_token
      		end
          flash.notice = "登录成功！"
          redirect_to :root
        else
          flash.notice = "用户名密码错误!"
          render :login
        end
      #如果用户为管理员身份，状态为未激活，需要提示激活信息
      elsif account.role == 1 && account.status == 1
        flash.notice = "您的用户未激活,请超级管理员激活后再重新登录"
        render :login
      #其他类型的客户，密码正确，可以登录
      else
        if Des.des_decode(account.password).to_s == password_html
          if params[:remember_me]
      		  cookies.permanent[:auth_token] = account.auth_token
      		else 
      		  cookies[:auth_token] = account.auth_token
      		end
          flash.notice = "登录成功！"
          redirect_to :root
        else
          flash.notice = "用户名密码错误!"
          render :login
        end
      end
    #如果用户不存在，需要提示用户去注册
    else
      flash.notice = "用户不存在，请先注册"
      render :login
    end   
  end

  def logout
  	cookies.delete(:auth_token)
  	redirect_to :root
  end

  #超级管理员激活管理员账户页面
  def account_active
  	@accounts = Account.where(role:1)
  end

  #改变激活状态
  def update_active
  	account_id = params[:account_id]
  	account = Account.find(account_id)
  	account.status = 0
  	account.save
  	redirect_to :account_active
  end

end
