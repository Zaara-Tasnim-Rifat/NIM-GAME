.MODEL SMALL
.STACK 100H

.DATA

X DW 0
Y DW 0
;NUMBER OF STICKS
N1 DW 0
N2 DW 0
N3 DW 0
N4 DW 0
;total number of sticks
T DW 0
;
FLAG DW 0
L DW 0

NIMSUM DW 0
;to store the row number
R DW 0
;GAME OVER MARKER
OVER DW 0
;to store row (random move)
ROW DB 0

TURN DW 0   ;0 means starting position,1 =user ,2=PC


;NAME
PL DB 10 DUP(0),'$'
CHAR DB 0
PROMPT DB "ENTER YOUR NAME: (<10)"
PROMPT2 DB "PRESS ANY KEY TO CONTINUE..."
NAMESIZE DW 0

;FILE
FILE1 DB "NIM.txt",0
HANDLE DW 0
SC DB ",SCORE:"
WINCOUNT DB 0
          DB 0DH,0AH
NIM DB "NIM"
WIN DB "WIN"  
TY DB ",THANK YOU !!$"

NO_NAME DB "ANONYMOUS"        
.CODE

MAIN PROC
    MOV AX,@DATA
    MOV DS,AX
    MOV ES,AX
    
    CALL NAME_
    
    ;SET GRAPHICS MODE
    MOV AX,5H
    INT 10H
    
    ;PAGE SELECTION
    MOV AH,5
    MOV AL,0    ;select page 0
    INT 10H
    
    ;select background color
    MOV AH,0BH
    MOV BH,0    ;SET BACKGROUND
    MOV BL,1111B ;BACKGROUND LIGHT BLUE
    INT 10H
    
    ;SELECT PALLETE
    MOV AH,0BH
    MOV BH,1    ;SET PALLET
    MOV BL,0    ;PALLET NO.
    INT 10H


    CALL FIXED 
NEW_GAME:
    
    CALL STICKDRAW 
    ;A FUNCTION MUST BE WRITTEN ,THAT RESTORE ALL THE INITIAL VALUES OF THE GAME
   ;N1=1,N2=3,N3=5,N4=7
  ; ARRAY CHANGE KORA LAGBE NA MAY BE
  ;
    CALL INIT_
    
;MOUSE POINTER

;INITIALIZE
    
  MOV AX,0
    INT 33H
    
    MOV AX,1
    INT 33H 
   
 
;;;#########new game ,close window ,pc mode button DETECTION CODE##########   


GAME:
 CLICK_:
 CALL POINTER_
 ;mov ax,cx        
 ;call print_ax
 
 ;CLOSE BUTTON DETECTION 
 XOR AX,AX
 CALL CLOSE_DET
 CMP AX,3
 JE CLOSE_OFR
 
 XOR AX,AX
 CALL NEWGAME_DET
 CMP AX,2
 JE NEW_GAME
 
 ;#1: if pcmove==1 && (turn==2 || TURN==0) then jmp pc_
 ;#2: if pcmove==1 && turn ==1 then jmp click_
 ;#3: if pcmove!=1 && (turn ==1 || TURN==0) then jmp B  **DONE!
 ;#4: if pcmove!=1 && turn ==2 then click_ **DONE!
 XOR AX,AX
 CALL PC_MOVE_DET
 CMP AX,1
 JNE B
 CMP TURN,1 ;#2
 JE CLICK_
 
 JMP PC_            ;;THERE CAN BE A PROBLEM .WAIT A SECOND.okay go :D
;;;ROW BUTTONS DETECTION

B:
    CMP TURN,2      ;actually there shouldnt be turn 2,becoz it is just beginning or it
    JE CLICK_       ;will be handled by b_1,b_2,b_3,b_4 functions
    
    CMP CX,470
    JL CLICK_  
    CMP CX,545
    JG CLICK_
    CMP DX,22
    JL CLICK_ ; INVALID,there is nothing upward 
    CMP DX,114
    JG CLICK_
    
    ;BUTTON1 DETECTION
    
B1:
    CMP DX,22
    JL B2
    CMP DX,42
    JG B2
    ;NO STICK LEFT
    CMP N1,0
    JE CLICK_
    
    
    CALL B_1
    
    ;if close is clicked!!!
    CMP AX,3
    JE CLOSE_OFR
    
    ;CHECK IF NEWGAME IS CLICKED
    
    CMP AX,2
    JE NG_OUT_OF_RANGE
    
    
     CMP OVER,1    ;THIS TWO LINE SHOULD BE RESTORED!!!!!!!!!!LOOK AT HERE!!!!##
     JE OH_NO_OFR
    
    JMP PC_
    ;MOV X,49     ;to prove that it really works!!
    ;CALL SHOW
  
   ;BUTTON2 DETECTION 
   CLOSE_OFR:
JMP CLOSE_IT 
B2:             
    
   ; mov ax,cx        
   ; call print_ax
    CMP DX,46
    JL B3
    CMP DX,66
    JG B3
    
    ;NO STICK LEFT
    
    CMP N2,0
    JE CLICK_2
    
   
    CALL B_2
    
    ;if close is clicked!!!
    CMP AX,3
    JE CLOSE_OFR
    
    ;CHECK IF NEWGAME IS CLICKED
    CMP AX,2
    JE NG_OUT_OF_RANGE
    
    CMP OVER,1
    JE OH_NO_OFR
    
    JMP PC_
    ;MOV X,50     ;to prove that it really works!!
    ;NEW_GAME OUT OF RANGE 

 
