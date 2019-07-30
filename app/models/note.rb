class Note < ApplicationRecord
	# rank 等级  

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
		row = 0
		product_types.each do |product_type|
			row2 = 0
			insurances = {}
			min_ins = 7
			#某个保险关于某疾病的最优核保结果
			max_inx = 0
			insurances_arr = Insurance.where(product_type:product_type).order(rank: :desc)
			#查找出所有寿险的集合，遍历每个寿险
			insurances_arr.each do |ins|
				row3 = 0
				ins_arr = []
				min_rank = 7
				max_rank = 7
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
				end
				# 当前假设都是确认的，然后，有两个疾病，一个拒保一个标准体承保，下一个保险，一个除外承保一个除外承保
				#某个保险，某个疾病是拒保的
				# if max_rank == 6 || 
				
				#如果当前疾病的核保结果为标准体承保，则跳出当前寿险的循环
				if max_rank == 1
					max_inx = 1
					insurances[[ins.id,max_rank,ins_arr.count]] = ins_arr
					break
				#如果这些疾病的核保对于擎天柱3号最坏结果是拒保，你们就没有必要去循环擎天柱3号了
				# 如果擎天柱优选版没有确认，擎天柱标准版是标准体承保
				elsif max_rank == 6
				  next
				#如果当前寿险的核保结果大于上一个寿险的核保结果，也就是脑出血拒保，甲状腺结节除外，最后结果还是拒保，则以当前疾病为准
				elsif max_rank == 7
					insurances[[ins.id,max_rank,ins_arr.count]] = ins_arr
				#如果当前寿险的核保结果比上一个寿险的核保结果好，那就以现在这个寿险为准
				elsif max_rank < max_ins 
					# max_ins就是对于某个保险的最终核保结果
					max_ins = max_rank
				end

				if min_rank < min_ins || (min_ins != 1 && min_rank == 7)
					#保险id,当前最优结果（针对寿险）,单个险种对应的行数
					insurances[[ins.id,min_rank,ins_arr.count]] = ins_arr
					row += ins_arr.count
					min_ins = min_rank if min_rank < min_ins
					if min_ins == 1

					end
				elsif min_rank < min_ins || min_rank == 1 
					notes[[product_type,row2]] = {}

					insurances[[ins.id,min_rank,max_inx.count]] = ins_arr
				end
			end
			#寿险,行数,最优核保结果 => 所有保险对应疾病的核保结果
			notes[[product_type,row2,min_ins]] = insurances
			# Rails.logger.info "=====notes===========#{notes}==="
		end
		[notes,row]
	end
end
