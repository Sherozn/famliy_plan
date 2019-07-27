class Insurance < ApplicationRecord
	# product_type 产品类型    1寿险  2重疾险  3医疗险  4意外险
	# platform 平台 0齐欣  1小雨伞 2微信 3支付宝  4其他

	# 无重复最长字符串
	# Insurance.get_chomp

	# 扫描到一个疾病，我先到备注表里面去找这个疾病，找到了就直接用结果，然后备注
	# 找不到，就在备注表里面创建这个疾病，然后记录下这个疾病的情况

	# 比如胆结石这个疾病，循环寿险，根据rank等级排序
	# 搜索备注表，相应的寿险没有这个疾病，创建node，然后先找寿险，根据rank等级过寿险的健康告知，
	# 先过擎天柱3号优选版（rank为5），再过擎天柱3号标准版（rank为4），再过爱相随（rank为3）
	# 再过大麦（rank为2），大麦保险有智能核保，看看智能核保是否能通过，只能核保先人工看一下

	# 过保险，是先过保险的健康告知，首先将健康告知全部输出，
	# 再搜索健康告知与疾病之间的交集，将交集赋值
	# 返回消息  与擎天柱3号优选版进行比较，交集为【胆，结，石】，没有智能核保，不建议投保。
	# 	      与擎天柱3号标准版进行比较，交集为【】，建议投保
	# ========请输入你的建议：
	# ========1、投保（循环结束）
	# ========2、不投保（循环继续）
	# ========3、进入智能核保
	# ========4、跳过
	# （进入智能核保，在disease表中搜索，找到包含胆结石的疾病，然后根据表中的内容去选择得出结论）
	# 你好，我也可以

	# ========请输入你的理由：
	# 对胆结石没有限制，可以直接投保
	# 或者对胆结石有限制，没有智能核保，不能选择擎天柱3号

	# 将疾病、保险id、保险类型、备注保存到Note表中，下次可以直接用

	# 比如甲状腺结节这个疾病，找到适合投保的重疾险。
	# 先计算表格里面的家庭收入，如果家庭收入超过30万，遍历多次赔付型的重疾。否则遍历单次赔付型的重疾
	# 先过健康保2.0，搜索备注表，健康保没有对应这个疾病，创建node
	# 返回消息  与超级玛丽旗舰版进行比较，交集为【头,痛】，不建议投保。
	# 	      与擎天柱3号标准版进行比较，交集为【】，建议投保
	# ========请输入你的建议：
	# ========1、投保（循环结束）
	# ========2、不投保（循环继续）
	# ========3、进入智能核保
	# ========4、跳过
	# （进入智能核保，在disease表中搜索，找到包含胆结石的疾病，然后根据表中的内容去选择得出结论）

	# ========请输入你的理由：
	# 对胆结石没有限制，可以直接投保
	# 或者对胆结石有限制，没有智能核保，不能选择擎天柱3号

	# node 
	# 甲状腺结节（已手术切除）    备注：如果已手术切除结节且治愈超过半年以上，术后病理结果为良性，无相关后遗症且甲状腺B超、甲状腺功能检查结果均正常可以投保
	# 甲状腺结节1、2级          备注：半年内做过甲状腺超声检查，超级玛丽旗舰版承保结果为标准体承保；如果半年内没有做过超声检查，需要做完超声检查后再投保。
	# 甲状腺结节3级             备注：半年内做过甲状腺超声检查，超级玛丽旗舰版承保结果为除外承保；如果半年内没有做过超声检查，需要做完超声检查后再投保。
	# 甲状腺结节0、4级及以上     备注：超级玛丽旗舰版不能投保
	# 甲状腺结节（无明确分级）    备注：半年内做过甲状腺超声检查，同时满足：（1）结节最大直径不超过1.5厘米，（2）边界光滑或清晰，（3）无颈部淋巴结肿大可以投保；如果半年内没有做过超声检查，需要做完超声检查后再投保。



	def self.get_chomp
		Rails.logger.info "是否进行"
		request = gets.chomp

		if request == "writer"
		  puts request
		elsif request == "press"
		  puts request
		elsif request == "date"
		  puts request
		end
	end

	# Insurance.get_dis
	def self.get_dis
		path = "/vagrant/famliy_plan/public/家庭保障规划信息收集模板.xlsx"
  	xls = Roo::Excelx.new path
  	sheet = xls.sheet(0)
  	member = nil
    sheet.each_with_index do |arr, index|
    	if !arr[0].blank?
    		member = arr[0]
    	end

    	if index > 5 && !arr[8].blank?
    		dis = arr[8].to_s.strip
    		Rails.logger.info "===dis======#{dis}====="
    		Insurance.get_note(dis)
    	end
    end
	end

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
    		Rails.logger.info "===arrs=======#{arrs}====="
    		Rails.logger.info "===dis=======#{dis.name}====="
    		Disease.make_dis(arrs,dis)
    	end
    end

	# 获得疾病的核保结果
	# dis = "甲状腺结节3级"
	def self.get_note(dis)
		if Node.exists?(name: dis)
		end
		#创建note，如果创建时有相关疾病，创建你的，我也可以输入相关疾病

	end
		
	# def length_of_longest_substring(s)
	#     slideWindow = Hash.new
	# 	startIndex = 0
	# 	endIndex = 0
	# 	ans = 0
	# 	while startIndex < s.length and endIndex < s.length
	# 		char = s[endIndex]
	# 		if  slideWindow.has_key?(char)
	# 			startIndex = [startIndex, slideWindow[char]].max
	# 		end
	# 		endIndex = endIndex + 1
	# 		ans = [ans, endIndex - startIndex].max
	# 		slideWindow[char] = endIndex
	# 	end
	# 	return ans
	# end
end
