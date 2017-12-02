section	.text
   global _start         ;must be declared for using gcc


   ;include standart c part
   extern printf ;only for debuging purposes
   extern Debug_tool_double ;only for debuging purposes
   extern Debug_tool_decimal
   extern Debug_tool_float
   extern move_side

   extern update_look

   extern cos
   extern sin

   extern sincos


   ;include SDL functions

   extern SDL_Init
   extern SDL_Quit
   extern SDL_Delay
   extern SDL_PollEvent

   extern SDL_CreateWindow
   extern SDL_GL_CreateContext
   extern SDL_GL_SwapWindow


   ;include ogl functions

   extern glEnable
   extern glFlush
   extern glColor3ub

   extern glBindBuffer
   extern glBindTexture
   extern glGenBuffers
   extern glGenTextures
   extern glTexParameteri
   extern glDeleteBuffers
   extern glBufferData
   extern glEnableClientState
   extern glVertexPointer
   extern glIndexPointer
   extern glNormalPointer
   extern glDrawArrays
   extern glDrawElements
   extern glTexImage2D
   extern glTexCoordPointer

   extern glClear
   extern glMatrixMode
   extern glLoadIdentity

   extern gluLookAt


   ;rewrite
   extern init_ogl
   extern proceed

%define M_PI 3.14159265358979323846

%define SDL_WINDOW_OPENGL 0x00000002
%define SDL_INIT_VIDEO 0x00000020
%define SDL_QUIT 0x100
%define SDL_KEYDOWN 0x300

%define GL_COLOR_MATERIAL 0xB57
%define GL_ELEMENT_ARRAY_BUFFER 0x8893
%define GL_INDEX_ARRAY 0x8077
%define GL_ARRAY_BUFFER 0x8892
%define GL_STATIC_DRAW 0x88E4
%define GL_MODELVIEW 0x1700
%define GL_FLOAT 0x1406
%define GL_TRIANGLES 0x4
%define GL_VERTEX_ARRAY 0x8074
%define GL_UNSIGNED_SHORT 0x1403
%define GL_SHORT 0x1402
%define GL_TEXTURE_2D 0xDE1
%define GL_TEXTURE_WRAP_S 0x2802
%define GL_TEXTURE_WRAP_T 0x2803
%define GL_REPEAT 0x2901
%define GL_RGB 0x1907
%define GL_TEXTURE_COORD_ARRAY 0x8078

%define SDL_SCANCODE_ESC 1769472

%define SDL_SCANCODE_W 7798784
%define SDL_SCANCODE_A 6356992
%define SDL_SCANCODE_S 7536640
%define SDL_SCANCODE_D 6553600

%define SDL_SCANCODE_UP 5373952
%define SDL_SCANCODE_LEFT 5242880
%define SDL_SCANCODE_DOWN 5308416
%define SDL_SCANCODE_RIGHT 5177344

struc SDL_KeyboardEvent

   .type resd 1 ;SDL_KEYDOWN or SDL_KEYUP
   .timestamp resd 1
   .windowID resd 1
   .state resb 1 ;SDL_PRESSED or SDL_RELEASED
   .repeat resb 1

   ;SDL_Keysym

   .scancode resd  1
   .sym resd 1
   .mod resw 1

endstruc

struc Camera

   .eyeX resq 1      ;aligned
   .eyeY resq 1
   .eyeZ resq 1      ;aligned

   .centerX resq 1
   .centerY resq 1   ;aligned
   .centerZ resq 1

   .angleY resq 1    ;aligned
   .angleZ resq 1

   .upZ resq 1       ;aligned

endstruc

%macro opengl_texture_start 1

   mov rdi, GL_TEXTURE_2D
   call glEnable

   mov rdi, %1
   mov rsi, textures_ids
   call glGenTextures

%endmacro

%macro load_texture 1

   mov rdi, GL_TEXTURE_2D
   mov rsi, [textures_ids + %1]
   call glBindTexture

   mov rdi, GL_TEXTURE_2D
   mov rsi, GL_TEXTURE_WRAP_S
   mov rdx, GL_REPEAT
   call glTexParameteri

   mov rdi, GL_TEXTURE_2D
   mov rsi, GL_TEXTURE_WRAP_T
   mov rdx, GL_REPEAT
   call glTexParameteri

   mov rdi, GL_TEXTURE_2D
   xor rsi, rsi
   mov rdx, GL_RGB
   mov rcx, 2
   mov r8, 2
   xor r9, r9
   push test_image
   push GL_FLOAT
   push rdx

   call glTexImage2D
   sub rsp, 24

