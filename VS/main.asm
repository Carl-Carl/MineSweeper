.386
.model flat,stdcall
option casemap:none

includelib msvcrt.lib

atof PROTO C : ptr sbyte
printf PROTO C : ptr sbyte, :VARARG	
sprintf PROTO C : ptr sbyte, :VARARG
puts PROTO C : ptr sbyte

strcmp PROTO C : ptr sbyte, : ptr sbyte
strcat PROTO C : ptr sbyte, : ptr sbyte
strlen PROTO C : ptr sbyte

fopen PROTO C : ptr sbyte, : ptr sbyte
fgets PROTO C : ptr sbyte, : dword, : ptr sbyte
fclose PROTO C : ptr sbyte
fscanf PROTO C : ptr sbyte, :VARARG	

WinMain     proto        ; Main window process
MessageBoxA proto :DWORD, :DWORD, :DWORD, :DWORD       
MessageBox 	equ   <MessageBoxA>                        


PromptError      proto                                 


include     windows.inc
include     user32.inc
include     kernel32.inc


.data
ClassName BYTE "Mine Sweeper", 0
AppName BYTE "Mine Sweeper", 0
ButtonClassName BYTE "button", 0
LEDClassName BYTE "STATIC", 0
error_title BYTE "Error", 0
error_msg BYTE "[ERROR] There is no input!", 0
scan_str BYTE "%d", 0ah, 0
file_mode BYTE "r", 0

init_flag BYTE 0


ButtonText1     BYTE "1", 0
ButtonText2     BYTE "Select the second file.", 0
ButtonText3     BYTE "Compare1", "Compare2", 0

mine_num_path BYTE   "src\images\0.bmp", 0,
                     "src\images\1.bmp", 0,
                     "src\images\2.bmp", 0,
                     "src\images\3.bmp", 0,
                     "src\images\4.bmp", 0,
                     "src\images\5.bmp", 0,
                     "src\images\6.bmp", 0,
                     "src\images\7.bmp", 0,
                     "src\images\8.bmp", 0
mine_num_path_length dd ($-mine_num_path)/9

led_path BYTE        "src\images\led0.bmp", 0,
                     "src\images\led1.bmp", 0,
                     "src\images\led2.bmp", 0,
                     "src\images\led3.bmp", 0,
                     "src\images\led4.bmp", 0,
                     "src\images\led5.bmp", 0,
                     "src\images\led6.bmp", 0,
                     "src\images\led7.bmp", 0,
                     "src\images\led8.bmp", 0,
                     "src\images\led9.bmp", 0
led_path_length dd ($-led_path)/10

hidden_path BYTE   "src\images\hidden.bmp", 0

menuCaptionText BYTE "Level of Difficulty", 0
menuEasyText BYTE "Easy", 0
menuMediumText BYTE "Medium", 0
menuHardText BYTE "Hard", 0

; handles
hInstance       HINSTANCE 0

hMenu HMENU  0
hSubMenu HMENU  0

button_pushed           HWND 0
buttons_all             HWND 16*30 dup(0)
buttons_all_end         dd 0
led1_handle             HWND 0
led0_handle             HWND 0

; image handles
mine_num    HBITMAP 9 dup(?)
led_num     HBITMAP 10 dup(?)
hidden      HBITMAP ?

paint           PAINTSTRUCT <>
hDC             HDC ?
hMemDC          HDC ?

; game information
led1    dd 0    ; the ends digit of LED
led0    dd 0    ; the ones digit of LED

.const
Button1ID       equ 1
Button2ID       equ 2
Button3ID       equ 3
BLOCK_SIZE      equ 30


.code

;
; generate the main window, fundation of the project
; You should not modify this function in most cases.
;
WinMain proc
    local wndclassex: WNDCLASSEX
    local message: MSG
    local handle: HWND

    ; initiallize WNDCLASSEX
    mov wndclassex.style, CS_HREDRAW or CS_VREDRAW
    mov wndclassex.cbSize, SIZEOF WNDCLASSEX
    mov wndclassex.lpfnWndProc, offset handle_function  ; set our function
    mov wndclassex.cbClsExtra, 0
    mov wndclassex.cbWndExtra, 0
    invoke GetModuleHandle, 0
    mov wndclassex.hInstance, eax
    mov wndclassex.hbrBackground, 04H
    mov wndclassex.lpszMenuName, 0
    mov wndclassex.lpszClassName, offset ClassName

    invoke LoadIcon, 0, IDI_APPLICATION
    mov wndclassex.hIcon, eax
    mov wndclassex.hIconSm, eax
    invoke LoadCursor, 0, IDC_ARROW
    mov wndclassex.hCursor, eax

    invoke RegisterClassEx, addr wndclassex
    invoke CreateWindowEx, WS_EX_CLIENTEDGE, offset ClassName, offset AppName, \
    WS_OVERLAPPEDWINDOW,   ; style of the main window
        CW_USEDEFAULT, CW_USEDEFAULT, 285, 380, 0, 0, hInstance, 0
    mov handle, eax

    ; show the window and refresh it recursively
    invoke ShowWindow, handle, SW_SHOWNORMAL
    invoke UpdateWindow, handle

