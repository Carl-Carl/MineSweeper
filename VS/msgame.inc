
.const

; --- 游戏难度设置 ---
BEGINNER_WIDTH      equ 8
BEGINNER_HEIGHT     equ 8
BEGINNER_MINES      equ 10
INTERMEDIATE_WIDTH  equ 16
INTERMEDIATE_HEIGHT equ 16
INTERMEDIATE_MINES  equ 16
EXPERT_WIDTH        equ 30
EXPERT_HEIGHT       equ 16
EXPERT_MINES        equ 99
MAX_CELLS           equ 1024


; --- 游戏状态 ---
STATE_INIT      equ 0
STATE_PLAYING   equ 1
STATE_WIN       equ 10h
STATE_LOSE      equ 11h


; --- 答案盘和显示盘的单元格类型 ---
NUMBER_0        equ 0
NUMBER_1        equ 1
NUMBER_2        equ 2
NUMBER_3        equ 3
NUMBER_4        equ 4
NUMBER_5        equ 5
NUMBER_6        equ 6
NUMBER_7        equ 7
NUMBER_8        equ 8
MINE            equ ffh  ; 仅答案盘
UNKNOWN         equ 10h  ; 仅显示盘
FLAGED          equ 20h  ; 仅显示盘


; --- 提示类型 ---
HINT_NONE       equ 0
HINT_SAFE       equ 1
HINT_MINE       equ 2
HINT_CLUE       equ 3
HINT_GUESS      equ 4



.data
; --- 游戏全局数据区 ---
gameState       dword 0

flaggedMines    dword 0
remainingMines  dword 0
exploredCells   dword 0

realBoard       byte MAX_CELLS DUP(0)
playBoard       byte MAX_CELLS DUP(0)
hintBoard       byte MAX_CELLS DUP(0)


; --- 其他辅助数据 ---
; 俩数组 能加到坐标上形成8个方向的相邻坐标
row_directions  dword  0,  1,  1,  1,  0, -1, -1, -1
col_directions  dword -1, -1,  0,  1,  1,  1,  0, -1

mine_total      dword 0 ;记录雷的总数
Board_column    dword 0 ;图的总列数
Board_row       dword 0 ;图的总行数
Clicked_point   dword 0 ;上一个点击的位置
