class Note < ApplicationRecord
	# rank 等级  

	# arrs是疾病的集合
	# product_types是险种的集合
	# arrs = ["甲状腺结节","脑出血"]
	# 先是擎天柱3号，甲状腺结节不能买，rank是6，结束循环，
	# 进入擎天柱3号标准版，甲状腺结节可以买rank是1，脑出血不确定
	# 进入华贵大麦，甲状腺结节可以买rank是1，脑出血不确定
	# 进入瑞泰瑞和，甲状腺结节可以买rank是1，脑出血不确定

# [4, 0, 7]=>{[4, 7, 1]=>[["甲状腺结节3级", 7]], [14, 7, 1]=>[["甲状腺结节3级", 7]], [15, 7, 1]=>[["甲状腺结节3级", 7]]}}
	def self.get_note(arrs,product_types,age)
		notes = {}
		row = 0
		product_types.each do |product_type|
			if product_type == 4
				row += 1
				if age > 17
					id = 4
				elsif age > 60 && age <= 85
					id = 14
				else 
					id = 15
				end
				notes[[4,1,1]] = {[id,1,1]=>[["1",1]]}
				break
			end
			row2 = 0
			insurances = {}
			min_ins = 7
			#某个保险关于某疾病的最优核保结果
			max_inx = 7
			insurances_arr = Insurance.where(product_type:product_type).order(rank: :desc)
			#查找出所有寿险的集合，遍历每个寿险
			insurances_arr.each do |ins|
				row3 = 0
				ins_arr = []
				min_rank = 7
				max_rank = 0
				jubao_arr = []
				#遍历所有的疾病
				arrs.each do |arr|
					note = Note.find_by(insurance_id:ins.id,name:arr)
					if note
						ins_arr << [arr,note.rank] 
						min_rank = note.rank if note.rank < min_rank
						max_rank = note.rank if note.rank > max_rank
					else
						#所有疾病的集合
						ins_arr << [arr,7]
						max_rank = 7
					end
					jubao_arr << max_rank
				end
				# 当前假设都是确认的，然后，有两个疾病，一个拒保一个标准体承保，下一个保险，一个除外承保一个除外承保
				#如果当前疾病的核保结果为标准体承保，则跳出当前寿险的循环
				if max_rank == 1
					max_inx = 1
					insurances[[ins.id,max_rank,ins_arr.count]] = ins_arr
					row += ins_arr.count
					break
				#如果这些疾病的核保对于擎天柱3号最坏结果是拒保，就没有必要去循环擎天柱3号了
				# 如果擎天柱优选版没有确认，擎天柱标准版是标准体承保
				elsif jubao_arr.include?(6)
				  next
				#如果当前寿险的核保结果大于上一个寿险的核保结果，也就是脑出血拒保，甲状腺结节除外，最后结果还是拒保，则以当前疾病为准
				elsif max_rank == 7
					insurances[[ins.id,max_rank,ins_arr.count]] = ins_arr
					row += ins_arr.count
				#如果当前寿险的核保结果比上一个寿险的核保结果好，那就以现在这个寿险为准
				elsif max_rank < max_inx
					# max_ins就是对于某个保险的最终核保结果
					max_inx = max_rank
					insurances[[ins.id,max_inx,ins_arr.count]] = ins_arr
					row += ins_arr.count
				end
				Rails.logger.info "=====max_inx===========#{max_inx}==="
				Rails.logger.info "=====max_rank===========#{max_rank}==="
			end
			#寿险,行数,最优核保结果 => 所有保险对应疾病的核保结果
			notes[[product_type,row2,max_inx]] = insurances
			# Rails.logger.info "=====notes===========#{notes}==="
		end
		[notes,row]
	end
end
