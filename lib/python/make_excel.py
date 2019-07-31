# -*- coding: utf-8 -*-
"""
Created on Mon Sep 03 18:28:56 2018
@purpose: 从广发证券指标库的webservice接口取数
@Version:1.0 初始版本
         1.1 解决import lxml后使用lxml.etree报no attribute 'etree'的问题
         2.0 处理xml命名空间；对返回的xml做过滤，只保存<return>tag的text
"""
import xlwt
import sys
reload(sys)
sys.setdefaultencoding('utf-8')

class QueryResult:
    def __init__(self,data):
        # style = xlwt.XFStyle()#格式信息
        # font = xlwt.Font()#字体基本设置
        # font.name = u'微软雅黑'
        # font.color = 'black'
        # font.height= 220 #字体大小，220就是11号字体，大概就是11*20得来的吧
        # style.font = font
        # pattern = xlwt.Pattern() # Create the Pattern
        # pattern.pattern = xlwt.Pattern.SOLID_PATTERN # May be: NO_PATTERN, SOLID_PATTERN, or 0x00 through 0x12
        # pattern.pattern_fore_colour = 5
        # style.pattern = pattern
        # style0 = xlwt.easyxf('alignment: horz center,vert center;font: name 宋体, color-index black,bold on,height 280;pattern: pattern solid, fore_colour dark_green_ega;align: wrap on; ')
        wb = xlwt.Workbook()
        ws = wb.add_sheet('sheet1')
        



        for i in range(9):
            ws.col(i).width = 256 * 20
        # ws.col(0).width = 256 * 20
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
        style4 = xlwt.easyxf('border: left thin,left_colour 0x40,right thin, right_colour 0x40,top thin,top_colour 0x40,bottom thin,bottom_colour 0x40; font: name Microsoft YaHei, color-index black, height 220; pattern: pattern solid; alignment: horz center,vert center;align: wrap on;',num_format_str='#,##0.00')
        arr = [u"家庭成员" ,u"险种" , u"产品" , u"保额" , u"缴费年限" , u"保险责任", u"备注" , u"保费/年", u"总保费/年", u"保险链接"]
        for index,col_name in enumerate(arr):
            ws.write(1,index,col_name,style1)

        row = 2
        exec("data="+data)
        for (member,value) in data.items():
            ws.write_merge(row, row+len(value), 0, 0, unicode(str(member), 'utf-8'), style2)
            for items in value:
                row += 1
                for index,item in enumerate(items):
                    print(item)
                    if(index == 0):
                        ws.write(row-1,index+1,unicode(str(item), 'utf-8'),style3)
                    else:
                        ws.write(row-1,index+1,unicode(str(item), 'utf-8'),style4)
                    
                    


        # exec("data="+data)
        # print(data)
        # 
        # for (member,value) in data.items():
        #     if(int(member[0]) == 1):
        #         str1 = u"先生"
        #     elif(int(member[0]) == 2):
        #         str1 = u"太太"
        #     elif(int(member[0]) == 3):
        #         str1 = u"大宝"
        #     elif(int(member[0]) == 4):
        #         str1 = u"小宝"
        #     elif(int(member[0]) == 5):
        #         str1 = u"男方父亲"
        #     elif(int(member[0]) == 6):
        #         str1 = u"男方母亲"
        #     elif(int(member[0]) == 7):
        #         str1 = u"女方父亲"
        #     elif(int(member[0]) == 8):
        #         str1 = u"女方母亲"
        #     ws.write_merge(row, row+int(member[1]), 0, 0, str1, style2)
        #     row += int(member[1])
            # print(member)
            # print(value)
            # for (product_type,ins) in value.items():
            #     print(product_type)
            #     print(ins)
            #     for (id_rank,ins_rank) in value.items():
            #         print(id_rank)
            #         print(ins_rank)
                    # for item in ins_rank:
                        # ws.write(2,0,str(item),style0)

        
        # ws.write(2,0,data,style0)

        ws.write_merge(0, 0, 0, 9, u'家庭保障清单', style0)

        wb.save('/vagrant/famliy_plan/public/test.xlsx')

            
if __name__=='__main__':
    # data = sys.argv[1]
    f = open("/vagrant/famliy_plan/public/保险信息.txt","r")
    fr = f.read()
    print(fr)
    # exec("data1="+fr)
    gquery=QueryResult(fr)
    
    #保存结果
    # f=open("wsResult1.txt","w")
    # f.write(qr)
    # f.close()