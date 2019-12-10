class Ill < ApplicationRecord
	def self.create_ill
		path = "/vagrant/famliy_plan/public/家庭信息收集.xls"
    xls = Roo::Excel.new path
    sheet = xls.sheet(1)
    sheet.each do |arr|
      if !arr[0].blank?
        name = arr[0].to_s
        Rails.logger.info "name===#{name}=="
        Ill.find_or_create_by(name:name)
      end  
    end
	end
end