WINDOW_LOOP:
    invoke GetMessage, addr message, NULL, 0, 0
    CMP eax, 0
    jz WINDOW_LOOP_OUT
    invoke TranslateMessage, addr message
    invoke DispatchMessage, addr message

    jmp WINDOW_LOOP
WINDOW_LOOP_OUT:

    ; exit
    mov eax, message.wParam
    ret
WinMain endp


;
; error handler
; I have not invoked this function at any places
;
PromptError proc
  pushad
  invoke MessageBox, NULL, ADDR error_msg, ADDR error_title, MB_OK
  popad
  ret
PromptError	endp


;
; show the number of remaining mines
; paramter "change" can be 1, 0, -1
; you should invoke this function only if when the player labeled a mine
;
showLED proc C  hWnd:HWND, change: DWORD
    local cnt: dword
    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov esi, led0
    mov edi, led1
    add esi, change

    .if esi == 10
        inc edi
        xor esi, esi
    .elseif esi == -1
        dec edi
        mov esi, 9
    .endif

    mov led0, esi
    mov led1, edi

    invoke DestroyWindow, led1_handle
    invoke DestroyWindow, led0_handle

    invoke CreateWindowEx, WS_EX_WINDOWEDGE, ADDR LEDClassName, ADDR LEDClassName, \
            WS_CHILD or WS_VISIBLE or SS_BITMAP, \
            0, 10, 24, 40, hWnd, 6666, hInstance, NULL
    mov led1_handle, eax
    invoke SendMessage, eax, STM_SETIMAGE, IMAGE_BITMAP, led_num[edi*type led_num]
    
    invoke CreateWindowEx, NULL, ADDR LEDClassName, ADDR LEDClassName, \
            WS_CHILD or WS_VISIBLE or SS_BITMAP, \
            24, 10, 24, 40, hWnd, 6667, hInstance, NULL
    mov led0_handle, eax
    invoke SendMessage, eax, STM_SETIMAGE, IMAGE_BITMAP, led_num[esi*type led_num]
  
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
showLED endp


;
; show the entire map of mines when initializing
; !!! you should not change or invoke this fucntion !!!
;
showMap proc C  hWnd:HWND, Width1: DWORD, Height1: DWORD, buttonWidth1: DWORD, buttonHeight1: DWORD
    local cnt: dword
    push ebx
    push ecx
    push edx
    push esi
    push edi

    xor ebx, ebx ; height
    xor ecx, ecx ; width
    mov cnt, 0

    .while ebx < Height1
        .while ecx < Width1
            mov eax, ecx
            mul buttonWidth1
            mov edi, eax

            mov eax, ebx
            mul buttonHeight1
            mov esi, eax
            add esi, 60

            ; ID of button
            mov eax, edi
            sal eax, 16
            or eax, esi


            push ecx
            push edx
            invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonText1, \
                    WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON or BS_BITMAP, \
                    edi, esi, buttonWidth1, buttonHeight1, hWnd, eax, hInstance, NULL

            mov esi, eax
            invoke SendMessage, esi, BM_SETIMAGE, IMAGE_BITMAP, hidden
            pop edx
            pop ecx

            mov edx, cnt
            mov buttons_all[edx*type buttons_all], esi
            inc ecx
            inc cnt
        .endw

        xor ecx, ecx
        inc ebx
    .endw

    mov eax, type buttons_all
    mul cnt
    mov buttons_all_end, eax
    add buttons_all_end, offset buttons_all
  
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
showMap	endp


