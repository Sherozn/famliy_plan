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
        # style0 = xlwt.easyxf('alignment: horz center,vert center;font: name 宋体, color-index black,bold on,height 280;pattern: pattern solid, fore_colour dark_green_ega;align: wrap on; ')
        wb = xlwt.Workbook()
        ws = wb.add_sheet('sheet1')
        ws.col(0).width=256*12 
        ws.col(1).width=256*10
        ws.col(2).width=256*22 
        ws.col(3).width=256*12
        ws.col(4).width=256*20
        ws.col(5).width=256*35
        ws.col(6).width=256*35
        ws.col(7).width=256*12
        ws.col(8).width=256*13
        ws.col(9).width=256*20
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
        arr = [u"家庭成员" ,u"险种" , u"产品" , u"保额" , u"缴费年限" , u"保险责任", u"备注" , u"保费/年", u"总保费/年", u"保险链接"]
        for index,col_name in enumerate(arr):
            ws.write(1,index,col_name,style1)

        row = 2
        exec("data="+data)
        for (member,value) in data.items():
            ws.write_merge(row, row+len(value)-1, 0, 0, unicode(str(member), 'utf-8'), style2)
            sum_fee = 0.0
            for i,items in enumerate(value):
                for index,item in enumerate(items):
                    # print(item)
                    if(index == 6):
                        sum_fee += float(item)
                    if(index == 0):
                        ws.write(row+i,index+1,unicode(str(item), 'utf-8'),style3)
                    else:
                        ws.write(row+i,index+1,unicode(str(item), 'utf-8'),style4)
            ws.write_merge(row, row+len(value)-1, 8, 8, unicode(str(sum_fee), 'utf-8'), style3)
            row += len(value)
                    
        ws.write_merge(0, 0, 0, 9, u'家庭保障清单', style0)
        path = "/vagrant/famliy_plan/public/test.xlsx"
        wb.save(path)
        return path

            
if __name__=='__main__':
    f = open("/vagrant/famliy_plan/public/保险信息.txt","r")
    fr = f.read()
    gquery=QueryResult(fr)
