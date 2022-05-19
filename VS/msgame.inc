
.const

; --- 游戏难度设置 ---
BEGINNER_WIDTH      equ 9
BEGINNER_HEIGHT     equ 9
BEGINNER_MINES      equ 10
INTERMEDIATE_WIDTH  equ 16
INTERMEDIATE_HEIGHT equ 16
INTERMEDIATE_MINES  equ 40
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
MINE            equ 0ffh  ; 仅答案盘
UNKNOWN         equ 10h  ; 仅显示盘
FLAGED          equ 20h  ; 仅显示盘
EXPLODED        equ 30h  ; 仅显示盘
FLAG_WRONG      equ 40h  ; 仅显示盘


; --- 提示类型 ---
HINT_NONE       equ 0
HINT_SAFE       equ 1
HINT_MINE       equ 2
HINT_CLUE       equ 3
HINT_GUESS      equ 4
