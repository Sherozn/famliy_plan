# -*- coding: utf-8 -*-
"""
Created on Mon Sep 03 18:28:56 2018
@purpose: 从广发证券指标库的webservice接口取数
@Version:1.0 初始版本
         1.1 解决import lxml后使用lxml.etree报no attribute 'etree'的问题
         2.0 处理xml命名空间；对返回的xml做过滤，只保存<return>tag的text
"""
import xlwt
import os, sys
from PIL import Image
reload(sys)
sys.setdefaultencoding('utf-8')

class QueryResult:
    def __init__(self,data):
        # style0 = xlwt.easyxf('alignment: horz center,vert center;font: name 宋体, color-index black,bold on,height 280;pattern: pattern solid, fore_colour dark_green_ega;align: wrap on; ')
        wb = xlwt.Workbook()
        ws = wb.add_sheet(u'3、家庭保障规划',cell_overwrite_ok=True)
        ws.col(0).width=256*12 
        ws.col(1).width=256*10
        ws.col(2).width=256*18
        ws.col(3).width=256*10
        ws.col(4).width=256*18
        ws.col(5).width=256*36
        ws.col(6).width=256*36
        ws.col(7).width=256*12
        ws.col(8).width=256*13
        ws.col(9).width=256*25

        # s = "123"
        # im = Image.open('%s' % os.path.join(os.getcwd(), 'index.jpg')).convert("RGB")
        # im.save('gaitubao_123_bmp.bmp')
        # ws.write(2,9,u'=H3+H4')


        xlwt.add_palette_colour("colour0", 0x21)
        wb.set_colour_RGB(0x21, 33, 27, 14)
        xlwt.add_palette_colour("colour1", 13)
        wb.set_colour_RGB(13, 118, 96, 50)
        xlwt.add_palette_colour("colour2", 10)
        wb.set_colour_RGB(10, 201, 179, 131)
        xlwt.add_palette_colour("colour3", 12)
        wb.set_colour_RGB(12, 228, 217, 192)
        style0 = xlwt.easyxf('border: left thin,left_colour 0x40,right thin, right_colour 0x40,top thin,top_colour 0x40,bottom thin,bottom_colour 0x40; font: name Microsoft YaHei, color-index white, bold on, height 360; pattern: pattern solid, fore_colour colour0;alignment: horz center,vert center;',num_format_str='#,##0.00')
        style1 = xlwt.easyxf('border: left thin,left_colour 0x40,right thin, right_colour 0x40,top thin,top_colour 0x40,bottom thin,bottom_colour 0x40; font: name Microsoft YaHei, color-index white, bold on, height 280; pattern: pattern solid, fore_colour colour1;alignment: horz center,vert center;',num_format_str='#,##0.00')
        style2 = xlwt.easyxf('border: left thin,left_colour 0x40,right thin, right_colour 0x40,top thin,top_colour 0x40,bottom thin,bottom_colour 0x40; font: name Microsoft YaHei, color-index black, bold on, height 220; pattern: pattern solid, fore_colour colour2;alignment: horz center,vert center;',num_format_str='#,##0.00')
        style3 = xlwt.easyxf('border: left thin,left_colour 0x40,right thin, right_colour 0x40,top thin,top_colour 0x40,bottom thin,bottom_colour 0x40; font: name Microsoft YaHei, color-index black, bold on, height 220; pattern: pattern solid, fore_colour colour3;alignment: horz center,vert center;',num_format_str='#,##0.00')
        style4 = xlwt.easyxf('border: left thin,left_colour 0x40,right thin, right_colour 0x40,top thin,top_colour 0x40,bottom thin,bottom_colour 0x40; font: name Microsoft YaHei, color-index black, height 220; pattern: pattern solid; alignment: horz left,vert center;align: wrap on;',num_format_str='#,##0.00')
        style5 = xlwt.easyxf('border: left thin,left_colour 0x40,right thin, right_colour 0x40,top thin,top_colour 0x40,bottom thin,bottom_colour 0x40; font: name Microsoft YaHei, color-index black, height 220; pattern: pattern solid; alignment: horz center,vert center;align: wrap on;',num_format_str='#,##0.00')
        arr = [u"家庭成员" ,u"险种" , u"产品" , u"保额" , u"缴费年限" , u"保险责任", u"备注" , u"保费/年", u"总保费/年", u"保险链接"]
        for index,col_name in enumerate(arr):
            ws.write(1,index,col_name,style1)

        row = 2
        exec("data="+data)
        sum = 0.0
        nn = u"\n\n\n\n\n\n\n\n\n"
        # 家庭成员级别
       
        for (member,value) in data.items():
            items_no = 0
            init_row = row
            
            sum_fee = 0.0
            # items是每一个疾病对应的数组，比如：["寿险", "华贵保险\n大麦正青春", "10.0万", "交30年保到60岁", "1.等待期90天\n2.保费递增型，保费按每年3%的比例增长\n3.等待期后身故/全残保险金：基本保险金额", "", "43.00", "甲状腺结节（无明确分级）"]
            # 保险名称初始化
            ins_str = ""
            # 备注的序号
            ii = 1
            # 每一列的初始值
            col1,col2,col3,col4,col5,col6,col7 = "","","","","","",""
            # 备注的总和
            issues = ""
            flag = 0
            for i,items in enumerate(value):
                items_no += 1
                #是否合并单元格的标志
                flag = 0
                # item是最低一级数组的每一项，就比如寿险、10.0万
                # 如果现在数组中的保险名称发生了变化，说明现在应该合并了
                if(items[1] != ins_str):
                    ins_str = items[1]
                    flag = 1
                    
                #说明已经到了下一个保险了
                if(flag == 1 and items_no != 1):
                    if(row != 1):
                        for ind in [1,2,3,4,5,6,7]:
                            if(ind == 1):
                                ws.write(row,1,unicode(str(col1), 'utf-8'),style4)
                            elif(ind == 6):
                                ws.write(row,6,unicode(str(col6), 'utf-8'),style4)
                            else:
                                col_name = "col" + str(ind)
                                ws.write(row,ind,unicode(str(eval(col_name)), 'utf-8'),style4)
                        ii = 1
                        issues = ""
                    row += 1
               
                for index,item in enumerate(items): 
                    if(index == 6):
                        sum_fee += float(item)
                    elif(index == 7):
                        if(items[5] == ""):
                            items[5] = "健康告知没有限制到，可以正常投保"
                        issues = issues + str(ii)+ u'、' + item + ":" + items[5] + u";\n"
                        ii += 1

                    if(index == 0):
                        col1 = item
                    elif(index == 1):
                        col2 = item
                    elif(index == 2):
                        col3 = item
                    elif(index == 3):
                        col4 = item
                    elif(index == 4):
                        col5 = item
                    elif(index == 6):
                        col7 = item
                    elif(index == 7 and items[0] != u"意外险"):
                        col6 = issues
                    elif(index == 7 and items[0] == u"意外险"):
                        col6 = item
                        # eval(col_name) = item

                
                # ws.write(row+i, 10, nn)

            if(flag == 1):
                for ind in [1,2,3,4,5,6,7]:
                    if(ind == 1):
                        ws.write(row,1,unicode(str(col1), 'utf-8'),style4)
                    elif(ind == 6):
                        ws.write(row,6,unicode(str(col6), 'utf-8'),style4)
                    else:
                        col_name = "col" + str(ind)
                        ws.write(row,ind,unicode(str(eval(col_name)), 'utf-8'),style4)
                row += 1
            sum += sum_fee
            ws.write_merge(init_row, row-1, 0, 0, unicode(str(member), 'utf-8'), style2)
            ws.write_merge(init_row, row-1, 8, 8, unicode(str(sum_fee), 'utf-8'), style3)
            ws.write_merge(row, row, 0, 9, u'', style1)    
                    
        ws.write_merge(0, 0, 0, 9, u'家庭保障清单', style0)
        ws.write(row+1,0,u'合计',style0)
        ws.write_merge(row+1,row+1,1,6,u'',style0)
        ws.write(row+1,9,u'',style0)

        ws.write_merge(row+1,row+1,7,8,unicode(str(sum), 'utf-8'),style0)
        path = "/vagrant/famliy_plan/public/1力哥理财家庭保障规划.xlsx"
        wb.save(path)

            
if __name__=='__main__':
    f = open("/vagrant/famliy_plan/public/file/保险信息.txt","r")
    fr = f.read()
    gquery=QueryResult(fr)
