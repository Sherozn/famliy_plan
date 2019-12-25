class HomeController < ApplicationController
	before_action :check_login
  def index
  	# path = "/vagrant/famliy_plan/public/家庭保障方案.xlsx"
  	# begin
	  # 	xls = Roo::Excelx.new path
	  # rescue
	  # 	xls = Roo::Excel.new path
	  # end
	  # sheet = xls.sheet(2)
   #  sheet.each_with_index do |arr, j|
   #  	if j==2
   #  		sheet.row(j)[6] = "你好"
   #  		p arr[6]
   #  	end
   #  end
    # book.write path
  end

  def down_rate
  	path = "#{Rails.root}/public/费率表模板.xlsx"
  	send_file path, :type=>"application/octet-stream;charset=utf-8", :filename => CGI::escape("费率表模板.xlsx"), disposition: 'attachment'
  end

  def derive
  	array = (%x{cd lib/python/ && python make_excel.py})

  	path = "#{Rails.root}/public/1力哥理财家庭保障规划.xlsx"
  	# send_file path, :type=>"application/octet-stream;charset=utf-8", :filename => "#{valuation_table.filename}.xls", disposition: 'attachment'

    send_file path, :type=>"application/octet-stream;charset=utf-8", :filename => CGI::escape("力哥理财家庭保障规划.xlsx"), disposition: 'attachment'
  end

  def import_information

  end

  def create_information
  	ori_file = params[:file].original_filename
  	Rails.logger.info "===========文件名称======#{ori_file}"
  	begin
  		Rails.logger.info "===========第一个错误======#{ori_file}"
	    xlsx = Roo::Spreadsheet.open(params[:file])
	    sheet = xlsx.sheet(0)
	  rescue e
	  	Rails.logger.info "===========第二个错误======#{e}"
	  	xlsx = Spreadsheet.open(params[:file])
	  	sheet = xlsx.worksheet(0)
	  end
	  
	  # 月开支
	  month_expenses = sheet.row(2)[5].to_f
	  # 房贷
		mortgage = sheet.row(3)[5].to_f
		# 车贷
	  car_loans = sheet.row(4)[5].to_f
		# 其他负债
	  other_loans = sheet.row(5)[5].to_f
	  # 家庭流动资产
	  current_assets = sheet.row(2)[8].to_f
	  # 父母赡养费用
	  parents_support = sheet.row(3)[8].to_f
	  # 子母教育费用
	  children_education = sheet.row(4)[8].to_f

	  man_income = sheet.row(5)[8].to_f
	  woman_income = sheet.row(2)[12].to_f

	  amount = month_expenses * 12 * 5 + mortgage + car_loans + other_loans + parents_support + children_education - current_assets

	  Rails.logger.info "=====amount===#{amount}"

	  # 通过处理这些信息，我需要计算家庭责任，读取先生太太的年收入来计算寿险的比例
	  # 读取疾病信息，然后根据疾病去匹配
	  @member = nil
	  birth = nil
	  sex = nil
	  #疾病数组
	  arrs = []
	  hash = {}
	  # flag = 0
	  sheet.each_with_index do |rows,index|
	  	if index < 7
	  		next
	  	end
	  	flag_member = rows[0]
	  	if !flag_member.blank? 
	  		if flag_member != @member
		  		if @member
		  			Rails.logger.info "=====@member===#{@member}"
	  				Rails.logger.info "=====@arrs===#{arrs}"
	    			product_types = ApplicationController.get_product_types(man_income,woman_income,@member.to_s.strip)
	    			Rails.logger.info "=====@birth===#{birth}"
			  		age = ApplicationController.get_age(birth)
			  		# sex = rows[2].to_s
			  		Rails.logger.info "===age======#{age}====="
			  		Rails.logger.info "===sex======#{sex}====="
			  		
	    			notes_arr = Note.get_note(arrs,product_types,age)
	    			hash[[@member.to_s,notes_arr[1],age,sex]] = notes_arr[0]
	    		end
	  			arrs = [] 
	  			if rows[7]
	  				ill = Ill.find_or_create_by(name:rows[7].to_s.strip)
	  				arrs << ill.id
	  			end
	  			@member = flag_member
	  			birth = rows[3].to_s
	  			sex = rows[2].to_s
	  		end
  		else	
  			if rows[7]
	  			ill = Ill.find_or_create_by(name:rows[7].to_s.strip)
	  			arrs << ill.id
	  		end
  		end
	  end
	  @hash = hash
	  Rails.logger.info "=============@hash=========#{hash}"
	  # {["先生", 4]=>{[1, 0, 1]=>{[7, 1, 1]=>[["甲状腺结节3级", 1]]}, [2, 0, 2]=>{[11, 2, 1]=>[["甲状腺结节3级", 2]]}, [3, 0, 1]=>{[3, 1, 1]=>[["甲状腺结节3级", 1]]}, [4, 1, 1]=>{[4, 1, 1]=>[["意外险可以直接投保", 1]]}}, ["太太", 4]=>{[1, 0, 1]=>{[6, 1, 1]=>[["可以直接投保", 1]]}, [2, 0, 1]=>{[2, 1, 1]=>[["可以直接投保", 1]]}, [3, 0, 1]=>{[3, 1, 1]=>[["可以直接投保", 1]]}, [4, 1, 1]=>{[4, 1, 1]=>[["意外险可以直接投保", 1]]}}, ["大宝", 5]=>{[2, 0, 7]=>{[2, 7, 1]=>[["脑血管瘤", 7]], [13, 7, 1]=>[["脑血管瘤", 7]]}, [3, 0, 7]=>{[3, 7, 1]=>[["脑血管瘤", 7]], [5, 7, 1]=>[["脑血管瘤", 7]]}, [4, 1, 1]=>{[15, 1, 1]=>[["意外险可以直接投保", 1]]}}}
	  # {"先生":[["寿险","擎天柱3号优选版","150万","交20年保到60岁","1.等待期90天 \n2.等期待内身故/全残保险金：返还所交保险费 \n3.等待期后身故/全残保险金：基本保险金额","选择优选版就可以，胸疼检查没有异常就无碍，健康告知也没有限制体重和脂肪肝。附加项选择被保人豁免","2637.11"],["重疾险","健康保","50万","交30年保到70岁","1.等待期90天 2.等期待内身故/全残保险金：返还所交保险费 3.等待期后身故/全残保险金：基本保险金额","选择优选版就可以，胸疼检查没有异常就无碍，健康告知也没有限制体重和脂肪肝。附加项选择被保人豁免","2637.11"],["意外险","擎天柱3号优选版","50万","1年","1.等待期90天 2.等期待内身故/全残保险金：返还所交保险费 3.等待期后身故/全残保险金：基本保险金额","选择优选版就可以，胸疼检查没有异常就无碍，健康告知也没有限制体重和脂肪肝。附加项选择被保人豁免","2637.11"]],"太太":[["寿险","擎天柱3号优选版","150万","交20年保到60岁","1.等待期90天 2.等期待内身故/全残保险金：返还所交保险费 3.等待期后身故/全残保险金：基本保险金额","选择优选版就可以，胸疼检查没有异常就无碍，健康告知也没有限制体重和脂肪肝。附加项选择被保人豁免","2637.11"],["重疾险","健康保","50万","交30年保到70岁","1.等待期90天 2.等期待内身故/全残保险金：返还所交保险费 3.等待期后身故/全残保险金：基本保险金额","选择优选版就可以，胸疼检查没有异常就无碍，健康告知也没有限制体重和脂肪肝。附加项选择被保人豁免","2637.11"],["意外险","擎天柱3号优选版","50万","1年","1.等待期90天 2.等期待内身故/全残保险金：返还所交保险费 3.等待期后身故/全残保险金：基本保险金额","选择优选版就可以，胸疼检查没有异常就无碍，健康告知也没有限制体重和脂肪肝。附加项选择被保人豁免","2637.11"]],"大宝":[["寿险","擎天柱3号优选版","150万","交20年保到60岁","1.等待期90天 2.等期待内身故/全残保险金：返还所交保险费 3.等待期后身故/全残保险金：基本保险金额","选择优选版就可以，胸疼检查没有异常就无碍，健康告知也没有限制体重和脂肪肝。附加项选择被保人豁免","2637.11"],["重疾险","健康保","50万","交30年保到70岁","1.等待期90天 2.等期待内身故/全残保险金：返还所交保险费 3.等待期后身故/全残保险金：基本保险金额","选择优选版就可以，胸疼检查没有异常就无碍，健康告知也没有限制体重和脂肪肝。附加项选择被保人豁免","2637.11"],["意外险","擎天柱3号优选版","50万","1年","1.等待期90天 2.等期待内身故/全残保险金：返还所交保险费 3.等待期后身故/全残保险金：基本保险金额","选择优选版就可以，胸疼检查没有异常就无碍，健康告知也没有限制体重和脂肪肝。附加项选择被保人豁免","2637.11"]]}
	  # 最终保存的形式
	  data = {}
	  hash.each do |col1,arr1|
	  	# Rails.logger.info "=============@hash=========#{hash}"
	  	data[col1[0]] = []
	  	arr1.each do |product_type,ins|
	  		col2 = ApplicationController.get_product_type(product_type[0])
	  		ins.each do |id_rank,ins_rank|
	  			ins_rank.each do |arr|
	  				Rails.logger.info "==ins_rank=========#{ins_rank}"
		  			insurance = Insurance.find(id_rank[0])
		  			#保险名称
		  			col3 = "#{insurance.factory}\n#{insurance.name}"
		  			#保险责任
		  			col6 = insurance.note
		  			#备注
		  			col7 = arr[2]
		  			fee = 0.0
		  			year = 0
		  			if product_type[0] == 1 && col1[0] == "先生"
		  				a = man_income/(man_income+woman_income)*amount
		  				fee = ("%.1f" % (a/100)).to_f * 100
		  				if fee > 300
		  					fee = 300
		  				elsif fee > 0
		  					fee = fee
		  				end
		  				year = 60
		  			elsif product_type[0] == 1 && col1[0] == "太太"
		  				a = woman_income/(man_income+woman_income)*amount
		  				fee = ("%.1f" % (a/100)).to_f * 100
		  				if fee > 300
		  					fee = 300
		  				elsif fee > 0
		  					fee = fee
		  				end
		  				year = 60
		  			elsif product_type[0] == 2 
		  				fee = 50
		  				year = 70
		  			elsif product_type[0] == 3
		  				if id_rank[0]==18
		  					fee = 300
		  				else
		  					fee = 200
		  				end
		  				if id_rank[0]==3 || id_rank[0]==5
		  				  year = 6
		  				else
		  					year = 1
		  				end
		  			elsif product_type[0] == 4
		  				if col1[2] < 10
		  					fee = 20
		  				else
		  					fee = 50
		  				end
		  				year = 1
		  			end
		  			col4 = "#{fee}万"
		  			jf_year,jf_sum,year15 = Rate.get_rate(product_type[0],id_rank[0],fee,col1[2],col1[3],man_income+woman_income)
		  			if year15 != 0
		  				year = year15
		  			end
		  			if year <=30
		  				col5 = "交#{jf_year}年保#{year}年"
		  			elsif year == 106
		  				col5 = "交#{jf_year}年保到终身"
		  			else
		  				col5 = "交#{jf_year}年保到#{year}岁"
		  			end
		  			#费用
		  			col8 = "%.2f" % jf_sum
		  			#疾病
		  			if arr[0].to_s =~ /\d{1,}/
              col9 = Ill.find(arr[0]).name
            else
              col9 = arr[0]
            end
		  			Rails.logger.info "====col9=======#{col9}"
		  			data[col1[0]] << [col2,col3,col4,col5,col6,col7,col8,col9]
		  		end
	  		end
	  	end
	  end
	  Rails.logger.info "====data=======#{data}"
	  file = File.open("#{Rails.root}/public/file/保险信息.txt","w")
		file.write(data.to_s.gsub("=>",":").gsub("nil","\"\""))
		file.close
  	# redirect_to "/show_information"
  end

  def new_note
  	@ins_id = params[:ins_id]
  	@ins = Insurance.find(@ins_id)
  	@ill_id = params[:ill_id]
  	@ill = Ill.find(@ill_id)
  	@note = Note.new(insurance_id:@ins_id,ill_id:@ill_id)
  end

   #添加备注
  def add_note
  	@note = Note.new
  	@insurances = Insurance.where(status:0)
  	@ills = Ill.all
  end

  def create_note
  	insurance_id = params[:insurance_id].blank?? params[:note][:insurance_id] : params[:insurance_id]
  	ill_id = params[:ill_id].blank?? params[:note][:ill_id] : params[:ill_id]
  	rank = params[:rank]
  	note = params[:note][:note]
  	Rails.logger.info "====insurance_id=====#{insurance_id}========"
  	@note = Note.find_or_create_by(insurance_id:insurance_id,ill_id:ill_id)
  	@note.rank = rank
  	@note.note = note
  	@note.save

  	redirect_to "/add_note", notice: "添加成功"
  end

  def search_product
  	ill_name = params[:name]
  	Rails.logger.info("===输入的名称=======#{ill_name}")
  	@ills = Ill.where("name like '%#{ill_name}%'")
  	Rails.logger.info("====@ills.ids======#{@ills.ids}")
  end
end
