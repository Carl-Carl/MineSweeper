.386
.model flat,stdcall
option casemap:none

include    MineSweeper.inc

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

        mov    ecx, MINE
        mov    ebx, POSITION
        mov    dword ptr [realBoard+ebx],ecx

        INC    CNT
        USED:
    .endw

    xor ecx,ecx
    mov CNT,ecx

    xor edx,edx
    mov eax,Board_column
    MUL Board_row
    mov TOTAL_SCALE,eax

    .while TOTAL_SCALE

        xor    edx,edx
        div    mine_total
        mov    POSITION,edx

        cmp    POSITION,Clicked_point
        JE     USED

        mov    ecx, MINE
        mov    ebx, POSITION
        mov    dword ptr [realBoard+ebx],ecx

        INC    CNT
        USED:
    .endw

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
Initializing endp

.end