;ANOTHER CLICK_2 BECOZ ,OTHERWISE IT GOES OUT OF RANGE
CLICK_2:
  CALL POINTER_
  ;IF NEWGAME IS CLICKED
   XOR AX,AX
  CALL NEWGAME_DET
  CMP AX,2
  JE NG_OUT_OF_RANGE
  
  ;***
   JMP B            
   ;BUTTON3 DETECTION 
OH_NO_OFR:
    JMP OH_NO 
    
NG_OUT_OF_RANGE:
    JMP NEW_GAME    
B3:
    
    CMP DX,70
    JL B4
    CMP DX,91
    JG B4
    ;MOV X,51     ;to prove that it really works!!
    ;CALL SHOW
    CMP N3,0
    JE CLICK_2
    
   
    CALL B_3
    
    ;if close is clicked!!!
    CMP AX,3
    JE CLOSE_IT
    
    ;CHECK IF NEWGAME IS CLICKED
    CMP AX,2
    JE NG_OUT_OF_RANGE
    
    CMP OVER,1                ;game over
    JE OH_NO
    
    JMP PC_
    ;JMP OH_NO

   ;BUTTON4 DETECTION

B4:
 
    CMP DX,94
    JL CLICK_2
    CMP DX,114
    JG CLICK_2      ;THIS MEANS, THIS IS USER'S TURN ,BUT HE/SHE HAS CLICKED ANUTHING ELSE
    ;MOV X,52     ;to prove that it really works!!
    ;CALL SHOW
    
    CMP N4,0
    JE CLICK_2
    
    CALL B_4
    
    ;if close is clicked!!!
    CMP AX,3
    JE CLOSE_IT
    
    ;CHECK IF NEWGAME IS CLICKED
    CMP AX,2
    JE NG_OUT_OF_RANGE
    
    CMP OVER,1
    JE OH_NO
    
    JMP PC_
    ;JMP OH_NO

    PC_:
    ;change the turn 
    MOV TURN,1
    ;now i have to calculate the nim sum
    CALL NIMSUM_    ;NIM SUM IS IN AX
    CMP AX,0
    JNE PCOPT
;PC RAND
    CALL PC_RAND
    ;mov ax,19        
    ;  call print_ax
    JMP LOOP_OR_OVER    
PCOPT:
    CALL PC_OPT 
    
    
    ;check whether the game is over or not
LOOP_OR_OVER:    
    CMP OVER,1
    JE OH_NO
    
    JMP GAME
    
   ;;;;THIS SEGMENT IS PRINTING THE POSITION OF WHERE MOUSE HAS BEEN CLICKED!!! 
       ;mov ax,19        
       ;call print_ax    ;row value will bE printed.To get COLUMN value,use cx instead!
   
   ;##################;;
   
   
   ;JMP POINTER
   OH_NO:
   CALL POINTER_
   
   ;CHECK IF NEWGAME IS CLICKED
   CALL NEWGAME_DET
    CMP AX,2
    JE NG_OUT_OF_RANGE
    ;CHECK IF CLOSE IS  CLICKED!!
   CALL CLOSE_DET
   CMP AX,3
   JE CLOSE_IT
   JMP OH_NO 
   
   ;mov ax,dx        
   ;call print_ax 
    
    ;READ KEYBOARD
    MOV AH,0
    INT 16H    
 CLOSE_IT: 
    MOV AL,WINCOUNT
    ADD AL,'0'
    MOV WINCOUNT,AL
    CALL FILE
;SET TO TEXT MODE
   MOV AX,3
   INT 10H
    
   ;THANK YOU!!!
   ;MOV AH,1
   ; INT 16
   
   
   LEA DX,PL
   MOV AH,9 
   INT 21H
   LEA DX,TY
   INT 21H
   
;RETURN TO DOS
    MOV AH,4CH
    INT 21H
    
    ret
    MAIN ENDP
   ;*********************************************************
   ;procedures :D

FILE PROC
    MOV AH,3DH
    LEA DX,FILE1
    MOV AL,1
    INT 21H
    MOV HANDLE,AX
    
    ;MOVE FILE POINTER
    MOV AH,42H
    MOV BX,HANDLE
    XOR CX,CX
    XOR DX,DX
    MOV AL,2
    INT 21H
    
    ;WRITE
    MOV BX,HANDLE
    MOV AH,40H
    MOV CX,NAMESIZE
    LEA DX,PL
    INT 21H
    

    MOV AH,40H
    MOV CX,10
    LEA DX,SC
    INT 21H
    RET
    FILE ENDP
    
LOGO_ PROC
    MOV DH,4            ;fix the row
    MOV BP,OFFSET NIM
    MOV CX,3            ;string length
    CALL SHOWLOGO
    MOV DH,5            ;fix the row
    MOV BP,OFFSET WIN
    CALL SHOWLOGO
    
    MOV AL,3
    MOV CX,130
    MOV DX,25
    CALL LOGO_BOX
    MOV CX,180
    MOV DX,25
    CALL LOGO_BOX
    MOV CX,130
    MOV DX,25
    MOV BX,50
    MOV L,BX
    CALL HORZLINE_2
    MOV CX,130
    MOV DX,55
    MOV BX,50
    MOV L,BX
    CALL HORZLINE_2
    
    RET 
    LOGO_ ENDP