%endmacro



%macro update_lookat 0  ;7843 cycles avg speed; 24 instructions

   movapd xmm0, [main_camera + Camera.angleY]   ;angleY|angleZ
   movapd xmm7, xmm0
   sub rsp, 32
   lea rdi, [rsp]       ;sin(angleY)
   lea rsi, [rsp + 8]   ;cos(angleY)
   call sincos
   movapd xmm0, xmm7
   shufpd xmm0, xmm0, 1    ;angleZ
   lea rdi, [rsp + 16]  ;sin(angleZ)
   lea rsi, [rsp + 24]  ;cos(angleZ)
   call sincos
   movapd xmm0, [rsp]   ;sin(Y)|cos(Y)
   movapd xmm3, xmm0
   shufpd xmm0, xmm0, 3
   movapd xmm1, [rsp + 16]
   mulpd xmm0, xmm1     ;sin(Z)*cos(Y)|cos(Z)*cos(Y)
   shufpd xmm0, xmm0, 1 ;swap
   movapd xmm2, [main_camera + Camera.eyeX]
   addpd xmm0, xmm2
   movupd [main_camera + Camera.centerX], xmm0     ; TODO: solve alignment(probably not possible)
   movsd xmm4, [main_camera + Camera.eyeZ]
   addsd xmm3, xmm4
   movsd [main_camera + Camera.centerZ], xmm3
   add rsp, 32

%endmacro

%macro load_meshes 1

%endmacro
   

;r10 continuer
;r12 SDL_Window screen

_timer_start:
   push rax
   push rdx
   rdtsc ;save time stamp in EDX:EAX
   mov [timer_first], edx
   mov [timer_first + 4], eax
   pop rdx
   pop rax
   ret

_timer_stop:

   push r12
   push rax
   push rdx
   rdtsc

   sub eax, [timer_first + 4]
   sub edx, [timer_first]

   mov rdi, timer_fmt
   mov rsi, rdx
   mov rdx, rax

   sub rsp, 32
   call printf
   add rsp, 32
   pop rdx
   pop rax
   pop r12
   ret

_debug_Uint32:
   push rsi
   push r12
   push rax
   push rdx

   mov rdi, debug_Uint32_fmt
   sub rsp, 32
   call printf
   add rsp, 32

   pop rdx
   pop rax
   pop r12
   pop rsi
   ret

_debug_double:
   push rsi
   push r12
   push rax
   push rdx

   mov rdi, debug_double_fmt
   sub rsp, 32
   call printf
   add rsp, 32

   pop rdx
   pop rax
   pop r12
   pop rsi
   ret


