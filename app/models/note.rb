class Note < ApplicationRecord

	def self.get_note(arrs)
		(1..4).each do |product_type|
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