NAME_ PROC
   ;SET GRAPHICS MODE
    MOV AX,5H
    INT 10H
    
    ;PAGE SELECTION
    MOV AH,5
    MOV AL,0    ;select page 0
    INT 10H
    
    ;select background color
    MOV AH,0BH
    MOV BH,0    ;SET BACKGROUND
    MOV BL,0B ;BACKGROUND LIGHT BLUE
    INT 10H
    
    ;SHOW LOGO
    
    CALL LOGO_
    
    ;SELECT PALLETE
    MOV AH,0BH
    MOV BH,1    ;SET PALLET
    MOV BL,1    ;PALLET NO.
    INT 10H
    
DISPLAY_PROMPT:
    MOV AL,1
    MOV BH,0
    MOV BL,00011110B
    MOV CX,22 
    MOV DH,9       ;ROW NUMBER
    MOV DL,9     ;COLUMN NUMBER
    MOV BP,OFFSET PROMPT                   ;###IM WORKING HERE
    MOV AH,13H
    INT 10H

    ;INPUT BOX
    
    ;LEFT VERTICAL 
    MOV CX,105    ;COLUMN NUMBER
    MOV DX,90
    CALL STICK
    ;box draw
;RIGHT VERTICAL    
    MOV CX,220    ;COLUMN NUMBER
    MOV DX,90     ;ROW NUMBER  
    CALL STICK
    
;UPPER HORZ
    MOV CX,105
    MOV DX,90
    MOV AX,115
    MOV L,AX   ;HORZ LINE LENGTH IS 48
    CALL HORZLINE    

;LOWER HORZ
    MOV CX,105
    MOV DX,110
    CALL HORZLINE
    
    
;NAME INPUT   
    ;NAME SIZE NAMESIZE
    LEA DI,PL
    CLD
    
    ;SHOW CURSOR
    MOV DL,15
    
    READ_:    
    MOV AH,0
    INT 16H ;AL=KEYSTROKE
    
    CMP AL,8
    JE BACK_
    CMP AL,0DH
    JE DIS_
    STOSB
    INC NAMESIZE     ;INCREMENT SIZE
    
    MOV CHAR,AL
    ;MOVE CURSOR
    
    MOV AH,2
    MOV BH,0
    MOV DH,12
    ;MOV DL,3
    INT 10H
    
    ;write char function
    MOV AH,9
    MOV AL,CHAR
    MOV BL,1
    MOV CX,1
    INT 10H
    INC DL
    JMP READ_
BACK_:
    DEC DI
    DEC DL
    MOV AH,2
    MOV BH,0
    MOV DH,12
    ;MOV DL,3
    INT 10H
    
    DEC NAMESIZE   ;
    ;write char function
    MOV AH,9
    MOV AL,0    ;0 IS NULL,SO REPLACING THE CHARACTER WITH NULL TO ERASE
    MOV BL,1
    MOV CX,1
    INT 10H
    JMP READ_
    
    
    
    

DIS_:
;checking whether name is is empty or not
    CMP PL,0
    JE NONAME_
    MOV AL,'$'
    MOV [DI],AL
    JMP CONTINUE_
    
NONAME_:
    MOV CX,10
    LEA SI,NO_NAME
    LEA DI,PL
 MOVE_:
     MOVSB
     LOOP MOVE_
     MOV NAMESIZE,9
CONTINUE_:        
;PRESS ANY KEY TO CONTINUE
    
    MOV AL,1
    MOV BH,0
    MOV BL,00000010B
    MOV CX,28 
    MOV DH,23       ;ROW NUMBER
    MOV DL,6     ;COLUMN NUMBER
    MOV BP,OFFSET PROMPT2                   ;###IM WORKING HERE
    MOV AH,13H
    INT 10H
    
   MOV AH,0
   INT 16H
    RET 
 NAME_ ENDP   

 HORZLINE_2 PROC        ;this guy draws the horizontal lines of logo box
    ;INPUT: CX,DX,L,PIXEL(AX)
    MOV AH,0CH
    MOV BX,0    ;LOOP CONTROL
    S_2:
    INT 10H
    INC CX
    INC BX
    CMP BX,L
    JLE S_2
    RET
    HORZLINE_2 ENDP
    
;shows "nim" and "win" AND "thank you"   
 SHOWLOGO PROC           
 ;input: bp points to string ,dh= row , cx= string length 
;MOVE THE CURSOR
    MOV AL,1
    MOV BH,0
    MOV BL,11111111B
   ; MOV CX,3
   ; MOV DH,3       ;ROW NUMBER
   MOV DL,18     ;COLUMN NUMBER
    ;MOV BP,OFFSET PROMPT                   ;###IM WORKING HERE
    MOV AH,13H
    INT 10H
    RET
    SHOWLOGO ENDP
LOGO_BOX PROC
    MOV AH,0CH
    MOV BX,0
    
    L_:
    INT 10H
    INC DX
    INC BX
    CMP BX,30
    JLE L_
    RET
   LOGO_BOX ENDP
   
