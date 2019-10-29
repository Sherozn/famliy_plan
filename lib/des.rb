class Des
  ALG = 'DES-EDE3-CBC'
  KEY = "5iLuoPan"     #你的密钥
  DES_KEY = "XWERDFGS"          #任意固定长度为8的值
	
  #加密
  def self.des_encode(str)
    des = OpenSSL::Cipher::Cipher.new(ALG)
    des.pkcs5_keyivgen(KEY, DES_KEY)
    des.encrypt
    cipher = des.update(str)
    cipher << des.final
    return Base64.encode64(cipher).gsub(/(^\s*)|(\s*$)/, "") #Base64编码，才能保存到数据库
  end

  #解密
  def self.des_decode(str)
    str = Base64.decode64(str)
    des = OpenSSL::Cipher::Cipher.new(ALG)
    des.pkcs5_keyivgen(KEY, DES_KEY)
    des.decrypt
    des.update(str) + des.final
  end
end	