;   _____ _             _   
;  / ____| |           | |  
; | (___ | |_ __ _ _ __| |_ 
;  \___ \| __/ _` | '__| __|
;  ____) | || (_| | |  | |_ 
; |_____/ \__\__,_|_|   \__|
;
                           
_start:

   ;initialisation process

   mov [stack_start], rsp
   and rsp, 0xFFFFFFFFFFFFFFF0 ;align stack

   call _timer_start ;starting time-stamp

   mov rdi, SDL_INIT_VIDEO
   call SDL_Init

   mov rcx, func_name_SDL_Init ;output string
   call _timer_stop ;difference between time-stamps

   call _timer_start

   mov rdi, window_title
   mov rsi, 640
   mov rdx, 480
   mov rcx, 640
   mov r8, 480
   mov r9, SDL_WINDOW_OPENGL

   call SDL_CreateWindow
   mov r12, rax
   mov rcx, func_name_SDL_CreateWindow
   call _timer_stop

   call _timer_start
   mov rdi, r12
   call SDL_GL_CreateContext
   mov rcx, func_name_SDL_GL_CreateContext
   call _timer_stop

   call init_ogl

   ;;mov rdi, 0x1701
   ;;call glMatrixMode

   ;;call glLoadIdentity

   ;;movupd xmm0, 

   call _timer_start
   mov rdi, SDL_event
   call SDL_PollEvent
   mov rcx, func_name_SDL_PollEvent
   call _timer_stop

   ;mov rdi, GL_COLOR_MATERIAL
   ;call glEnable

   ;mov rdi, 255 ;red
   ;mov rsi, 0 ;green
   ;mov rdx, 0 ;blue
   ;call glColor3ub

   ;Prepare buffers

   mov rdi, 1 ;vertices
   mov rsi, buffers_ids
   call glGenBuffers

   mov rdi, 1 ;normals
   mov rsi, buffers_ids + 8
   call glGenBuffers

   mov rdi, 1 ;texture coords
   mov rsi, buffers_ids + 16
   call glGenBuffers

   mov rdi, 1 ;indices
   mov rsi, buffers_ids + 24
   call glGenBuffers

   opengl_texture_start 1

   load_texture 0

   ;Open file

   mov rax, 5 ;open
   mov rbx, file_name
   mov rcx, 0 ;read only
   mov rdx, 0777 ;chmod
   int  0x80
   
   mov  [fd_in], rax

   mov rax, 3 ;read
   mov rbx, [fd_in]
   mov rcx, readed_data
   mov rdx, 8
   int 0x80

   xor rdx, rdx
   mov edx, [readed_data+4]
   mov [buffers_sizes], rdx

   shl rdx, 2
   mov r10, rdx
   add rdx, rdx
   add rdx, r10

   mov r10, rdx


   mov rax, 3 ;read
   mov rbx, [fd_in]
   mov rcx, readed_data
   int 0x80

   mov rdi, GL_ARRAY_BUFFER
   mov rsi, [buffers_ids]
   call glBindBuffer

   mov rdi, GL_ARRAY_BUFFER
   mov rsi, r10 ;size in bytes
   mov rdx, readed_data
   mov rcx, GL_STATIC_DRAW
   call glBufferData

   ;mov rdi, GL_ARRAY_BUFFER
   ;mov rsi, 36 ;size in bytes
   ;mov rdx, verticles
   ;mov rcx, GL_STATIC_DRAW
   ;call glBufferData

   mov rdx, [buffers_sizes]
   shl rdx, 2
   mov r10, rdx
   add rdx, rdx
   add rdx, r10

   mov rax, 3 ;read
   mov rbx, [fd_in]
   mov rcx, readed_data
   int 0x80

   mov rdi, GL_ARRAY_BUFFER
   mov rsi, [buffers_ids+8]
   call glBindBuffer

   mov rdi, GL_ARRAY_BUFFER
   mov rsi, r10 ;size in bytes
   mov rdx, readed_data
   mov rcx, GL_STATIC_DRAW
   call glBufferData

   mov rdx, [buffers_sizes]
   shl rdx, 3
   mov r10, rdx

   mov rax, 3 ;read
   mov rbx, [fd_in]
   mov rcx, readed_data
   int 0x80

   mov rdi, GL_ARRAY_BUFFER
   mov rsi, [buffers_ids+16]
   call glBindBuffer

   mov rdi, GL_ARRAY_BUFFER
   mov rsi, r10
   mov rdx, readed_data
   mov rcx, GL_STATIC_DRAW
   call glBufferData

   mov rax, 3 ;read
   mov rbx, [fd_in]
   mov rcx, readed_data
   mov rdx, 4
   int 0x80

   xor rdx, rdx
   mov edx, [readed_data]
   mov rdi, rdx

   mov [buffers_sizes+8], rdx

   shl rdx, 2

   mov rax, 3 ;read
   mov rbx, [fd_in]
   mov rcx, readed_data
   int 0x80

   mov rdi, GL_ELEMENT_ARRAY_BUFFER
   mov rsi, [buffers_ids+24]
   call glBindBuffer

   mov rdi, GL_ELEMENT_ARRAY_BUFFER
   mov rsi, [buffers_sizes+8]
   shl rsi, 2
   mov rdx, readed_data
   mov rcx, GL_STATIC_DRAW
   call glBufferData

   mov eax, 6 ;close
   mov ebx, [fd_in]
   int 0x80

   mov rdi, main_camera
   update_lookat


;   ____            _             _ _           
;  / ___|___  _ __ | |_ _ __ ___ | | | ___ _ __ 
; | |   / _ \| '_ \| __| '__/ _ \| | |/ _ \ '__|
; | |__| (_) | | | | |_| | | (_) | | |  __/ |   
;  \____\___/|_| |_|\__|_|  \___/|_|_|\___|_|   
;


main_controller:

   mov r10, [continuer]
   cmp r10, 0
   je end_main_controller ;properly end everything

   mov rdi, SDL_event ;call again, without time_stamp
   call SDL_PollEvent
   cmp rax, 0
   je break_sw1 ;no need for checking event

   ;mov rdi, [SDL_event]
   ;call Debug_tool_decimal

   movss xmm0, [SDL_event]
   shufps xmm0, xmm0, 0

   movups xmm1, [switch1] ;need to be reworked on aligned variant

   cmpps xmm0, xmm1, 0

   movups xmm1, [general_switch]
   andps xmm0, xmm1
   haddps xmm0, xmm0
   haddps xmm0, xmm0

   movups [xmm_something], xmm0
   mov eax, [xmm_something]

   jmp [rax + switch1_labels]

KEY_DOWN_sw1:

   ;mov rdi, [SDL_event + 4 + SDL_KeyboardEvent.scancode]
   ;call Debug_tool_decimal

   movss xmm0, [SDL_event + 4 + SDL_KeyboardEvent.scancode]
   shufps xmm0, xmm0, 0

   movups xmm1, [switch2]
   movups xmm2, [switch2+16]

   cmpps xmm1, xmm0, 0
   cmpps xmm2, xmm0, 0

   movups xmm0, [general_switch]
   andps xmm1, xmm0
   movups xmm0, [general_switch+16]
   andps xmm2, xmm0

   addps xmm1, xmm2
   haddps xmm1, xmm1
   haddps xmm1, xmm1

   movups [xmm_something], xmm1
   mov eax, [xmm_something]

   jmp [eax + switch2_labels]

FORWARD_sw2:

   movsd xmm0, [main_camera + Camera.centerX]
   movsd [main_camera + Camera.eyeX], xmm0

   movsd xmm0, [main_camera + Camera.centerY]
   movsd [main_camera + Camera.eyeY], xmm0

   update_lookat

   jmp break_sw1

BACKWARD_sw2:
   movsd xmm0, [main_camera + Camera.centerX]
   movsd xmm1, [main_camera + Camera.eyeX]
   subsd xmm0, xmm1
   subsd xmm1, xmm0
   movsd [main_camera + Camera.eyeX], xmm1

   movsd xmm0, [main_camera + Camera.centerY]
   movsd xmm1, [main_camera + Camera.eyeY]
   subsd xmm0, xmm1
   subsd xmm1, xmm0
   movsd [main_camera + Camera.eyeY], xmm1

   update_lookat

   jmp break_sw1

LEFT_sw1:

   mov rdi, main_camera
   call move_side

   ;movsd xmm0, [main_camera + Camera.centerX]
   ;movsd xmm1, [main_camera + Camera.eyeX]
   ;subsd xmm0, xmm1

   ;movsd xmm2, [main_camera + Camera.centerY]
   ;movsd xmm3, [main_camera + Camera.eyeY]
   ;subsd xmm2, xmm3

   ;addsd xmm3, xmm0
   ;addsd xmm1, xmm2

   ;movsd [main_camera + Camera.eyeX], xmm1
   ;movsd [main_camera + Camera.eyeY], xmm3

   update_lookat

   jmp break_sw1

ROTATE_RIGHT_sw2:
   movsd xmm0, [main_camera + Camera.angleZ]
   movsd xmm7, [M_PI_DIV_180]
   subsd xmm0, xmm7

   movsd [main_camera + Camera.angleZ], xmm0

   update_lookat

   jmp break_sw1

ROTATE_LEFT_sw2:
   movsd xmm0, [main_camera + Camera.angleZ]
   movsd xmm7, [M_PI_DIV_180]
   addsd xmm0, xmm7

   movsd [main_camera + Camera.angleZ], xmm0

   update_lookat

   jmp break_sw1

SDL_QUIT_sw1:
   mov r10, 0
   mov [continuer], r10
   jmp break_sw1
default_sw1:
   jmp break_sw1

break_sw1:

   mov rdi, 0x4100 ;GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
   call glClear

   mov rdi, GL_MODELVIEW
   call glMatrixMode

   call glLoadIdentity

   ;update_lookat

   mov rax, 0x3FF0000000000000
   push rax

   movsd xmm0, [main_camera + Camera.eyeX]  ;eyeX
   movsd xmm1, [main_camera + Camera.eyeY]  ;eyeY
   movsd xmm2, [main_camera + Camera.eyeZ]  ;eyeZ
   ;xorpd xmm3, xmm3
   movsd xmm3, [main_camera + Camera.centerX]
   movsd xmm4, [main_camera + Camera.centerY]
   movsd xmm5, [main_camera + Camera.centerZ]
   xorpd xmm6, xmm6  ; 0
   xorpd xmm7, xmm7  ; 0

   call gluLookAt
   add rsp, 8

   mov rdi, GL_VERTEX_ARRAY
   call glEnableClientState

   mov rdi, GL_ARRAY_BUFFER
   mov rsi, [buffers_ids]
   call glBindBuffer

   mov rdi, 3
   mov rsi, GL_FLOAT
   mov rdx, 0
   mov rcx, 0
   call glVertexPointer

   mov rdi, GL_TEXTURE_COORD_ARRAY
   call glEnableClientState

   mov rdi, GL_ARRAY_BUFFER
   mov rsi, [buffers_ids + 16]
   call glBindBuffer

   mov rdi, 2
   mov rsi, GL_FLOAT
   mov rdx, 0
   mov rcx, 0
   call glTexCoordPointer

   ;mov rdi, GL_ARRAY_BUFFER
   ;mov rsi, [buffers_ids+8]
   ;call glBindBuffer

   ;mov rdi, GL_FLOAT
   ;mov rsi, 0
   ;mov rdx, 0
   ;call glNormalPointer

   mov rdi, GL_TEXTURE_2D
   mov rsi, [textures_ids]
   call glBindTexture


   mov rdi, GL_TRIANGLES           ;;WITH VBO NO LONGER NEEDED
   mov rsi, 0 ;first index
   mov rdx, [buffers_sizes+8]
   call glDrawArrays

   ;mov rdi, GL_TRIANGLES
   ;mov rsi, [buffers_sizes+8]
   ;shl rsi, 2
   ;mov rdx, GL_UNSIGNED_SHORT
   ;mov rcx, 0
   ;call glDrawElements

   call glFlush

   mov rdi, r12
   call SDL_GL_SwapWindow

   mov rdi, 10
   call SDL_Delay
   jmp main_controller

end_main_controller:



   call _timer_start
   call SDL_Quit
   mov rcx, func_name_SDL_Quit
   call _timer_stop

   mov rdi, 1
   mov rsi, buffers_ids
   call glDeleteBuffers

   mov rdi, 1
   mov rsi, buffers_ids + 8
   call glDeleteBuffers

   mov rsp, [stack_start]
       
   mov	eax,1             ;system call number (sys_exit)
   int	0x80              ;call kernel

section	.data
file_name db 'meshes.ipa', 0
len_file_name equ $-file_name

window_title db 'IPA project xkelem01', 0

stack_start dq 0
continuer dq 1

align 16
main_camera dq 2.0, 3.0, 0.0, 0.0, 0.0, 0.0, 0.0, 180.0, 1.0, 0.0

general_switch dd 8, 16, 24, 32, 40, 48, 56, 64

switch1 dd 0x0 , 0x0 , SDL_KEYDOWN , SDL_QUIT
switch1_labels dq default_sw1, default_sw1, default_sw1, KEY_DOWN_sw1, SDL_QUIT_sw1

switch2 dd SDL_SCANCODE_W , SDL_SCANCODE_A , SDL_SCANCODE_S, SDL_SCANCODE_D, SDL_SCANCODE_UP, SDL_SCANCODE_LEFT, SDL_SCANCODE_DOWN, SDL_SCANCODE_RIGHT
switch2_labels dq default_sw1, FORWARD_sw2, LEFT_sw1, BACKWARD_sw2, SDL_QUIT_sw1, FORWARD_sw2, ROTATE_LEFT_sw2, BACKWARD_sw2, ROTATE_RIGHT_sw2

verticles dd 1.0, -1.0, 1.0,    -1.0, -1.0, -1.0,    1.0, -1.0, -1.0
indices dd 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 , 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32,33,34,35,36
test_image dd 1.0, 1.0, 1.0,  0.5,0.5,0.5,  0.0,0.0,0.0,  0.5,0.5,0.5

M_PI_DIV_180 dq 0x3F91D746A2529D39

var0 dq 0x0
var1 dq 0x3FF0000000000000

timer_fmt db 'rdsct time difference: %d%d cycles (func %s)', 0xa, 0

;function names
func_name_SDL_Init db 'SDL_Init', 0
func_name_SDL_Quit db 'SDL_Quit', 0
func_name_SDL_CreateWindow db 'SDL_CreateWindow', 0
func_name_SDL_GL_CreateContext db 'SDL_GL_CreateContext', 0
func_name_SDL_PollEvent db 'SDL_PollEvent', 0
func_name_Update_LookAt db 'Update_LookAt', 0

debug_Uint32_fmt db 'output decimal: %d', 0xa, 0
debug_double_fmt db 'output double: %f', 0xa, 0

;insta_args_gluPerspective dq 

section .bss   ;uninitialised data

xmm_something resq 2
timer_first resq 2 ;first time-stamp for compare (EDX:EAX = 64b)
SDL_event resb 64 ;event handler
textures_ids resd 4
buffers_ids resq 4
buffers_sizes resq 4

fd_out resq 1
fd_in  resq 1
readed_data resd 1024