PC_RAND PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
;randomly choose a pile and number of sticks
GET_ROW:
    MOV AH,2CH          ;GET THE TIME
    INT 21H         
    ;CH=HOUR  CL=MIN   DH=SEC
    ;choose a pile,total pile=4, so i will use dh%5 for row
    XOR AX,AX
    MOV AL,DH
    XOR DX,DX
    MOV BX,5
    DIV BX
    CMP DX,0
    JE GET_ROW
    MOV R,DX
    CMP R,1
    JE GET_STICKS_1
    CMP R,2
    JE GET_STICKS_2
    CMP R,3
    JE GET_STICKS_3
    CMP R,4
    JE GET_STICKS_4
GET_STICKS_1:
    CMP N1,0
    JE GET_ROW
    MOV R,20    ;DEFINE THE ROW
    
    MOV BX,N1
    INC BX   
    CALL RANDPC_CALC
    
    MOV BX,N1
    MOV FLAG,BX
    
    SUB N1,DX
    SUB T,DX
    JMP EXIT_RAND
    
 GET_ROW_OUTOFRANGE:     ;THE OUT OF RANGE FACT :3 :3
    JMP GET_ROW
   
    
GET_STICKS_2:
    CMP N2,0
    JE GET_ROW
    
    MOV R,45    ;DEFINE THE ROW
    
    MOV BX,N2
    INC BX   
    CALL RANDPC_CALC
    
     MOV BX,N2
    MOV FLAG,BX
    SUB N2,DX
    SUB T,DX
    JMP EXIT_RAND  
    
GET_STICKS_3:
    CMP N3,0
    JE GET_ROW_OUTOFRANGE
    
    MOV R,70    ;DEFINE THE ROW
    
    MOV BX,N3
    INC BX   
    CALL RANDPC_CALC
    
     MOV BX,N3
    MOV FLAG,BX
    
    SUB N3,DX
    SUB T,DX
    JMP EXIT_RAND
 GET_STICKS_4:
    CMP N4,0
    JE GET_ROW_OUTOFRANGE
    MOV R,95    ;DEFINE THE ROW
    
    MOV BX,N4
    INC BX 
    CALL RANDPC_CALC
    
    MOV BX,N4
    MOV FLAG,BX
    SUB N4,DX
    SUB T,DX
    JMP EXIT_RAND
 
EXIT_RAND:
;mov ax,dx        
    ;  call print_ax
    MOV BX,DX
    ERASE_PC_RAND:
    ;code to erase a stick from the pile
    MOV AX,15
    MUL FLAG           ;FLAG=N
    MOV CX,AX          ;COLUMN NUMBER
    MOV DX,R                   ;ROW NUMBER DEFINED
    DEC FLAG
    DEC BX             ;LOOP CONTROL REGISTER= NUMBER OF STICKS REMOVED
    CALL ERASE_STICK
    
    CMP BX,0
    JNLE ERASE_PC_RAND
    
    CMP T,0         ;PC WON THE MATCH
    JG RESTORE_2
    CALL PCWON_
RESTORE_2:    
    POP DX
    POP CX
    POP BX
    POP AX    
    RET
    
    
PC_RAND ENDP    
    
RANDPC_CALC PROC
;INPUT: BX= NUMBER OF STICKS
;OUTPUT: DX= NUMBER OF STICKS HAVE TO BE REMOVED
BLOOP:
    MOV AH,2CH          ;GET THE TIME
    INT 21H         
    ;CH=HOUR  CL=MIN   DH=SEC
    ;choose a pile,total pile=4, so i will use dh%5 for row
    XOR AX,AX
    MOV AL,DH
    XOR DX,DX
    ;MOV BX,N4
    DIV BX
    CMP DX,0
    JLE BLOOP
    CMP DX,BX
    JGE BLOOP
        
    RET 
RANDPC_CALC ENDP

PC_OPT PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV AX,NIMSUM
    MOV BX,N1
    XOR AX,BX
    CMP AX,BX
    JGE TWO_
    ;ELSE
    MOV R,20        ;STORE ROW
    MOV FLAG,BX     ;FLAG=N
    SUB BX,AX   ;NUMBER OF STICKS TO REMOVE
    SUB N1,BX
    SUB T,BX
    
    JMP EXITPC_
TWO_:    
    MOV AX,NIMSUM
    MOV BX,N2
    XOR AX,BX
    CMP AX,BX
    JGE THREE_
    ;ELSE
    MOV R,45
    MOV FLAG,BX     ;FLAG=N
    SUB BX,AX   ;NUMBER OF STICKS TO REMOVE
    SUB N2,BX
    SUB T,BX
    JMP EXITPC_
THREE_:
    MOV AX,NIMSUM
    MOV BX,N3
    XOR AX,BX
    CMP AX,BX
    JGE FOUR_
    ;ELSE
    MOV R,70
    MOV FLAG,BX     ;FLAG=N
    SUB BX,AX   ;NUMBER OF STICKS TO REMOVE
    SUB N3,BX
    SUB T,BX
    JMP EXITPC_

FOUR_:
    MOV AX,NIMSUM
    MOV BX,N4
    XOR AX,BX
    ;CMP AX,BX
    ;JGE TWO
    ;ELSE
    MOV R,95
    MOV FLAG,BX     ;FLAG=N
    SUB BX,AX   ;NUMBER OF STICKS TO REMOVE
    SUB N4,BX
    SUB T,BX
    ;JMP EXIT_PC
    
