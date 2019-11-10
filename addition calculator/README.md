# 加法计数器实现：  
1，提醒用户输入  
2，调用DOS中断将输入存入到输入缓冲区INPUT_BUFF  
3，通过串操作将INPUT_BUFF以加号分割为INPUT_A与INPUT_B两个对应缓冲区  
4，通过栈操作将A、B倒序，实现低位在前，高位在后以方便运算  
5，将A与B按字节相加并存入OUT_NUM缓冲区  
6，输出OUT_NUM  
