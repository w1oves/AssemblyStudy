;��������ع��̿�Դ��Github:
;https://github.com/w1oves/AssemblyStudy.git
;����������ڶ��棬֧�ּӷ����������˷���������ͨ���ַ���ת���ֺ��������������������
;����ʵ�ַ�����
;1�������û�����
;2������DOS�жϽ�������뵽���뻺����INPUT_BUFF
;3����INPUT_BUFF��������ָ�ΪINPUT_A��INPUT_B������Ӧ������
;4�������ӳ����ַ���INPUT_A��INPUT_Bת��Ϊ����������A��B�洢��ʮ��λ�Ĵ�����
;5��������������мӼ��˳������㣬�����C�洢��AX��
;6�������ӳ��򽫶���������Cת��Ϊ�ַ������
DATAS SEGMENT
    ;�˴��������ݶδ���  
	;������������
   	OUT_STRING   DB 80
   				 DB ?
   				 DB 80 DUP('0')
   	;�����û�������ַ���
    SENTENCE1 DB "INPUT A + B :$"
    ;�س��ַ�
    CRLF DB 0AH,0DH
    	 DB "$"
   	;�����ַ���������
   	INPUT_BUFF DB 80
   			   DB ?
   			   DB 80 DUP(?)
   	INPUT_A	   DB 78
   			   DB ?
   			   DB 78 DUP(0)
   	INPUT_B    DB 78
   			   DB ?
   			   DB 78 DUP(0)
    ;������ֽ��
   	NUM_A      DW 0
	;�Ӽ��˳�����ѡ���־
   	FLAG       DB 0  ;1-ADD,2-SUB,3-MUL,4-DIV
DATAS ENDS

STACKS SEGMENT
    ;�˴������ջ�δ���
STACKS ENDS

CODES SEGMENT
    ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
    MOV AX,DATAS
    MOV DS,AX
    ;�˴��������δ���
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;������;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	AGAIN:			;������,�������ǰ��������벢ʶ�������
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
	MOV INPUT_B+1,BL	;��INPUT_A+1��INPUT_B+1�д����Ӧ�ĳ���
	;��B�ַ������油'$'
    MOV BL,INPUT_B+1
    MOV BYTE PTR INPUT_B+2[BX],24H
    ;��INPUT_A�ַ���ת���ִ洢��NUM_A��
    LEA BX,INPUT_A+2
    CALL STRING_TO_NUM
    MOV NUM_A,AX
	;��INPUT_B�ַ���ת���ִ洢��CX��
    LEA BX,INPUT_B+2
    CALL STRING_TO_NUM
    MOV CX,AX
    ;����flag��������ж�Ӧ����
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
	;�����ת��Ϊ�ַ��������	
NEXT2:
    LEA BX,OUT_STRING
    CALL NUM_TO_STRING
    
    LEA DX,OUT_STRING+2
    MOV AH,09H
    INT 21H
    
    MOV AH,4CH
    INT 21H
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;�ӳ���STRING_TO_NUM;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;��ڲ�����BX:�����ַ�����ַ���ַ���Ҫ���ԡ�$����β���޷���������СΪ0-65536,�洢�����ݶ�
;���ڲ�����AX:ת���������
;����Ч�����ַ���ת����
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
	;��ɳ�10����
	SAL AX,1
	SAL AX,1
	SAL AX,1
	ADD AX,CX
	ADD AX,CX
	;���ϵ�ǰ����
	SUB DL,'0'
	ADD AX,DX
	JMP AGAIN_S_1
STRING_TO_NUM_END:	RET
STRING_TO_NUM ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;�ӳ���NUM_TO_STRING;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;��ڲ�����BX:����ַ�����������ַ��Ҫ���ʽ:
;		      ���ֽڣ���󳤶�
;             �ڶ��ֽڣ�ʵ�ʳ���
;             �����ֽڣ�����
;          AX:��ת�����֣�0-65535���޷�����
;���ڲ�������
;����Ч��������ת�ַ���
;          ��1[BX]�����ַ�������
;          ��2[BX]��֮�������ַ���
;          �ַ����ԡ�$����β	
NUM_TO_STRING PROC
	MOV CX,0024H   ;MOV CX,'$'
	PUSH CX
	XOR DX,DX
	MOV CX,0AH
;��ѭ��ʵ�ֽ�ʮλ����ÿһλ������ջ�Ĺ��ܣ�ͨ����ջ���ջ�������
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
;��ջ���������Ϊ�ַ���
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
