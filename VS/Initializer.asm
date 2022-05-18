.386
.model flat,stdcall
option casemap:none

include    msgame.inc

srand  PROTO C :DWORD
rand   PROTO C 
time   PROTO C :DWORD

public Initializing
.data

Total       DWORD 0
PLACED_MINE DWORD 0
POSITION    DWORD 0
CNT         DWORD 0
TOTOAL_SCALE DWORD 0
.code

Initializing   proc
    LOCAL ROW: DWORD
    LOCAL COLUMN: DWORD
    LOCAL ROW_MAX: DWORD
    LOCAL COL_MAX: DWORD
    
    push eax
	push ebx
    push ecx
    push edx
    push esi
    push edi
	
    invoke time,0
    invoke srand,eax

    .while CNT < mine_total
        invoke rand
        xor    edx,edx
        div    mine_total
        mov    POSITION,edx

        cmp    POSITION,Clicked_point
        JE     USED

        mov    cl, MINE
        mov    ebx, POSITION
        mov    dword ptr [realBoard+ebx],cl

        INC    CNT
        USED:
    .endw

    xor ecx,ecx
    mov CNT,ecx

    xor edx,edx
    mov eax,Board_column
    MUL Board_row
    mov TOTAL_SCALE,eax

    mov ecx, Board_column
    dec ecx
    mov COL_MAX, ecx

    mov ecx, Board_row
    dec ecx
    mov ROW_MAX, ecx

    .while CNT < TOTAL_SCALE
        mov ebx,CNT

        CMP byte ptr [realBoard+ebx], MINE
        JE  IS_MINE

        xor edx,edx
        mov eax,CNT
        DIV Board_column
   
        .IF eax != 0 
            .IF edx != 0
                mov ebx, eax
                sub ebx, Board_column
                dec ebx
                .IF byte ptr [realBoard+ebx]==MINE
                    mov ecx, CNT
                    inc byte ptr [realBoard+ecx]
                .ENDIF
            .ENDIF

            mov ebx, eax
            sub ebx, Board_column
            .IF byte ptr [realBoard+ebx]==MINE
                mov ecx, CNT
                inc byte ptr [realBoard+ecx]
            .ENDIF

            .IF edx != COL_MAX
                mov ebx, eax
                sub ebx, Board_column
                inc ebx
                .IF byte ptr [realBoard+ebx]==MINE
                    mov ecx, CNT
                    inc byte ptr [realBoard+ecx]
                .ENDIF
            .ENDIF

        .ENDIF


        .IF edx != 0
            mov ebx, eax
            dec ebx
            .IF byte ptr [realBoard+ebx]==MINE
                mov ecx, CNT
                inc byte ptr [realBoard+ecx]
            .ENDIF
        .ENDIF

        .IF edx != COL_MAX
            mov ebx, eax
            inc ebx
            .IF byte ptr [realBoard+ebx]==MINE
                mov ecx, CNT
                inc byte ptr [realBoard+ecx]
            .ENDIF
        .ENDIF




        .IF eax != ROW_MAX
            .IF edx != 0
                mov ebx, eax
                add ebx, Board_column
                dec ebx
                .IF byte ptr [realBoard+ebx]==MINE
                    mov ecx, CNT
                    inc byte ptr [realBoard+ecx]
                .ENDIF
            .ENDIF

            mov ebx, eax
            add ebx, Board_column
            .IF byte ptr [realBoard+ebx]==MINE
                mov ecx, CNT
                inc byte ptr [realBoard+ecx]
            .ENDIF

            .IF edx != COL_MAX
                mov ebx, eax
                add ebx, Board_column
                inc ebx
                .IF byte ptr [realBoard+ebx]==MINE
                    mov ecx, CNT
                    inc byte ptr [realBoard+ecx]
                .ENDIF
            .ENDIF

        .ENDIF



    IS_MINE:
        INC CNT

    .endw


    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
Initializing endp

.end