;
; start a new game
; this function refreash everything including LED, mine, difficulty and menu
; you should input the difficulty at parameter "dicciculty", 
; where 1001 is easy, 1002 is medium, 1003 is hard
;
newGame proc C hWnd: HWND, difficulty: DWORD
    push ebx
    push ecx
    push edx
    push esi
    push edi

    lea esi, buttons_all
    .while esi < buttons_all_end
        mov edi, [esi]
        invoke DestroyWindow, edi
        add esi, type buttons_all
    .endw


    ; refresh window and reset size of it
    .if difficulty == 1001
        mov esi, 9
        mov edi, 9
        mov led1, 1
        mov led0, 0
    .elseif difficulty == 1002
        mov esi, 16
        mov edi, 16
        mov led1, 4
        mov led0, 0
    .else
        mov esi, 30
        mov edi, 16
        mov led1, 9
        mov led0, 9
    .endif

    invoke showLED, hWnd, 0

    mov eax, BLOCK_SIZE
    mul esi
    mov ebx, eax
    add ebx, 20

    mov eax, BLOCK_SIZE
    mul edi
    add eax, 120
    invoke MoveWindow, hWnd, 100, 150, ebx, eax, 1

    invoke showMap, hWnd, esi, edi, BLOCK_SIZE, BLOCK_SIZE


    ; modify the menu
    mov edi, 1001

    .while edi < 1004
        mov esi, MF_BYCOMMAND
        .if difficulty == edi
            or esi, MF_CHECKED
        .else
            or esi, MF_UNCHECKED
        .endif
        invoke CheckMenuItem, hSubMenu, edi, esi
        inc edi
    .endw

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
newGame endp


;
; load the all the image here
;
loadBitmap proc C
    push ecx
    push edx

    ; load number of mines images
    xor ebx, ebx
    xor esi, esi
    .while esi <= 8
        invoke  LoadImageA, NULL, addr mine_num_path[ebx], IMAGE_BITMAP, 25, 25, LR_LOADFROMFILE
        mov dword ptr mine_num[esi*type mine_num], eax

        add ebx, mine_num_path_length
        inc esi
    .endw

    ; load led images
    xor ebx, ebx
    xor esi, esi
    .while esi <= 9
        invoke  LoadImageA, NULL, addr led_path[ebx], IMAGE_BITMAP, 24, 40, LR_LOADFROMFILE
        mov dword ptr led_num[esi*type led_num], eax

        add ebx, led_path_length
        inc esi
    .endw

    ; load hidden image
    invoke  LoadImageA, NULL, addr hidden_path, IMAGE_BITMAP, 25, 25, LR_LOADFROMFILE
    mov hidden, eax

    pop edx
    pop ecx
    ret
loadBitmap endp


;
; input handle of button and handle of image, then the image of button will change
;
changeButtonImage proc C button_hwnd: HWND, image: dword
    push ecx
    push edx

    invoke SendMessage, button_hwnd, BM_SETIMAGE, IMAGE_BITMAP, image

    pop edx
    pop ecx
    ret
changeButtonImage endp


;
; message handler
; this is the core function
;
handle_function proc hWnd: HWND, uMsg: UINT, wParam: WPARAM, lParam: LPARAM
    .IF uMsg == WM_DESTROY
        invoke DestroyWindow, hWnd
        invoke PostQuitMessage, NULL

    .ELSEIF uMsg == WM_CREATE
        
        ; menu
        invoke CreateMenu
        mov hMenu, eax
        
        invoke CreateMenu
        mov hSubMenu, eax
 
        invoke AppendMenu, hMenu, MF_POPUP, hSubMenu, offset menuCaptionText
        invoke AppendMenu, hSubMenu, MF_STRING or MF_CHECKED, 1001, offset menuEasyText
        invoke AppendMenu, hSubMenu, MF_SEPARATOR, 0, NULL
        invoke AppendMenu, hSubMenu, MF_STRING, 1002, offset menuMediumText
        invoke AppendMenu, hSubMenu, MF_SEPARATOR, 0, NULL
        invoke AppendMenu, hSubMenu, MF_STRING, 1003, offset menuHardText

        invoke SetMenu, hWnd, hMenu

        invoke loadBitmap

        invoke newGame, hWnd, 1001

    .ELSEIF uMsg == WM_COMMAND
        mov eax, wParam

        ; change difficulty
        .if eax == 1001  ; easy
            invoke newGame, hWnd, 1001
        .elseif eax == 1002 ; midium
            invoke newGame, hWnd, 1002
        .elseif eax == 1003 ; hard
            invoke newGame, hWnd, 1003
        .endif

        ; click
        mov ebx, eax
        shr ebx, 16
        .if bh == BN_CLICKED  
            ; "lParam" is the handle of button
            invoke changeButtonImage, lParam, mine_num[2*type mine_num]

            invoke showLED, hWnd, -1
        .endif

    .ELSE
        invoke DefWindowProc, hWnd, uMsg, wParam, lParam
        ret
    .ENDIF

    xor eax, eax
    ret
handle_function endp


;
; main
;
main:
  invoke WinMain
  invoke ExitProcess, eax
end main