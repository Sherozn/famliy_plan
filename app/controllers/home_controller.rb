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
	  arrs = []
	  hash = {}
	  sheet.each_row_streaming(offset: 7) do |rows|
	  	flag_member = rows[0]
	  	if !flag_member.blank? && flag_member != @member
	  		if !arrs.blank?
	  			Rails.logger.info "=====@member===#{@member}"
    			Rails.logger.info "===arrs=======#{arrs}====="
    			product_types = ApplicationController.get_product_types(man_income,woman_income,@member.to_s.strip)
    			Rails.logger.info "===product_types=======#{product_types}====="
    			notes = Note.get_note(arrs,product_types)
    			hash[@member.to_s] = notes
    			Rails.logger.info "====hash=======#{hash}"
    		end
  			arrs = [] 
  			arrs << rows[7].value if rows[7] && rows[7].value
  			@member = flag_member
  		else
  			arrs << rows[7].value if rows[7] && rows[7].value
  		end
	  end
  	redirect_to :root
  end
end
