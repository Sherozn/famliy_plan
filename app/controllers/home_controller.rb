class HomeController < ApplicationController
  def index
  	path = "/vagrant/famliy_plan/public/家庭保障方案.xlsx"
  	xls = Roo::Excelx.new path
  	sheet = xls.sheet(2)
    sheet.each_with_index do |arr, j|
    	if j==2
    		sheet.row(j)[6] = "你好"
    		p arr[6]
    	end
    end
    # book.write path
  end

  # array = (%x{cd lib/python/ && python make_excel.py})
  # array = (%x{cd lib/python/ && python gf_api.py "#{appKey}" "#{userID}" "#{indexName}"})
  def derive
  	name = `ls public/file | grep "家庭"`
  	path = "#{Rails.root}/public/file/#{name.strip}"
  	Rails.logger.info "===path===#{path}"
		file = File.open(path)
		data = file.read
  	hash = eval(data)
  	file.close
  	array = (%x{cd lib/python/ && python make_excel.py "#{hash}"})


  	 #  	path = receive_email.email_path
    # filename = receive_email.subject
    # send_file path, :type=>"application/octet-stream;charset=utf-8", :filename => "#{filename}", disposition: 'attachment'
  end

  def import_information

  end

  def create_information
  	ori_file = params[:file].original_filename
	  xlsx = Roo::Spreadsheet.open(params[:file])
	  sheet = xlsx.sheet(0)
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
	  arrs = []
	  hash = {}
	  sheet.each_row_streaming(offset: 7) do |rows|
	  	flag_member = rows[0]
	  	
	  	if !flag_member.blank? 

	  		if flag_member != @member
		  		if !arrs.blank?  
	    			product_types = ApplicationController.get_product_types(man_income,woman_income,@member.to_s.strip)
	    			Rails.logger.info "=====@member===#{@member}"
			  		age = ApplicationController.get_age(birth)
			  		Rails.logger.info "===age======#{age}====="
	    			# Rails.logger.info "===product_types=======#{product_types}====="
	    			notes_arr = Note.get_note(arrs,product_types,age)
	    			hash[[@member.to_s,notes_arr[1]]] = notes_arr[0]
	    		end
	  			arrs = [] 
	  			arrs << rows[7].value if rows[7] && rows[7].value
	  			@member = flag_member
	  			birth = rows[3].to_s
	  		end
  		else
  			arrs << rows[7].value if rows[7] && rows[7].value
  		end
	  end
	  @hash = hash
	  file = File.open("#{Rails.root}/public/file/#{ori_file}（未确认）.txt","w")
	  Rails.logger.info "====hash=======#{hash}"
		file.write(hash)
		file.close
  	# redirect_to "/show_information"
  end

  def new_note
  	@ins_id = params[:ins_id]
  	@ins = Insurance.find(@ins_id)
  	@name = params[:name]
  	@note = Note.new(insurance_id:@ins_id,name:@name)
  end

  def create_note
  	insurance_id = params[:note][:insurance_id]
  	name = params[:note][:name]
  	note = params[:note][:note]
  	rank = params[:rank]
  	@note = Note.find_or_create_by(insurance_id:insurance_id,name:name)
  	@note.rank = rank
  	@note.note = note
  	@note.save

  	redirect_to "/new_note/#{params[:note][:insurance_id]}/#{params[:note][:name]}" , notice: "添加成功"
  end
end
