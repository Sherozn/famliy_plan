class Disease < ApplicationRecord

	# code: 疾病代码
	# name: 疾病名称
	# rank: 疾病等级  默认0  1是直接拒保 


	# issues content问题内容、insurance_ids(集合)、disease_id、rank（等级）、iss_ids答案集合，也就是issue_item的id集合

	# 还需要一个表格  是issue_item表格，answer答案内容、issue_id所属问题的id、next_issue_id下一个issue的id
	# result 核保结果（0没有结束，下一个问题 1是标准体承保 2是除外承保 3是加费承保 4是拒保 5是转人工核保）

	# 1、我点击页面上需要选择我的疾病，就是Disease中的内容，通过iss_ids答案集合集合将issue选择出来，循环
	# 然后会出现与这个疾病相关的问题，也就是issue表中的内容，根据等级依次出现，
	# 选择了问题之后，选择需要出现这个问题的各个选项，也就是issue_item表中的内容
	# 系统判断目前是否需要出现核保结果，如果核保结果是0，则循环继续到下一个issue
	# 如果核保结果不是0，则可以得出投保结论

	# 2、通过传入信息表格，来获取当前疾病，生成核保结果。
	# 那么就需要将疾病都整理到表格中,让客户选择疾病，将几种高发的疾病的例子都列上
	# Disease疾病表格，Issues表格，里面有disease_id字段和疾病情况


	# status: 0
	# Disease.import_disease
	def self.import_disease
		path = "/vagrant/famliy_plan/public/小雨伞智能核保.xlsx"
  	xls = Roo::Excelx.new path
  	sheet = xls.sheet(7)
  	arrs = []
  	disease_flag = nil

    sheet.each_with_index do |arr, index|
    	
    	if index > 2 
    		name = arr[2].to_s.strip
    		#初始化disease_flag
    		if index == 3
    			disease_flag = nil
    		end
    		if !name.blank? && name != disease_flag
    			arrs = [] << arr
    			disease_flag = name
    		  # dis = Disease.find_or_create_by(code:arr[1].to_s.strip,name:name,rank:0,status:0)
    		else
    			arrs << arr
    		end	
    		dis = Disease.where(name:disease_flag).last
    		
    		Rails.logger.info "===dis=======#{dis.name}====="
    		Disease.make_dis(arrs,dis)
    	end
    end
  end

# Disease.make_dis(arrs,dis)
  def self.make_dis(arrs,dis)
  
  	issue_items = {}
  	issues = []
  	old_issues = []
  	issue = Issue.new
		[3,4,5,6,7,8,9,10].each_with_index do |iss,i|
			
			flag = 0
			flag1 = 0
			Rails.logger.info "===iss=========#{iss}==="
			if iss % 2 == 1
				old_issues = issues
				issues = []
			elsif iss % 2 == 0
				issue_items = {}
			end
			arrs.each_with_index do |aa,j|

				if iss%2 == 1 && !aa[iss].blank?
					issue = Issue.find_or_create_by(disease_id:dis.id,rank:iss/2,content:aa[iss])
					issue.insurance_ids = issue.insurance_ids << 1 unless issue.insurance_ids.include?(1)
					issue.save
					issues << issue.id
				elsif iss%2 == 0 && !aa[iss].blank?
					if !aa[iss-1].blank? 
						issue = Issue.where(content:aa[iss-1],disease_id:dis.id).last
					end
					Rails.logger.info "jjjjjj====#{j}===issues22222=========#{issues}===issue_id======#{issue.id}"
					issue_item = IssueItem.find_or_create_by(issue_id:issue.id,answer:aa[iss],flag: j)
					issue_item.save

					if issue_items[issue.id].blank?
						issue_items[issue.id] = [issue_item.id]
					else
						issue_items[issue.id] << issue_item.id
					end
				end
				
			end
			arrs.each_with_index do |aa,j|
				if iss%2 == 1 && i > 0
					if !aa[iss-1].blank? 
						
						Issue.where(id:issues).each_with_index do |issue,index|
							if aa[iss] == issue.content
								issue_items.each do |key,value|
									issue_item = IssueItem.where(id:value,answer:aa[iss-1],flag:j).last
									issue_item.update(next_issue_id:issue.id) if issue_item
								end
							end
						end
	  				Rails.logger.info "jjjjj=====#{j}====issuea=======#{issues}=====issue_items=========#{issue_items}======flag======#{flag}"
	  			end
	  		end
  		end
  		IssueItem.where(next_issue_id:nil,result:nil).each do |ii|
  			result_arr = arrs[ii.flag][11].to_s.strip
  			Rails.logger.info "===result_arr======#{result_arr}"
  			if result_arr == "标准体"
					result = 1
				elsif result_arr == "拒保"
					result = 4
				elsif result_arr == "除外承保"
					result = 2
				elsif result_arr == "转人工核保"
					result = 5
				end
				Rails.logger.info "===result======#{result}"
				ii.result = result
				ii.save
			end				
				  					
  		#回答列
  		if iss%2 == 0
  			Rails.logger.info "===issues=====#{issues}=====issue_items=========#{issue_items}=======flag======#{flag}"
  			Issue.where(id:issues).each_with_index do |issue,index|
  				issue.update(iss_ids: issue_items[issue.id])
  			end
	  		# Issue.find(issues[flag-1]).update(iss_ids: issue_items[flag])
	  	end
		end
  end
end
