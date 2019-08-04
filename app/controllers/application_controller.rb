class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # 获取各种情况下应该买的险种
  def self.get_product_types(man_income,woman_income,member)
		sum_income = man_income + woman_income
		product_types = []
		if sum_income <= 10
			if member == "先生" 
				if man_income > 0
				  product_types = [1,2,3]
				else
					product_types = [2,3]
				end
			elsif member == "太太" 
				if woman_income > 0
				  product_types = [1,2,3]
				else
					product_types = [2,3]
				end
			elsif member == "大宝" || member == "小宝"
				product_types = [2,3]
			else
				product_types = [3,4]
			end
		else
			if member == "先生" 
				if man_income > 0
				  product_types = [1,2,3,4]
				else
					product_types = [2,3,4]
				end
			elsif member == "太太" 
				if woman_income > 0
				  product_types = [1,2,3,4]
				else
					product_types = [2,3,4]
				end
			elsif member == "大宝" || member == "小宝"
				product_types = [2,3,4]
			else
				product_types = [3,4]
			end
		end
		product_types
	end

	def self.get_age(birth)
		# fn = birth.to_s.gsub("年","-").gsub("月","-").gsub(".","-").gsub("/","-")
    # m = fn.match(/\d{4}[-\.\/]?(0\d|1[012])[-\.\/]?[0123]?\d{1}/)
    if !birth.blank?
		  age = ((Date.today - Time.parse(birth).to_date) / 365).floor
		else
			age = 100
		end
		age
	end

	def self.get_product_type(product_type)
		if product_type.to_i == 1
			str = "寿险"
		elsif product_type.to_i == 2
			str = "重疾险"
		elsif product_type.to_i == 3
			str = "医疗险"
		elsif product_type.to_i == 4
			str = "意外险"
		end
		str
	end
end
