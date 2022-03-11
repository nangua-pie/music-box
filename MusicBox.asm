IOY1 EQU 0640H
IOY3 EQU 06C0H
MY8255_A EQU IOY1+00H        ;8255并口A端口地址
MY8255_MODE EQU IOY1+06H     ;8255控制寄存器端口地址
MY8254_COUNT0 EQU IOY3+00H   ;8254计数器0端口地址
MY8254_MODE	EQU IOY3+06H     ;8254控制寄存器端口地址

DATA SEGMENT
    FREQ_ONE DW 661,990,990,882,786,786
		      DW 742,786,882,882,786,1484,1322
		      DW 661,990,990,882,786,786
		      DW 742,786,882,882,1178,882,1049,990
		      DW 661,990,990,882,786,786
		      DW 742,786,882,882,786,1484,1322
		      DW 661,742,786,786,742,661,589
		      DW 589,661,742,786,589,742,661,0
    TIME_ONE  DB 4,4,4,4,4,4
              DB 3,3,4,4,4,4,4
              DB 4,4,4,4,4,4
              DB 3,3,4,4,4,4,4
              DB 4,4,4,4,4,4
              DB 3,3,4,4,4,4,4
              DB 4,4,4,4,4,4,4
              DB 4,4,4,4,4,4,4,2

    FREQ_TWO DW 661,990,882,1178,661,990,882,1178
              DW 661,990,882,1322,661,990,882,1322
              DW 661,990,882,1178,661,990,882,1178
              DW 661,990,882,1322,661,990,882,1322
              DW 661,660,661,660,661,742,786
              DW 661,660,661,660,661,742,786
              DW 786,882,991,990,1049,991,990,882,882,0
    TIME_TWO  DB 4,4,4,4,4,4,4,4
              DB 4,4,4,4,4,4,4,4
              DB 4,4,4,4,4,4,4,4
              DB 4,4,4,4,4,4,4,4
              DB 4,4,4,4,4,4,4
              DB 4,4,4,4,4,4,4
              DW 4,4,4,4,4,4,4,4,2

    FREQ_THREE DW 882,742,589,495,882,742,589,742,589,742
                DW 661,589,589,661,589,525,589,525
                DW 589,589,742,441,495,525
                DW 882,742,589,495,882,742,589,742,589,742
                DW 661,589,589,661,589,525,589,525
                DW 589,589,742,882,990,1049,0
    TIME_THREE DB 3,2,2,2,2,2,2,3,3,3
               DB 3,2,2,2,2,2,2,3
               DB 3,2,2,2,2,3
               DB 3,2,2,2,2,2,2,3,3,3
               DB 3,2,2,2,2,2,2,3
               DB 3,2,2,2,2,3,1

    FREQ_FOUR DW 330,371,416,330
                
              DW 416,441,495
              DW 495,556,495,441,416,330
              DW 495,556,495,441,416,330
              DW 330,248,330
              DW 330,248,330,0
    TIME_FOUR DB 4,4,4,4
              DB 4,4,4,4
              DB 4,4,8
              DB 4,4,8
              DB 2,2,2,2,4,4
              DB 2,2,2,2,4,4
              DB 4,4,8
              DB 4,4,8

    MENU_LINES DB 0DH,0AH,'-----------------Music Box-----------------'
               DB 0DH,0AH,'1.'
               DB 0DH,0AH,'2.'
               DB 0DH,0AH,'3.'
               DB 0DH,0AH,'4.'
               DB 0DH,0AH,'-------------------------------------------'
               DB '$'
    SELECT_LINES DB 0DH,0AH,'Select Music NO.'
                 DB '$'
    PLAY_TAG DB 00H
DATA ENDS

STACK SEGMENT STACK
    DW 256 DUP(?)
STACK ENDS