EXITPC_:   
    ERASE_PC:
    ;code to erase a stick from the pile
    MOV AX,15
    MUL FLAG           ;FLAG=N
    MOV CX,AX          ;COLUMN NUMBER
    MOV DX,R                   ;ROW NUMBER DEFINED
    DEC FLAG
    DEC BX             ;LOOP CONTROL REGISTER= NUMBER OF STICKS REMOVED
    CALL ERASE_STICK
    
    CMP BX,0                ;detect problem
    JNLE ERASE_PC
    
    CMP T,0         ;PC WON THE MATCH
    JG RESTORE_
    CALL PCWON_
RESTORE_:    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
    PC_OPT ENDP
    
    
PCWON_ PROC
    ;declares that pc has won
     MOV AL,1
    MOV BH,0
    MOV BL,00011110B
    MOV CX,15 
    MOV DH,2       ;ROW NUMBER
    MOV DL,90     ;COLUMN NUMBER
    PUSH CS
    POP ES
    MOV BP,OFFSET PCWIN                   ;###IM WORKING HERE
    
    MOV AH,13H
    INT 10H
    JMP PCWINEND
    PCWIN DB "SORRY! I WON :D"
    PCWINEND:   
    
    MOV OVER,1
    RET 
    PCWON_ ENDP
 
 USERWON_ PROC
    ;declares that pc has won
     MOV AL,1
    MOV BH,0
    MOV BL,00011110B
    MOV CX,17
    MOV DH,2       ;ROW NUMBER
    MOV DL,90     ;COLUMN NUMBER
    PUSH CS
    POP ES
    MOV BP,OFFSET USERWIN                   ;###IM WORKING HERE
    
    MOV AH,13H
    INT 10H
    JMP USERWINEND
    USERWIN DB "CONGRATZ!U WON :/"
    USERWINEND:   
    
    INC WINCOUNT
    MOV OVER,1
    RET 
    USERWON_ ENDP
    
BLANK_ PROC
    ;ERASES THE WIN DECARATION
     MOV AL,1
    MOV BH,0
    MOV BL,00011110B
    MOV CX,17
    MOV DH,2       ;ROW NUMBER
    MOV DL,90     ;COLUMN NUMBER
    PUSH CS
    POP ES
    MOV BP,OFFSET BLANK                   ;###IM WORKING HERE
    
    MOV AH,13H
    INT 10H
    JMP BLANKEND
    BLANK DB "                 "
    BLANKEND:   
    
    RET 
    BLANK_ ENDP 
    
NIMSUM_ PROC
    ;calculates the nim sum
    ;output: nim sum is in ax
    MOV AX,N1
    XOR AX,N2
    XOR AX,N3
    XOR AX,N4
    
    MOV NIMSUM,AX
    RET 
    NIMSUM_ ENDP
    
    
POINTER_ PROC
CLICK_3:
  mov ax,3
   int 33h
  
   MOV AX,5
   MOV BX,0
   INT 33H
   
   CMP BX,1
   JNE CLICK_3
   RET
    POINTER_ ENDP
    
;button1    
B_1 PROC
    B1_:
    CMP N1,0
    JE B1CLICK 
     ;code to erase a stick from the pile
    MOV AX,15
    MUL N1
   
    MOV CX,AX   ;COLUMN NUMBER
    MOV DX,20   ;ROW NUMBER
    DEC N1
    DEC T
    
    CALL ERASE_STICK
    ;end game or not
    CMP T,0
    JE USERWON_1
    
    
    B1CLICK:    
    CALL POINTER_
    
    ;close window detector
     XOR AX,AX
     CALL CLOSE_DET
     CMP AX,3
     JE EXIT_B1
     
    ;new game detector
     XOR AX,AX
     CALL NEWGAME_DET
     CMP AX,2
     JE EXIT_B1
    
    ;pc_move detector 
    XOR AX,AX
    CALL PC_MOVE_DET
    CMP AX,1
    JE EXIT_B1
    
    CMP CX,470
    JL B1CLICK  
    CMP CX,545
    JG B1CLICK
   CMP DX,22
   JL B1CLICK
    CMP DX,42
    JG B1CLICK
    
    JMP B1_
    
    USERWON_1:
    CALL USERWON_
      ;LEAVE A MARKER TO IDENTIFY THE GAME OVER
     
    
    EXIT_B1:
    
    RET
    B_1 ENDP

;button2
B_2 PROC
B2_:
    CMP N2,0
    JE B2CLICK 
    ;code to erase a stick from the pile
    MOV AX,15
    MUL N2
    MOV CX,AX   ;COLUMN NUMBER
    MOV DX,45   ;ROW NUMBER
    DEC N2
    DEC T
    
    CALL ERASE_STICK
    
    CMP T,0
    JE USERWON_2
    
B2CLICK:    
    CALL POINTER_
    
    ;close window detector
     XOR AX,AX
     CALL CLOSE_DET
     CMP AX,3
     JE EXIT_B2
     
    ;new game detector
     XOR AX,AX
     CALL NEWGAME_DET
     CMP AX,2
     JE EXIT_B2
    
    ;pc_move detector 
    XOR AX,AX
    CALL PC_MOVE_DET
    CMP AX,1
    JE EXIT_B2
    
    CMP CX,470
    JL B2CLICK  
    CMP CX,545
    JG B2CLICK
    CMP DX,46
    JL B2CLICK
    CMP DX,66
    JG B2CLICK
    
    JMP B2_
    USERWON_2:
    CALL USERWON_
    
    
