.386
.model flat,stdcall
option casemap:none

include msgame.inc

public  	gameState
public		flaggedMines  
public		remainingMines
public		exploredCells 
public		realBoard     
public		playBoard     
public		hintBoard    
public		row_directions
public		col_directions
public		mine_total    
public		Board_column  
public		Board_row     
public		Clicked_column
public		Clicked_row   

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
Clicked_column  dword 0 ;上一个点击的位置
Clicked_row     dword 0 ;上一个点击的位置



end