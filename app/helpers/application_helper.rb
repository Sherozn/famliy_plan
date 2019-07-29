module ApplicationHelper
	def get_product_type(product_type)
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

	def get_rank(rank)
		if rank.to_i == 1
			str = "标准体承保"
		elsif rank.to_i == 2
			str = "除外承保"
		elsif rank.to_i == 3
			str = "加费承保"
		elsif rank.to_i == 4
			str = "不确定，需要检查项目之后确认再投保"
		elsif rank.to_i == 5
			str = "转人工核保"
		elsif rank.to_i == 6
			str = "拒保"
		elsif rank.to_i == 7
			str = "待确认"
		end
		str
	end
end
