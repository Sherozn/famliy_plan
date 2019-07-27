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
  	# xls = Roo::Excelx.new path
  	# sheet = xls.sheet(0)
   #  sheet.each_with_index do |arr, j|
   Rails.logger.info "=====params[:file]===#{params[:file]}"
  	 xlsx = Roo::Spreadsheet.open(params[:file])
  	 colname = xlsx.sheet(0).row(1)
  	 Rails.logger.info "=====colname===#{colname}"

  end
end
