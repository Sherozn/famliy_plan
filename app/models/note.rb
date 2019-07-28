class Note < ApplicationRecord

	# arrs是疾病的集合
	# product_types是险种的集合
	def self.get_note(arrs,product_types)
		return
		product_types.each do |product_type|
			notes = {}
			Insurance.where(product_type:product_type).order(rank: :desc).each do |ins|
				arrs.each do |arr|
					note = Note.find_by(insurance_id:ins.id,name:arr)
					if note
						notes[ins.rank] = note.note
					else
						notes[ins.rank] = ins.id
					end
				end
			end
		end
	end
end
