require 'rubygems'
require 'rest-client'

class SendMail
	def self.send_mail(to,subject,html)
                response = RestClient.post "http://api.sendcloud.net/apiv2/mail/send",
                :apiUser => 'xuzhaoning_test_uQgpis', # 使用api_user和api_key进行验证
                :apiKey => 'vpJ5xA9ph4qrM6dp', #点击左侧菜单API User,点击生成新的API_KEY
                :from => "sendcloud@cxSVVBe4BAIvKZwWyHjm4HuvmQld0FRO.sendcloud.org", # 发信人，用正确邮件地址替代
                :fromName => "SendCloud",
                :to => "#{to}", # 收件人地址，用正确邮件地址替代，多个地址用';'分隔
                :subject => "#{subject}",
                :html => "#{html}"
        	return response
	end
end