EXIT_B2:
    
    RET
B_2 ENDP

;button 3
B_3 PROC
B3_:
    CMP N3,0
    JE B3CLICK 
    
    ;code to erase a stick from the pile
    MOV AX,15
    MUL N3
    MOV CX,AX   ;COLUMN NUMBER
    MOV DX,70   ;ROW NUMBER
    
    DEC N3
    DEC T
    
    CALL ERASE_STICK
    
    CMP T,0
    JE USERWON_3
    
    B3CLICK:    
    CALL POINTER_
    
    ;close window detector
     XOR AX,AX
     CALL CLOSE_DET
     CMP AX,3
     JE EXIT_B3
     
    ;new game detector
     XOR AX,AX
     CALL NEWGAME_DET
     CMP AX,2
     JE EXIT_B3
    
    ;pc_move detector 
    XOR AX,AX
    CALL PC_MOVE_DET
    CMP AX,1
    JE EXIT_B3
    
    CMP CX,470
    JL B3CLICK  
    CMP CX,545
    JG B3CLICK
    CMP DX,70
    JL B3CLICK
    CMP DX,91
    JG B3CLICK
    
    JMP B3_
    
    USERWON_3:
    CALL USERWON_
    
    
    EXIT_B3:
    
    RET
    B_3 ENDP

;button 4
B_4 PROC
B4_:
    CMP N4,0
    JE B4CLICK 
    
    ;code to erase a stick from the pile
    MOV AX,15
    MUL N4
    MOV Cx,AX   ;COLUMN NUMBER
    MOV DX,95   ;ROW NUMBER
    DEC N4
    DEC T
    
    CALL ERASE_STICK
    CMP T,0
    JE USERWON_4
    
    B4CLICK:    
    CALL POINTER_
    
    ;close window detector
     XOR AX,AX
     CALL CLOSE_DET
     CMP AX,3
     JE EXIT_B4
     
     ;new game detector
     XOR AX,AX
     CALL NEWGAME_DET
     CMP AX,2
     JE EXIT_B4
    
     ;PC MOVE DETECTOR
    XOR AX,AX
    CALL PC_MOVE_DET
    CMP AX,1
    JE EXIT_B4
    
    CMP CX,470
    JL B4CLICK  
    CMP CX,545
    JG B4CLICK
    CMP DX,94
    JL B4CLICK
    CMP DX,114
    JG B4CLICK
    
    JMP B4_
    USERWON_4:
    CALL USERWON_
    
    EXIT_B4:
    
    RET
    B_4 ENDP    
;************
PC_MOVE_DET PROC
    PUSH CX
    PUSH DX
    ;WRITE CODE HERE
    ;RETURN AX=1 IF PCMOVE BUTTON IS CLICKED!!
    XOR AX,AX ;CLEAR AX
    CMP CX,440  ;220X2
    JL EXIT_PC  
    CMP CX,564  ;282X2
    JG EXIT_PC
    CMP DX,145
    JL EXIT_PC
    CMP DX,165
    JG EXIT_PC
    MOV AX,1
    
EXIT_PC:
   
    POP DX
    POP CX
    RET
    PC_MOVE_DET ENDP
    
CLOSE_DET PROC
    PUSH CX
    PUSH DX
    ;WRITE CODE HERE
    ;RETURN AX=1 IF PCMOVE BUTTON IS CLICKED!!
    XOR AX,AX ;CLEAR AX
    CMP CX,262  ;131X2
    JL EXIT_C  
    CMP CX,358  ;179X2
    JG EXIT_C
    CMP DX,144
    JL EXIT_C
    CMP DX,164
    JG EXIT_C
    MOV AX,3    ;CLOSE CLICKED WHEN AX=3
    
    EXIT_C:
   
    POP DX
    POP CX
    RET
    CLOSE_DET ENDP 
 
 ;CLOSE BUTTON DETECT
NEWGAME_DET PROC
    PUSH CX
    PUSH DX
    ;WRITE CODE HERE
    ;RETURN AX=1 IF PCMOVE BUTTON IS CLICKED!!
    XOR AX,AX ;CLEAR AX
    CMP CX,40  ;20X2
    JL EXIT_PC  
    CMP CX,182  ;91X2
    JG EXIT_PC
    CMP DX,144
    JL EXIT_PC
    CMP DX,164
    JG EXIT_NG
    MOV AX,2    ;NEW GAME CLICKED WHEN AX=2
    
    EXIT_NG:
    POP DX
    POP CX
    RET
    NEWGAME_DET ENDP 

    
INIT_ PROC
    ;INITIALIZES ALL DATA FOR NEW GAME
    MOV N1,1
    MOV N2,3
    MOV N3,5
    MOV N4,7
    
    MOV T,16 ;NUMBER OF TOTAL STICKS
    MOV OVER,0
    CALL BLANK_  ;ERASE THE DECLARATION
    
    MOV TURN,0  ;ANYONE CAN START
    RET
INIT_ ENDP

    
BOX PROC NEAR
;INPUT: 

BOX ENDP

