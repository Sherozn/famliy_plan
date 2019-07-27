class Issue < ApplicationRecord
	serialize :insurance_ids, Array
	serialize :iss_ids, Array
end