CODE SEGMENT
ASSUME DS:DATA,SS:STACK,CS:CODE
START:
    INIT PROC
        MOV AX,DATA
        MOV DS,AX
        MOV DX,MY8254_MODE    ;初始化8254
        MOV AL,36H
        OUT DX,AL
        MOV DX,MY8255_MODE    ;初始化8255
        MOV AL,90H
        OUT DX,AL
        PUSH DS               ;初始化8259
        MOV AX,0000H
        MOV DS,AX
        MOV AX,OFFSET PAUSE
        MOV SI,003CH
        MOV [SI],AX
        MOV AX,CS
        MOV SI,003EH
        MOV [SI],AX
        MOV AX,OFFSET SWITCH_MUSIC
        MOV SI,00C4H
        MOV [SI],AX
        MOV AX,CS
        MOV SI,00C6H
        MOV [SI],AX
        CLI
        POP DS
        MOV AL,11H
        OUT 20H,AL
        MOV AL,08H
        OUT 21H,AL
        MOV AL,04H
        OUT 21H,AL
        MOV AL,01H
        OUT 21H,AL
        MOV AL,11H
        OUT 0A0H,AL
        MOV AL,30H
        OUT 0A1H,AL
        MOV AL,02H
        OUT 0A1H,AL
        MOV AL,01H
        OUT 0A1H,AL
        MOV AL,0FDH
        OUT 0A1H,AL
        MOV AL,6BH
        OUT 21H,AL
        STI
        JMP END_INIT
        PAUSE:
            MOV DL,PLAY_TAG
            NOT DL
            MOV PLAY_TAG,DL
            MOV AL,20H
            OUT 20H,AL
            IRET
        SWITCH_MUSIC:
            CALL SELECT
            MOV AL,20H
            OUT 0A0H,AL
            OUT 20H,AL
            IRET
    END_INIT:
        RET
    INIT ENDP


    MAIN PROC    ;主程序
    BEGIN:
        LEA DX,MENU_LINES
        MOV AH,09H
        INT 21H
        CALL SELECT
        CALL PLAY
        JMP BEGIN
    DONE:
        MOV AH,4CH
        INT 21H
    MAIN ENDP

    SELECT PROC    ;选择曲目子程序
        LEA DX,SELECT_LINES
        MOV AH,09H
        INT 21H
        MOV DX,MY8255_A
        IN AL,DX
        CMP AL,00H
        JZ ONE
        CMP AL,01H
        JZ TWO
        CMP AL,02H
        JZ THREE
        CMP AL,03H
        JZ FOUR
        ONE:
            LEA SI,FREQ_ONE
            LEA DI,TIME_ONE
            JMP SELECT_END
        TWO:
            LEA SI,FREQ_TWO
            LEA DI,TIME_TWO
            JMP SELECT_END
        THREE:
            LEA SI,FREQ_THREE
            LEA DI,TIME_THREE
            JMP END_SELECT
        FOUR:
            LEA SI,FREQ_FOUR
            LEA DI,TIME_FOUR
    END_SELECT:
        OR AL,30H
        INT 10H
        RET
    SELECT ENDP

    PLAY PROC    ;演奏子程序
        MOV AH,1
        INT 16H
        JZ NEXT
        CMP AL,'Q'
        JZ NEAR PTR DONE
        CMP AL,'q'
        JZ NEAR PTR DONE
    NEXT:
        MOV DL,PLAY_TAG
        CMP DL,00H
        JZ PLAY
        MOV DX,0FH
        MOV AX,4240H
        DIV WORD PTR [SI]
        MOV DX,MY8254_COUNT0
        OUT DX,AL    ;装入数据初值
        MOV AL,AH
        OUT DX,AL
        MOV DL,[DI]    ;取出演奏相对时间，调用延时子程序
        CALL DALLY
        ADD SI,2
        INC DI
        CMP WORD PTR [SI],0    ;判断是否到曲末？
        JE END_PLAY
        JMP PLAY
    END_PLAY:
        RET
    PLAY ENDP

    DALLY PROC   ;延时子程序
    D0: MOV CX,0010H
    D1: MOV AX,0F00H
    D2: DEC AX
        JNZ D2
        LOOP D1
        DEC DL
        JNZ D0
        RET
    DALLY ENDP
CODE ENDS
    END START