.386
.model flat,stdcall
option casemap:none

includelib msvcrt.lib
include Comdlg32.inc
includelib Comdlg32.lib

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
error_title BYTE "Error", 0
error_msg BYTE "[ERROR] There is no input!", 0
scan_str BYTE "%s", 0ah, 0
file_mode BYTE "r", 0



ButtonText1     BYTE "1", 0
ButtonText2     BYTE "Select the second file.", 0
ButtonText3     BYTE "Compare1", "Compare2", 0

Image_1 BYTE "D:\Files\Resource\Github\MineSweeper\VS\src\images\1.png", 0

menuCaptionText BYTE "Level of Difficulty", 0
menuEasyText BYTE "Easy", 0
menuMediumText BYTE "Medium", 0
menuHardText BYTE "Hard", 0

; handlers
hInstance       HINSTANCE 0

hMenu HMENU  0
hSubMenu HMENU  0

File1       HWND 0
File2       HWND 0
File3       HWND 0



.const
Button1ID       equ 1
Button2ID       equ 2
Button3ID       equ 3
BLOCK_SIZE      equ 30


.code

;
; generate the main window, fundation of the project
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
        CW_USEDEFAULT, CW_USEDEFAULT, 285, 320, 0, 0, hInstance, 0
    mov handle, eax

    ; show the window and refresh it recursively
    invoke ShowWindow, handle, SW_SHOWNORMAL

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
;
PromptError proc
  pushad
  invoke MessageBox, NULL, ADDR error_msg, ADDR error_title, MB_OK
  popad
  ret
PromptError	endp


showMap proc C  hWnd:HWND, Width1: DWORD, Height1: DWORD, buttonWidth1: DWORD, buttonHeight1: DWORD
    push ebx
    push ecx
    push edx
    push esi
    push edi

    xor ebx, ebx ; height
    xor ecx, ecx ; width

    .while ebx < Height1
        .while ecx < Width1
            mov eax, ecx
            mul buttonWidth1
            mov edi, eax

            mov eax, ebx
            mul buttonHeight1
            mov esi, eax

            ; ID of button
            mov eax, edi
            sal eax, 16
            or eax, esi


            push ecx
            push ebx
            invoke CreateWindowEx, NULL, ADDR ButtonClassName, ADDR ButtonText1, \
                    WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, \
                    edi, esi, buttonWidth1, buttonHeight1, hWnd, eax, hInstance, NULL
            mov File1, eax

            pop ebx
            pop ecx

            inc ecx
        .endw

        xor ecx, ecx
        inc ebx
    .endw
  
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret
showMap	endp


;
; new game
;
newGame proc C hWnd: HWND, difficulty: DWORD
    push ebx
    push ecx
    push edx
    push esi
    push edi

    

    ; refresh window and reset size of it
    .if difficulty == 1001
        mov esi, 9
        mov edi, 9
    .elseif difficulty == 1002
        mov esi, 16
        mov edi, 16
    .else
        mov esi, 30
        mov edi, 16
    .endif

    mov eax, BLOCK_SIZE
    mul esi
    mov ebx, eax
    add ebx, 20

    mov eax, BLOCK_SIZE
    mul edi
    add eax, 60
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
; message handler
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

        invoke newGame, hWnd, 1001

    .ELSEIF uMsg == WM_COMMAND
        
        ; change difficulty
        .if wParam == 1001  ; easy
            invoke newGame, hWnd, 1001
        .elseif wParam == 1002 ; midium
            invoke newGame, hWnd, 1002
        .elseif wParam == 1003 ; hard
            invoke newGame, hWnd, 1003
        .endif

        ; restart game

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