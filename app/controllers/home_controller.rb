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
	  month_expenses = sheet.row(1)[2]
	  # 房贷
		mortgage = sheet.row(2)[2]
		# 车贷
	  car_loans = sheet.row(3)[2]
	  # 家庭流动资产
	  current_assets = sheet.row(1)[4]
	  # 父母赡养费用
	  parents_support = sheet.row(2)[4]
	  # 子母教育费用
	  children_education = sheet.row(3)[4]

	  sheet.each do |rows|
    
	 	  Rails.logger.info "=====rows===#{rows}"
	  end
  	 

  end
end