STICKDRAW PROC NEAR
   ;STICK DRAW
    ;FIRST ROW 1 STICK
    MOV AL,1
    MOV CX,15    ;COLUMN NUMBER
    MOV DX,20    ;ROW NUMBER
    CALL STICK
   
    ;SECOND ROW 3 STICKS
    MOV BX,0
    MOV AL,1
    MOV CX,15    ;COLUMN NUMBER
    MOV DX,45    ;ROW NUMBER
ROW2:    
    
    CALL STICK
    INC BX
    ADD CX,15
    CMP BX,2
    JLE ROW2

;THIRD ROW 5 STICKS
    MOV BX,0
    MOV AL,1
    MOV CX,15    ;COLUMN NUMBER
    MOV DX,70    ;ROW NUMBER
ROW3:    
    
    CALL STICK
    INC BX
    ADD CX,15
    CMP BX,4
    JLE ROW3 
 
;FOURTH ROW 7 STICKS
    MOV BX,0
    MOV AL,1
    MOV CX,15    ;COLUMN NUMBER
    MOV DX,95    ;ROW NUMBER
ROW4:    
    
    CALL STICK
    INC BX
    ADD CX,15
    CMP BX,6
    JLE ROW4   
   ret
   
    STICKDRAW ENDP 
    
STICK PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    ;INPUT: AL=PIXEL VALUE OF THE PALLETE  //LET ME CHOOSE THE COLOR FOR U EVERY TIME :)
    ;CX= COLUMN NUMBER  DX= ROW NUMBER
    ;MOV AL,1    ;PIXEL VALUE SET TO GREEN
    MOV AH,0CH
    MOV BX,0
S:
    INT 10H
    INC DX
    INC BX
    CMP BX,20
    JLE S
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
STICK ENDP    

;HORIZONTAL LINE
HORZLINE PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    ;INPUT: L=STICK LENGTH
    ;CX= COLUMN NUMBER  DX= ROW NUMBER
    MOV AL,1    ;PIXEL VALUE SET TO GREEN
    MOV AH,0CH
    MOV BX,0    ;LOOP CONTROL
S_:
    INT 10H
    INC CX
    INC BX
    CMP BX,L
    JLE S_
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
    HORZLINE ENDP

;erase function
ERASE_STICK PROC
;INPUT:  CX=COLUMN NUMBER,DX=ROW NUMBER
    MOV AL,0   ;CHOOSING BACKGROUND COLOUR
 
    CALL STICK
    
    RET
ERASE_STICK ENDP
    
    
    


;DRAW THE FIXED THINGS

FIXED PROC
;draw the buttons
    
    ;BUTTON1
    MOV AL,1
    MOV BH,0
    MOV BL,00000010B
    MOV CX,4
    MOV DH,3       ;ROW NUMBER
    MOV DL,150      ;COLUMN NUMBER
    PUSH CS
    POP ES
    MOV BP,OFFSET BUTTON1
    
    MOV AH,13H
    INT 10H
    JMP BUTTON1END
    BUTTON1 DB "ROW1"
    BUTTON1END:

;BUTTON2
    MOV AL,1
    MOV BH,0
    MOV BL,00000010B
    MOV CX,4
    MOV DH,6       ;ROW NUMBER
    MOV DL,150      ;COLUMN NUMBER
    PUSH CS
    POP ES
    MOV BP,OFFSET BUTTON2
    
    MOV AH,13H
    INT 10H
    JMP BUTTON2END
    BUTTON2 DB "ROW2"
    BUTTON2END:

    ;BUTTON3
    MOV AL,1
    MOV BH,0
    MOV BL,00000010B
    MOV CX,4
    MOV DH,9       ;ROW NUMBER
    MOV DL,150      ;COLUMN NUMBER
    PUSH CS
    POP ES
    MOV BP,OFFSET BUTTON3
    
    MOV AH,13H
    INT 10H
    JMP BUTTON3END
    BUTTON3 DB "ROW3"
    BUTTON3END:
    
;BUTTON4
    MOV AL,1
    MOV BH,0
    MOV BL,00000010B
    MOV CX,4
    MOV DH,12
    MOV DL,150
    PUSH CS
    POP ES
    MOV BP,OFFSET BUTTON4
    
    MOV AH,13H
    INT 10H
    JMP BUTTON4END
    BUTTON4 DB "ROW4"
    BUTTON4END:
    

;DRAW THE BOXES
MOV AX,38
MOV L,AX   ;HORZ LINE LENGTH IS 38

;ROW1
;LEFT VERTICAL 
    MOV CX,235    ;COLUMN NUMBER
    MOV DX,23
    CALL STICK
    
;RIGHT VERTICAL    
    MOV CX,273    ;COLUMN NUMBER
    MOV DX,23     ;ROW NUMBER  
    CALL STICK
    
;UPPER HORZ
    MOV CX,235
    MOV DX,23
    CALL HORZLINE    

;LOWER HORZ
    MOV CX,235
    MOV DX,43
    CALL HORZLINE 

;ROW2
;LEFT VERTICAL 
    MOV CX,235    ;COLUMN NUMBER
    MOV DX,46
    CALL STICK
    
;RIGHT VERTICAL    
    MOV CX,273    ;COLUMN NUMBER
    MOV DX,46     ;ROW NUMBER  
    CALL STICK
    
;UPPER HORZ
    MOV CX,235
    MOV DX,46
    CALL HORZLINE    

