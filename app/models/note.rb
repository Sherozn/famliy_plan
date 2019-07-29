class Note < ApplicationRecord
	# rank 等级  1是标准体承保 2是除外承保 3是加费承保 4是不确定，需要检查项目之后确认再投保 5是转人工核保 6是拒保 7待确认

	# arrs是疾病的集合
	# product_types是险种的集合
	# arrs = ["甲状腺结节","脑出血"]
	# 先是擎天柱3号，甲状腺结节不能买，rank是6，结束循环，
	# 进入擎天柱3号标准版，甲状腺结节可以买rank是1，脑出血不确定
	# 进入华贵大麦，甲状腺结节可以买rank是1，脑出血不确定
	# 进入瑞泰瑞和，甲状腺结节可以买rank是1，脑出血不确定

# {[寿险、未确认]=>{
# 	[擎天柱3号优选版,7]=>[[甲状腺结节,6],[脑出血,7]],
# 	[爱相随,7]=>[[甲状腺结节,1],[脑出血,7]],
# 	[大麦,7]=>[[甲状腺结节,1],[脑出血,7]]}}
	def self.get_note(arrs,product_types)
		notes = {}
		product_types.each do |product_type|
			insurances = {}
			Insurance.where(product_type:product_type).order(rank: :desc).each do |ins|
				ins_arr = []
				max_rank = 7
				arrs.each do |arr|
					note = Note.find_by(insurance_id:ins.id,name:arr)
					if note
						ins_arr << [arr,note.rank] if note.rank < max_rank
						max_rank = note.rank 
					else
						ins_arr << [arr,7]
					end
				end
				insurances[[ins.id,max_rank]] = ins_arr
			end
			notes[product_type] = insurances
			Rails.logger.info "=====notes===========#{notes}==="
		end
		notes
	end
end
