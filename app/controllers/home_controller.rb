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

  def import_information

  end

  def create_information
	  xlsx = Roo::Spreadsheet.open(params[:file])
	  sheet = xlsx.sheet(0)
	  # 月开支
	  month_expenses = sheet.row(2)[7].to_f
	  # 房贷
		mortgage = sheet.row(3)[7].to_f
		# 车贷
	  car_loans = sheet.row(4)[7].to_f
		# 其他负债
	  other_loans = sheet.row(5)[7].to_f
	  # 家庭流动资产
	  current_assets = sheet.row(2)[9].to_f
	  # 父母赡养费用
	  parents_support = sheet.row(3)[9].to_f
	  # 子母教育费用
	  children_education = sheet.row(4)[9].to_f

	  amount = month_expenses * 12 * 5 + mortgage + car_loans + other_loans + parents_support + children_education - current_assets

	  Rails.logger.info "=====amount===#{amount}"



	  # 通过处理这些信息，我需要计算家庭责任，读取先生太太的年收入来计算寿险的比例
	  # 读取疾病信息，然后根据疾病去匹配
	  @member = nil
	  man_income = 0.0
	  woman_income = 0.0
	  arrs = []
	  sheet.each_row_streaming(offset: 7) do |rows|

	  	flag_member = rows[0]
	  	if !flag_member.blank? && flag_member != @member
	  		if !arrs.blank?
	  			Rails.logger.info "=====@member===#{@member}"
    			Rails.logger.info "===arrs=======#{arrs}====="
    			Note.get_note(arrs)
    		end
  			arrs = [] 
  			arrs << rows[8].value if rows[8] && rows[8].value
  			@member = flag_member
  		else
  			arrs << rows[8].value if rows[8] && rows[8].value
  		end	
  		
			

	  end
  	redirect_to :root
  end
end
