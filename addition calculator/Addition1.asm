;�ӷ�������ʵ�֣�
;1�������û�����
;2������DOS�жϽ�������뵽���뻺����INPUT_BUFF
;3��ͨ����������INPUT_BUFF�ԼӺŷָ�ΪINPUT_A��INPUT_B������Ӧ������
;4��ͨ��ջ������A��B����ʵ�ֵ�λ��ǰ����λ�ں��Է�������
;5����A��B���ֽ�Ϊ��λ��ÿ���ֽڴ洢һ�����֣���Ӳ�����OUT_NUM������
;6�����OUT_NUM
DATAS SEGMENT
    ;�˴��������ݶδ���  
    ;�����û�������ַ���
    SENTENCE1 DB "INPUT A + B :$"
    ;�س��ַ�
    CRLF DB 0AH,0DH
    	 DB "$"
   	;�����ַ���������
   	INPUT_BUFF DB 80
   			   DB ?
   			   DB 80 DUP(?)
   			   
   	OUT_NUM    DB 80
   			   DB ?
   			   DB 80 DUP(0)
DATAS ENDS
EXTRAS SEGMENT
   	INPUT_A	   DB 78
   			   DB ?
   			   DB 78 DUP(0)
   	INPUT_B    DB 78
   			   DB ?
   			   DB 78 DUP(0)
EXTRAS ENDS
STACKS SEGMENT
    ;�˴������ջ�δ���
    
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS,ES:EXTRAS
START:
    MOV AX,DATAS
    MOV DS,AX
    MOV AX,EXTRAS
    MOV ES,AX
    ;�˴��������δ���
    LEA DX,SENTENCE1	;�����û�����
    MOV AH,09H
    INT 21H
    
    LEA DX,CRLF			;�س�
    MOV AH,09H
    INT 21H				
    
    LEA DX,INPUT_BUFF	;�����ַ�������
    MOV AH,0AH
    INT 21H
    
    LEA DX,CRLF			;�س�
    MOV AH,09H
    INT 21H	
    
    XOR CX,CX			;���cx���������ַ����ܳ��ȴ���cx
    MOV CL,INPUT_BUFF+1
	
	LEA SI,INPUT_BUFF+2	;���ô�������ַ
	LEA DI,INPUT_A+2
	XOR BX,BX
	AGAIN:LODSB			;������,���Ӻ�ǰ���������
		CMP AL,'+'
		JZ CHANGE_TO_B
		ADD BL,1
		SUB AL,30H
		STOSB	
		JMP NEXT1
		
	CHANGE_TO_B:
		LEA DI,INPUT_B+2
		MOV INPUT_A+1,BL
		XOR BX,BX
	NEXT1:
		LOOP AGAIN
	MOV INPUT_B+1,BL	;��INPUT_A+1��INPUT_B+1�д����Ӧ�ĳ���
	;��INPUT_A����洢
	XOR CX,CX
	XOR AX,AX
	MOV CL,INPUT_A+1
	LEA BX,INPUT_A+2
	;��ջA
AGAIN2:
	MOV AL,ES:[BX]
	PUSH AX
	INC BX
	LOOP AGAIN2
	
	XOR CX,CX
	MOV CL,INPUT_A+1
	LEA BX,INPUT_A+2
	;��ջA
AGAIN3:
	POP AX
	MOV ES:[BX],AL
	INC BX
	LOOP AGAIN3

	XOR CX,CX
	XOR AX,AX
	MOV CL,INPUT_B+1
	LEA BX,INPUT_B+2
	;��ջB
AGAIN5:
	MOV AL,ES:[BX]
	PUSH AX
	INC BX
	LOOP AGAIN5
	;��ջB
	XOR CX,CX
	MOV CL,INPUT_B+1
	LEA BX,INPUT_B+2
AGAIN6:
	POP AX
	MOV ES:[BX],AL
	INC BX
	LOOP AGAIN6
	;�ҳ�A��B�ϳ��ĳ���
	XOR CX,CX
	MOV AL,INPUT_A+1
	MOV BL,INPUT_B+1
	CMP AL,BL
	JA A_IS_ABOVE
	MOV CL,BL
	JMP NEXT2
A_IS_ABOVE:	
	MOV CL,AL
NEXT2:
	MOV DX,CX
	INC CX
	LEA BX,OUT_NUM+2
	LEA DI,INPUT_A+2
	LEA SI,INPUT_B+2
	XOR AX,AX
	;ִ�мӷ�����
AGAIN8:
	MOV BYTE PTR AL,ES:[DI]
	MOV BYTE PTR AH,ES:[SI]
	ADD AL,AH
	CMP AL,9
	JA NEED_CARRY
	JMP NEXT3
NEED_CARRY:
	INC DI
	INC BYTE PTR ES:[DI]
	DEC DI
	SUB AL,10
NEXT3:
	MOV BYTE PTR [BX],AL
	INC BX
	INC DI
	INC SI
	LOOP AGAIN8
	;�ж��������
	MOV BX,DX
	MOV BYTE PTR AL,OUT_NUM[BX]+2
	CMP AL,0
	JA NEED_INC_DX
	JMP NEXT4
NEED_INC_DX:
	INC DX
NEXT4:
	MOV OUT_NUM+1,DL
	;������
	MOV CL,OUT_NUM+1
	LEA BX,OUT_NUM+2
	ADD BX,CX
	DEC BX
	MOV AH,02H
AGAIN9:
	MOV DL,DS:[BX]
	ADD DL,'0'
	DEC BX
	INT 21H
	LOOP AGAIN9

    MOV AH,4CH
    INT 21H
CODES ENDS
    END START

