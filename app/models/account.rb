class Account < ApplicationRecord
	before_create :generate_token
	ROLE = {0 => "普通用户",1 => "管理员",2 => "超级管理员"}

	def generate_token
	  Rails.logger.info "===generate_token=========="
	  auth_token = nil
	  begin
	   auth_token = SecureRandom.urlsafe_base64
	   Rails.logger.info "===auth_token==========#{auth_token}"
	  end while Account.exists?(auth_token:"#{auth_token}")
	  self.auth_token = auth_token
	end
end