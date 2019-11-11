;本程序及相关工程开源于Github:
;https://github.com/w1oves/AssemblyStudy.git
;概览：程序第二版，支持加法、减法、乘法、除法，通过字符串转数字后对数字运算依次相加完成
;具体实现方法：
;1，提醒用户输入
;2，调用DOS中断将输入存入到输入缓冲区INPUT_BUFF
;3，将INPUT_BUFF以运算符分割为INPUT_A与INPUT_B两个对应缓冲区
;4，调用子程序将字符串INPUT_A和INPUT_B转化为二进制数字A和B存储于十六位寄存器中
;5，根据运算符进行加减乘除法运算，将结果C存储于AX中
;6，调用子程序将二进制数字C转化为字符串输出
DATAS SEGMENT
    ;此处输入数据段代码  
	;输出结果缓冲区
   	OUT_STRING   DB 80
   				 DB ?
   				 DB 80 DUP('0')
   	;提醒用户输入的字符串
    SENTENCE1 DB "INPUT A + B :$"
    ;回车字符
    CRLF DB 0AH,0DH
    	 DB "$"
   	;输入字符串缓冲区
   	INPUT_BUFF DB 80
   			   DB ?
   			   DB 80 DUP(?)
   	INPUT_A	   DB 78
   			   DB ?
   			   DB 78 DUP(0)
   	INPUT_B    DB 78
   			   DB ?
   			   DB 78 DUP(0)
    ;输出数字结果
   	NUM_A      DW 0
	;加减乘除功能选择标志
   	FLAG       DB 0  ;1-ADD,2-SUB,3-MUL,4-DIV
DATAS ENDS

STACKS SEGMENT
    ;此处输入堆栈段代码
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    ;此处输入代码段代码
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;主程序;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	LEA DX,SENTENCE1	;提醒用户输入
    MOV AH,09H
    INT 21H
    
    LEA DX,CRLF			;回车
    MOV AH,09H
    INT 21H				
    
    LEA DX,INPUT_BUFF	;输入字符串缓存
    MOV AH,0AH
    INT 21H
    
    LEA DX,CRLF			;回车
    MOV AH,09H
    INT 21H	
    
    XOR CX,CX			;清空cx并将输入字符串总长度存入cx
    MOV CL,INPUT_BUFF+1
	
	LEA SI,INPUT_BUFF+2	;设置串操作地址
	LEA DI,INPUT_A+2
	XOR BX,BX
	AGAIN:			;串操作,将运算符前后的数分离并识别运算符
		MOV AL,DS:[SI]
		CMP AL,'+'
		JZ FLAG_ADD
		CMP AL,'-'
		JZ FLAG_SUB
		CMP AL,'*'
		JZ FLAG_MUL
		CMP AL,'/'
		JZ FLAG_DIV
		ADD BL,1
		MOV DS:[DI],AL
		
		JMP NEXT1
	FLAG_ADD:
		MOV BYTE PTR FLAG,1H
		JMP CHANGE_TO_B
	FLAG_SUB:
		MOV BYTE PTR FLAG,2H
		JMP CHANGE_TO_B
	FLAG_MUL:
		MOV BYTE PTR FLAG,3H
		JMP CHANGE_TO_B
	FLAG_DIV:
		MOV BYTE PTR FLAG,4H
		JMP CHANGE_TO_B
		
	CHANGE_TO_B:
		MOV BYTE PTR DS:[DI],24H
		LEA DI,INPUT_B+1
		MOV INPUT_A+1,BL
		XOR BX,BX
	NEXT1:
		INC DI
		INC SI
		LOOP AGAIN
	MOV INPUT_B+1,BL	;在INPUT_A+1和INPUT_B+1中存入对应的长度
	;在B字符串后面补'$'
    MOV BL,INPUT_B+1
    MOV BYTE PTR INPUT_B+2[BX],24H
    ;将INPUT_A字符串转数字存储到NUM_A中
    LEA BX,INPUT_A+2
    CALL STRING_TO_NUM
    MOV NUM_A,AX
	;将INPUT_B字符串转数字存储到CX中
    LEA BX,INPUT_B+2
    CALL STRING_TO_NUM
    MOV CX,AX
    ;根据flag运算符进行对应运算
    MOV AX,NUM_A
    MOV BL,FLAG
    CMP BL,1H
    JZ TOADD
    CMP BL,2H
    JZ TOSUB
    CMP BL,3H
    JZ TOMUL
    CMP BL,4H
    JZ TODIV
TOADD:
    ADD AX,CX
    JMP NEXT2
TOSUB:
	SUB AX,CX
	JMP NEXT2
TOMUL:
    MUL CX
    JMP NEXT2
TODIV:
	XOR DX,DX
	DIV CX
	JMP NEXT2
	;将结果转化为字符串并输出	
NEXT2:
    LEA BX,OUT_STRING
    CALL NUM_TO_STRING
    
    LEA DX,OUT_STRING+2
    MOV AH,09H
    INT 21H
    
    MOV AH,4CH
    INT 21H
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;子程序：STRING_TO_NUM;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;入口参数：BX:数字字符串地址，字符串要求以‘$’结尾的无符号数，大小为0-65536,存储在数据段
;出口参数：AX:转换后的数字
;程序效果：字符串转数字
STRING_TO_NUM PROC
	XOR AX,AX
	XOR CX,CX
	XOR DX,DX
AGAIN_S_1:
	MOV DL,[BX]
	
	INC BX
	CMP DL,'$'
	JZ STRING_TO_NUM_END
	
	MOV CX,AX
	;完成乘10操作
	SAL AX,1
	SAL AX,1
	SAL AX,1
	ADD AX,CX
	ADD AX,CX
	;加上当前数字
	SUB DL,'0'
	ADD AX,DX
	JMP AGAIN_S_1
STRING_TO_NUM_END:	RET
STRING_TO_NUM ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;子程序：NUM_TO_STRING;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;入口参数：BX:输出字符串缓冲区地址，要求格式:
;		      首字节：最大长度
;             第二字节：实际长度
;             其余字节：内容
;          AX:待转换数字：0-65535的无符号数
;出口参数：无
;程序效果：数字转字符串
;          在1[BX]填入字符串长度
;          在2[BX]及之后填入字符串
;          字符串以‘$’结尾	
NUM_TO_STRING PROC
	MOV CX,0024H   ;MOV CX,'$'
	PUSH CX
	XOR DX,DX
	MOV CX,0AH
;该循环实现将十位数的每一位进行入栈的功能，通过入栈与出栈完成逆序
AGAIN_N_1:
	XOR DX,DX
	MOV CX,0AH
	DIV CX
	ADD DX,30H     ;ADD DX,'0'
	PUSH DX
	CMP AX,0
	JZ NEXT_N_1
	JMP AGAIN_N_1
NEXT_N_1:
	XOR AX,AX
	MOV DI,2
;将栈内数据输出为字符串
AGAIN_N_2:
	POP AX
	MOV BYTE PTR [DI][BX],AL
	INC DI
	CMP AX,24H
	JZ NEXT_N_2
	JMP AGAIN_N_2
NEXT_N_2:
	SUB DI,2
	MOV CX,DI
	MOV BYTE PTR 1[BX],CL
NUM_TO_STRING_END:	RET
NUM_TO_STRING ENDP

CODES ENDS
    END START