;LOWER HORZ
    MOV CX,235
    MOV DX,67
    CALL HORZLINE
;ROW3
;LEFT VERTICAL 
    MOV CX,235    ;COLUMN NUMBER
    MOV DX,70
    CALL STICK
    
;RIGHT VERTICAL    
    MOV CX,273    ;COLUMN NUMBER
    MOV DX,70     ;ROW NUMBER  
    CALL STICK
    
;UPPER HORZ
    MOV CX,235
    MOV DX,70
    CALL HORZLINE    

;LOWER HORZ
    MOV CX,235
    MOV DX,91
    CALL HORZLINE
    
;ROW4
;LEFT VERTICAL 
    MOV CX,235    ;COLUMN NUMBER
    MOV DX,94
    CALL STICK
    
;RIGHT VERTICAL    
    MOV CX,273    ;COLUMN NUMBER
    MOV DX,94     ;ROW NUMBER  
    CALL STICK
    
;UPPER HORZ
    MOV CX,235
    MOV DX,94
    CALL HORZLINE    

;LOWER HORZ
    MOV CX,235
    MOV DX,115
    CALL HORZLINE 

;;;#########new game ,close window ,pc mode button##########

;pc move button
    MOV AL,1
    MOV BH,0
    MOV BL,00011110B
    MOV CX,7
    MOV DH,18       ;ROW NUMBER
    MOV DL,148      ;COLUMN NUMBER
    PUSH CS
    POP ES
    MOV BP,OFFSET PCMOVE                   ;###IM WORKING HERE
    
    MOV AH,13H
    INT 10H
    JMP PCMOVEEND
    PCMOVE DB "PC MOVE"
    PCMOVEEND:
    
    ;LEFT VERTICAL 
    MOV CX,220    ;COLUMN NUMBER
    MOV DX,143
    CALL STICK
    ;box draw
;RIGHT VERTICAL    
    MOV CX,282    ;COLUMN NUMBER
    MOV DX,143     ;ROW NUMBER  
    CALL STICK
    
;UPPER HORZ
    MOV CX,220
    MOV DX,143
    MOV AX,62
    MOV L,AX   ;HORZ LINE LENGTH IS 38
    CALL HORZLINE    

;LOWER HORZ
    MOV CX,220
    MOV DX,163
    CALL HORZLINE 

;NEW GAME BUTTON
    MOV AL,1
    MOV BH,0
    MOV BL,00011110B
    MOV CX,8
    MOV DH,19       ;ROW NUMBER
    MOV DL,3      ;COLUMN NUMBER
    PUSH CS
    POP ES
    MOV BP,OFFSET NEW                   ;###IM WORKING HERE
    
    MOV AH,13H
    INT 10H
    JMP NEWEND
    NEW DB "NEW GAME"
    NEWEND:
    
    ;LEFT VERTICAL 
    MOV CX,20    ;COLUMN NUMBER
    MOV DX,144
    CALL STICK
    ;box draw
;RIGHT VERTICAL    
    MOV CX,91    ;COLUMN NUMBER
    MOV DX,144     ;ROW NUMBER  
    CALL STICK
    
;UPPER HORZ
    MOV CX,20
    MOV DX,144
    MOV AX,71
    MOV L,AX   ;HORZ LINE LENGTH IS 71
    CALL HORZLINE    

;LOWER HORZ
    MOV CX,20
    MOV DX,164
    CALL HORZLINE

;CLOSE
    MOV AL,1
    MOV BH,0
    MOV BL,00011110B
    MOV CX,5
    MOV DH,19       ;ROW NUMBER
    MOV DL,17      ;COLUMN NUMBER
    PUSH CS
    POP ES
    MOV BP,OFFSET CLOSE                   ;###IM WORKING HERE
    
    MOV AH,13H
    INT 10H
    JMP CLOSEEND
    CLOSE DB "CLOSE"
    CLOSEEND:
    
    ;LEFT VERTICAL 
    MOV CX,131    ;COLUMN NUMBER
    MOV DX,144
    CALL STICK
    ;box draw
;RIGHT VERTICAL    
    MOV CX,179    ;COLUMN NUMBER
    MOV DX,144     ;ROW NUMBER  
    CALL STICK
    
;UPPER HORZ
    MOV CX,131
    MOV DX,144
    MOV AX,48
    MOV L,AX   ;HORZ LINE LENGTH IS 48
    CALL HORZLINE    

;LOWER HORZ
    MOV CX,131
    MOV DX,164
    CALL HORZLINE
    
    RET
    FIXED ENDP

print_ax proc 
;#COPIED FROM "mouse.asm" ;this guy prints the value given in ax 
;input: ax=cx(get the column value printed),ax= dx(get the row value printed)     
cmp ax, 0
jne print_ax_r
    push ax
    mov al, '0'
    mov ah, 0eh
    int 10h
    pop ax
    ret 
print_ax_r:
    ;push all general registers
    push ax
    push bx
    push cx
    push dx
   
    ;work
    mov dx, 0
    cmp ax, 0
    je pn_done
    mov bx, 10
    div bx    
    call print_ax_r
    mov ax, dx
    add al, 30h
    mov ah, 0eh
    int 10h    
    jmp pn_done
pn_done:
;pop all general registers
    pop dx
    pop cx
    pop bx
    pop ax  
    ret  
endp    
END MAIN    
  