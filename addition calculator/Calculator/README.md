# 加减乘除法计算器实现：  
1，提醒用户输入
2，调用DOS中断将输入存入到输入缓冲区INPUT_BUFF
3，将INPUT_BUFF以运算符分割为INPUT_A与INPUT_B两个对应缓冲区
4，调用子程序将字符串INPUT_A和INPUT_B转化为二进制数字A和B存储于十六位寄存器中
5，根据运算符进行加减乘除法运算，将结果C存储于AX中
6，调用子程序将二进制数字C转化为字符串输出