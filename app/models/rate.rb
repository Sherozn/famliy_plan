class Rate < ApplicationRecord
	serialize :group, Array
	# group 产品组合：0 重疾  1 轻症  2 中症  3 癌症二次  4 身故  5 重大疾病津贴 6投保人豁免  7有社保
	# jf_year 缴费年限
	# year 保障期限
	# sex性别 0 男  1 女
	# insurance_id
	# rate
	# age

	# rails g model Rate insurance_id:integer group:string  year:integer jf_year:integer rate:float age:integer sex:integer status:integer
    def self.get_rate(product_type,ins_id,fee,age,sex,sum_amount)
      if sex == "男"
        sex_num = 0
      elsif sex == "女"
        sex_num = 1
      end  
      jf = 0.0 
      if product_type == 1
        rate = Rate.where(insurance_id:ins_id,age:age,sex:sex_num,year:60).order(:jf_year).last
        if rate
          jf = fee * 10000 * rate.rate
          rate_fj = Rate.where(insurance_id:ins_id,age:age,sex:sex_num,year:0).order(:jf_year).last.rate
          jf_fj = jf/1000 * rate_fj
          jf_sum = jf_fj + jf
        end
      elsif product_type == 2
        rate = Rate.where(insurance_id:ins_id,age:age,sex:sex_num).order(:jf_year).last
      elsif product_type == 3
        rate = Rate.where(insurance_id:ins_id,age:age,sex:sex_num).order(:jf_year).last
      elsif product_type == 4
        rate = 
      end
    end

    # 超级玛丽旗舰版
	def self.import_rate_1
		path = "/vagrant/famliy_plan/public/超级玛丽旗舰版费率表.xlsx"
  	    xls = Roo::Excelx.new path
  	    sheet = xls.sheet(0)
        sheet.each_with_index do |arr, j|
    	if j == 0
    		next
    	end
    	Rails.logger.info "==========#{arr[0]}"
    	if arr[0].blank?
    		break
    	end
    	group_old = arr[1].to_i
    	if group_old == 0
    		group = [0,1,2]
    	elsif group_old == 2
    		group = [0,1,2,3]
    	elsif group_old == 3
    		group = [0,1,2,3,4]
    	end
    	age = arr[2].to_i
    	sex = arr[3].to_i
    	jf_year = arr[4].to_i
    	year = arr[5].to_i
    	rate = Rate.find_or_create_by(insurance_id:1,group:group,sex:sex,age:age,year:year)
    	if rate.jf_year 
    		if rate.jf_year < jf_year
    		  rate.jf_year = jf_year
    		  rate.rate = arr[6].to_f
    		end
    	else
    		rate.jf_year = jf_year
    		rate.rate = arr[6].to_f
    	end
    	rate.save
    end
	end

  # 健康保
	def self.import_rate_2
		path = "/vagrant/famliy_plan/public/健康保费率表.xlsx"
  	xls = Roo::Excelx.new path
  	sheet = xls.sheet(0)
  	group = nil
    year = nil
    sex = nil
    jf_year = nil
    sheet.each_with_index do |arr, j|
    	Rails.logger.info "==group=#{group}======year=#{year}=======sex=#{sex}====="
    	if arr[1].to_s =~ /\d{1,2}/
    		age = arr[1].to_i
    		[3,4,5,6,7].each do |i|
    			if i == 3
    				jf_year = 5
    			elsif i == 4
    				jf_year = 10
    			elsif i == 5
    				jf_year = 15
    			elsif i == 6
    				jf_year = 20
    			elsif i == 7
    				jf_year = 30
    			end
    			rate = arr[i]
    			if !rate.blank?
    				Rails.logger.info "==jf_year=#{jf_year}======age=#{age}=======rate=#{rate}====="
    				Rate.find_or_create_by(insurance_id:2,jf_year:jf_year,sex:sex,age:age,year:year,group:group,rate:rate)
    			end
    		end
    	else
    		[3,4,5].each do |ii|
    			Rails.logger.info "=iiiiiiii#{ii}==arr[ii]=========#{arr[ii]}"
	    		if arr[ii].to_s.strip == "必选责任" 
		    		group = [0,1,2]
		    	elsif arr[ii].to_s.strip == "可选责任：重大疾病医疗津贴保险金"
		    		group = [5]
		    	elsif	arr[ii].to_s.strip == "可选责任：恶性肿瘤保险金"
		    		group = [3]
		    	elsif	arr[ii].to_s.strip.include?("豁免保险费责任(")
		    		group = [6]
		    	else
		    		Rails.logger.info "必选责任未读取到"
		    		# break
		    	end
		    	if arr[ii].to_s.gsub(" ","").include?("70周岁")
		    		year = 70
		    	elsif arr[ii].to_s.gsub(" ","").include?("80周岁")
		    		year = 80
		    	elsif arr[ii].to_s.gsub(" ","").include?("保终身")
		    		year = 106
		    	elsif arr[ii].to_s.gsub(" ","").include?("豁免保险费责任(")
		    		year = 0
		    	end
		    	if arr[ii].to_s.gsub(" ","").include?("男性")
		    	  sex = 0
		    	elsif arr[ii].to_s.gsub(" ","").include?("女性")
		    		sex = 1
		    	end
	    	end
    	end
    	
    end
	end

	# 好医保长期医疗、微医保长期医疗
	def self.import_rate_3
		hash_1 = {[0,1,2,3,4]=> 568,(5..10)=>166,(11..15)=>106,(16..20)=>108,
			(21..25)=>149,(26..30)=>229,(31..35)=>299,(36..40)=>418,(41..45)=>539,
			(46..50)=>759,(51..55)=>999,(56..60)=>1399}
		hash_1.each do |key,value|
			key.each do |age|
				Rails.logger.info "======age====#{age}"
				rate = Rate.find_or_create_by(insurance_id:3,group: [7],year: 1,jf_year: 1,rate:value,age:age,status:0)
			end
		end
		arr_1 = [731,655,575,495,423,354,320,284,247,210,175,148,153,158,163,
			169,186,197,210,222,236,260,272,284,297,310,338,354,370,387,405,440,
		  458,477,497,518,554,572,591,610,630,697,746,798,851,906,1005,1053,
		  1104,1157,1214,1344,1425,1511,1598,1689,1861,1956,2052,2154,2259]
		(0..60).each_with_index do |age,index|
			rate = Rate.find_or_create_by(insurance_id:5,group: [7],year: 1,jf_year: 1,rate:arr_1[index],age:age,status:0)
		end
	end

	# 擎天柱3号
	# Rate.import_rate_6
	def self.import_rate_6
		path = "/vagrant/famliy_plan/public/擎天柱3号费率表.xlsx"
  	xls = Roo::Excelx.new path
  	sheet = xls.sheet(0)
  	group = [0]
    year = nil
    insurance_id = nil
    # sex = nil
    jf_year = nil
    sheet.each_with_index do |arr, j|
    	Rails.logger.info "=====year=#{year}========="
    	if arr[0].to_s =~ /\d{1,2}/ && arr[0].to_s.length < 3
    		age = arr[0].to_i
    		(3..10).each do |i|
    			if i == 3
    				jf_year = 5
    			elsif i == 5
    				jf_year = 10
    			elsif i == 7
    				jf_year = 20
    			elsif i == 9
    				jf_year = 30
    			end
    			if i % 2 == 0
    				sex = 1
    			elsif i % 2 == 1
    				sex = 0
    			end
    			rate = arr[i]
    			if !rate.blank?
    				Rails.logger.info "insurance_id===#{insurance_id}==jf_year=#{jf_year}==sex===#{sex}====age=#{age}===year====#{year}====rate=#{rate}====="
    				Rate.find_or_create_by(insurance_id:insurance_id,jf_year:jf_year,sex:sex,age:age,year:year,group:group,rate:rate)
    			end
    		end
    	elsif arr[0]
    		# [3,4,5].each do |ii|
    			Rails.logger.info "===arr[0]=========#{arr[0]}"
    			arr0 = arr[0].to_s.gsub(" ","")
		    	if arr0.include?("20")
		    		year = 20
		    	elsif arr0.include?("30")
		    		year = 30
		    	elsif arr0.include?("60")
		    		year = 60
		    	elsif arr0.include?("65")
		    		year = 65
		    	elsif arr0.include?("70")
		    		year = 70
		    	elsif arr0.include?("80")
		    		year = 80
		    	end

		    	if arr0.include?("优选体")
		    		insurance_id = 6
		    	elsif arr0.include?("标准体")
		    		insurance_id = 7
		    	end
	    	# end
    	end
    end
	end

	# 擎天柱3号附加豁免
	# Rate.import_rate_7
	def self.import_rate_7
		path = "/vagrant/famliy_plan/public/擎天柱3号附加豁免费率表.xls"
  	xls = Roo::Excel.new path
  	[0,1].each do |sex|
	  	sheet = xls.sheet(sex)
	  	group = [6]
	    year = 0
	    sheet.each_with_index do |arr, j|
	    	Rails.logger.info "=====year=#{year}========="
	    	if j >= 3
	    		age = arr[0].to_i
	    		[5,10,20,30].each do |i|
	    			rate = arr[i-1]
	    			if rate
		    			Rails.logger.info "=jf_year=#{i}==sex===#{sex}====age=#{age}===year====#{0}====rate=#{rate}====="
		    			Rate.find_or_create_by(insurance_id:6,jf_year:i,sex:sex,age:age,year:year,group:group,rate:rate)
		    			Rate.find_or_create_by(insurance_id:7,jf_year:i,sex:sex,age:age,year:year,group:group,rate:rate)
		    		end
	    		end 			
	    	end
	    end
	  end
	end
end
