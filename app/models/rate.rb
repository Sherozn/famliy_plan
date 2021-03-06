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
        Rails.logger.info "===age   #{age}=======sex   #{sex}==="
      if sex == "男"
        sex_num = 0
      elsif sex == "女"
        sex_num = 1
      end  
      jf_sum = 0.0
      jf_year = 0
      year15 = 0
      if product_type == 1
        rate = Rate.where(insurance_id:ins_id,age:age,sex:sex_num,year:60).order(:jf_year).last
        if rate
          jf = fee * 10000/1000 * rate.rate
          jf_year = rate.jf_year
          rate_fj = Rate.where(insurance_id:ins_id,age:age,sex:sex_num,year:0,jf_year:jf_year).last
          if rate_fj
            jf_fj = jf/1000 * rate_fj.rate
            jf_sum = jf_fj + jf
          else
            jf_sum = jf
          end
        end
      elsif product_type == 2
        if ins_id == 16
            [15,20,25,30].each do |year|
                if age+year >= 30
                    Rails.logger.info "===year=======#{year}"
                    rate = Rate.where(insurance_id:ins_id,age:age,sex:sex_num,year:year,group: [0, 1, 2]).order(:jf_year).last
                    year15 = year
                    if rate
                        Rails.logger.info "===rate=======#{rate.id}"
                        jf_sum = fee * 10000/1000 * rate.rate
                        jf_year = rate.jf_year
                    end
                    rate_fj_obj = Rate.where(insurance_id:ins_id,age:age,sex:sex_num,year:0,group: [6]).order(:jf_year).last
                    if rate_fj_obj
                      jf_sum = jf_sum + jf_sum/1000 * rate_fj_obj.rate
                    end
                    break
                end
            end
        end
        # low_fee = sum_amount*0.03/1000
        rate = Rate.where(insurance_id:ins_id,age:age,sex:sex_num,year:70).order(:jf_year).last
        if rate
          jf_sum = fee * 10000/1000 * rate.rate
          jf_year = rate.jf_year
          if ins_id == 2
            rate_fj = Rate.where(insurance_id:ins_id,age:age,sex:sex_num,year:0,jf_year:jf_year).order(:jf_year).last.rate
            jf_fj = jf_sum/1000 * rate_fj
            jf_sum = jf_fj + jf_sum
          end
          
        end
      elsif product_type == 3
        rate = Rate.where(insurance_id:ins_id,age:age).last
        if rate
          jf_sum = rate.rate
        end
        if ins_id == 3 || ins_id == 5
            jf_year = 6
        else
            jf_year = 1
        end
      elsif product_type == 4
        rate = Rate.where(insurance_id:ins_id).last
        if rate
          jf_sum = rate.rate
          jf_year = 1
        end
      end
      Rails.logger.info "===year15=======#{year15}"
      [jf_year,jf_sum,year15]
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

    # 晴天保保
    # Rate.import_rate_16
    def self.import_rate_16
        path = "/vagrant/famliy_plan/public/晴天保保费率表.xlsx"
        xls = Roo::Excelx.new path
        sheet = xls.sheet(0)
        group = nil
        year = nil
        sex = nil
        jf_year = nil
        sheet.each_with_index do |arr, j|
            # Rails.logger.info "==arr[0]===#{arr[0]}="
            if arr[0].to_s =~ /\d{1,2}/
                age = arr[0].to_i
                [3,4,5,6,7,8,9,10,11,12].each do |i|
                    if i%2 == 0
                        sex = 1
                    else
                        sex = 0
                    end
                    if i == 3
                        jf_year = 3
                    elsif i == 5
                        jf_year = 5
                    elsif i == 7
                        jf_year = 10
                    elsif i == 9
                        jf_year = 15
                    elsif i == 11
                        jf_year = 20
                    end
                    rate = arr[i]
                    # Rails.logger.info "==rate===#{rate}"
                    if !rate.blank?
                        if year == 0
                            rate = rate
                        else
                            rate = "%.2f" % (rate.to_f/10)
                        end
                        Rails.logger.info "==jf_year=#{jf_year}======age=#{age}=======rate=#{rate}======sex=#{sex}======year=#{year}"
                        Rate.find_or_create_by(insurance_id:16,jf_year:jf_year,sex:sex,age:age,year:year,group:group,rate:rate)
                    end
                end
            else
                [2,3,4].each do |ii|
                    # Rails.logger.info "=iiiiiiii#{ii}==arr[ii]=========#{arr[ii]}"
                    if arr[ii].to_s.strip == "15年" 
                        group = [0,1,2]
                        year = 15
                    elsif arr[ii].to_s.strip == "20年" 
                        group = [0,1,2]
                        year = 20
                    elsif arr[ii].to_s.strip == "25年" 
                        group = [0,1,2]
                        year = 25
                    elsif arr[ii].to_s.strip == "30年" 
                        group = [0,1,2]
                        year = 30
                    elsif arr[ii].to_s.strip.include?("瑞泰附加投保人豁免重大疾病保险产品费率表")
                        group = [6]
                        year = 0
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

    #安心安享一生
    def self.import_rate_17
        hash_1 = {(0..6)=> 250,(7..20)=>50,(21..25)=>99,(26..30)=>125,
            (31..35)=>165,(36..40)=>205,(41..45)=>244,(46..50)=>333,(51..55)=>410,
            (56..60)=>471,(61..65)=>617,(66..70)=>911}
        hash_1.each do |key,value|
            key.each do |age|
                Rails.logger.info "======age====#{age}"
                rate = Rate.find_or_create_by(insurance_id:17,year: 1,jf_year: 1,rate:value,age:age,status:0)
            end
        end
    end

    #国泰父母综合意外
    def self.import_rate_14
        hash_1 = {(66..75)=> 188,(76..80)=>400,(81..85)=>500}
        hash_1.each do |key,value|
            key.each do |age|
                Rails.logger.info "======age====#{age}"
                rate = Rate.find_or_create_by(insurance_id:14,year: 1,jf_year: 1,rate:value,age:age,status:0)
            end
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

    # 大麦正青春
    def self.import_rate_20
        arr = [[18,30,0,0.73],[19,30,0,0.74],[20,30,0,0.76],[21,30,0,0.77],[22,30,0,0.79],
        [23,30,0,0.80],[24,30,0,0.81],[25,30,0,0.83],[26,30,0,0.84],[27,30,0,0.86],
        [28,30,0,0.87],[29,30,0,0.89],[30,30,0,0.90],[31,20,0,1.35],[32,20,0,1.37],
        [33,20,0,1.39],[34,20,0,1.41],[35,20,0,1.43],[36,20,0,1.44],[37,20,0,1.46],
        [38,20,0,1.47],[39,20,0,1.48],[40,20,0,1.49],
        [18,30,1,0.38],[19,30,1,0.39],[20,30,1,0.40],[21,30,1,0.41],[22,30,1,0.42],
        [23,30,1,0.42],[24,30,1,0.43],[25,30,1,0.44],[26,30,1,0.45],[27,30,1,0.46],
        [28,30,1,0.47],[29,30,1,0.48],[30,30,1,0.49],[31,20,1,0.73],[32,20,1,0.74],
        [33,20,1,0.76],[34,20,1,0.77],[35,20,1,0.78],[36,20,1,0.79],[37,20,1,0.80],
        [38,20,1,0.81],[39,20,1,0.82],[40,20,1,0.83]]
        arr.each do |key|
            age = key[0]
            jf_year = key[1]
            sex = key[2]
            ra = key[3]
            rate = Rate.find_or_create_by(insurance_id:20,year: 60,status:0,jf_year: jf_year,age:age,sex:sex)
            rate.rate = ra
            rate.save
        end
    end

    def self.import
        path = "/vagrant/famliy_plan/public/臻爱优选费率表.xlsx"
        xls = Roo::Excelx.new path
        sheet = xls.sheet(0)
        sheet.each_with_index do |arr, j|
            if !arr[0].blank? && j > 0
                age = arr[0].to_i
                sex = arr[1].to_i
                jf_year = arr[2].to_i
                year = arr[3].to_i
                rate = arr[4].to_f
                group = arr[5].to_s.strip.split("、").map{|gr| gr.to_i}
                insurance_id = arr[6].to_i
            end  
            if !rate.blank?
                Rails.logger.info "insurance_id===#{insurance_id}==jf_year=#{jf_year}==sex===#{sex}====age=#{age}===year====#{year}====rate=#{rate}=====group=#{group}"
                Rate.find_or_create_by(insurance_id:insurance_id,jf_year:jf_year,sex:sex,age:age,year:year,group:group,rate:rate)
            end
        end
    end
end
