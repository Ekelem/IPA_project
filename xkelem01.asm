section  .text
   global _start         ;must be declared for using gcc


   ;include standart c part
   extern printf ;only for debuging purposes
   extern Debug_tool_double ;only for debuging purposes
   extern Debug_tool_decimal
   extern Debug_tool_float
   extern move_side

   extern update_look
   extern texture_create

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
   extern SDL_GetDesktopDisplayMode


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
   extern glGenerateMipmap

   extern glClear
   extern glMatrixMode
   extern glLoadIdentity
   extern glPushMatrix
   extern glTranslated
   extern glPopMatrix

   extern gluLookAt


   ;rewrite
   extern init_ogl
   extern proceed

%define M_PI 3.14159265358979323846

%define SDL_WINDOW_OPENGL 0x00000002
%define SDL_INIT_VIDEO 0x00000020
%define SDL_QUIT 0x100
%define SDL_KEYDOWN 0x300
%define SDL_WINDOWPOS_UNDEFINED 0x1fff0000

%define GL_DEPTH_BUFFER_BIT 0x100
%define GL_COLOR_MATERIAL 0xB57
%define GL_ELEMENT_ARRAY_BUFFER 0x8893
%define GL_INDEX_ARRAY 0x8077
%define GL_ARRAY_BUFFER 0x8892
%define GL_STATIC_DRAW 0x88E4
%define GL_MODELVIEW 0x1700
%define GL_FLOAT 0x1406
%define GL_TRIANGLES 0x4
%define GL_VERTEX_ARRAY 0x8074
%define GL_NORMAL_ARRAY 0x8075
%define GL_UNSIGNED_BYTE 0x1401
%define GL_UNSIGNED_SHORT 0x1403
%define GL_UNSIGNED_INT 0x1405
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

struc SDL_DisplayMode

   .format resd 1
   .width resd 1
   .height resd 1
   .refresh_rate resd 1
   .driverdata resq 1

endstruc

%macro open_fullscreen_window 0

   call _timer_start

   mov rdi, 0
   mov rsi, readed_data
   call SDL_GetDesktopDisplayMode

   mov rdi, window_title
   mov rsi, SDL_WINDOWPOS_UNDEFINED
   mov rdx, SDL_WINDOWPOS_UNDEFINED
   mov rcx, [readed_data + SDL_DisplayMode.width]
   mov r8, [readed_data + SDL_DisplayMode.height]
   mov r9, 0x1003    ;SDL_WINDOW_OPENGL||SDL_WINDOW_FULLSCREEN

   call SDL_CreateWindow
   mov r12, rax
   mov rcx, func_name_SDL_CreateWindow
   call _timer_stop

%endmacro

%macro open_file 2

   mov rax, 5 ;open
   mov rbx, %1
   mov rcx, 0 ;read only
   mov rdx, 0777 ;chmod
   int  0x80

   mov  [%2], rax

%endmacro

%macro close_file 1
   mov eax, 6 ;close
   mov ebx, [%1]
   int 0x80
%endmacro

%macro read_file 1
   mov rax, 3 ;read
   mov rbx, [fd_in]
   mov rcx, readed_data
   mov rdx, %1
   int 0x80
%endmacro

%macro read_file_in_rdx 0
   mov rax, 3 ;read
   mov rbx, [fd_in]
   mov rcx, readed_data
   int 0x80
%endmacro

%macro check_integrity 0   ;check sequence "xkelem01" in first 64 bits

   read_file 16
   mov rax, [readed_data]
   mov rbx, [header]
   cmp rax, rbx
   jne end

%endmacro

%macro gen_buffer 1
   mov rdi, 1 ;number
   mov rsi, %1
   call glGenBuffers
%endmacro

%macro buffer_data 3

   mov rdi, GL_ARRAY_BUFFER
   mov rsi, [%1]
   call glBindBuffer

   mov rdi, GL_ARRAY_BUFFER
   mov rsi, %3 ;number of vertices
   shl rsi, 5  ;;size in bytes (Vertices * 32)
   mov rdx, %2 ;pointer
   mov rcx, GL_STATIC_DRAW
   call glBufferData

%endmacro

%macro element_buffer_data 3

   mov rdi, GL_ELEMENT_ARRAY_BUFFER
   mov rsi, [%1]  ;buffers_ids
   call glBindBuffer

   mov rdi, GL_ELEMENT_ARRAY_BUFFER
   mov rsi, %3 ;number indices
   shl rsi, 2 ;size in bytes
   mov rdx, %2 ;pointer
   mov rcx, GL_STATIC_DRAW
   call glBufferData

%endmacro
   

%macro opengl_texture_start 1

   mov rdi, GL_TEXTURE_2D
   call glEnable

%endmacro

%macro load_texture 1

   read_file 16
   movapd xmm0, [readed_data]
   movapd [textures_sizes + 16 + (%1*16)], xmm0

   mov rdx, [textures_sizes + 16+(%1*16)]
   mov rax, [textures_sizes + 24+(%1*16)]
   mul edx
   shl rdx, 32
   mov edx, eax
   mov rax, rdx
   add rdx, rax
   add rdx, rax

   read_file_in_rdx

   mov rdi, 1
   mov rsi, textures_ids + (%1*8)
   call glGenTextures

   mov rdi, GL_TEXTURE_2D
   mov rsi, [textures_ids + (%1*8)]
   call glBindTexture

   mov rdi, GL_TEXTURE_2D
   xor rsi, rsi
   mov rdx, GL_RGB
   mov rcx, [textures_sizes+16+(%1*16)]
   mov r8, [textures_sizes+24+(%1*16)]
   xor r9, r9  ;border must be 0
   push readed_data
   push GL_UNSIGNED_BYTE
   push rdx

   call glTexImage2D
   sub rsp, 24

   mov rdi, GL_TEXTURE_2D
   mov rsi, GL_TEXTURE_WRAP_S
   mov rdx, GL_REPEAT
   call glTexParameteri

   mov rdi, GL_TEXTURE_2D
   mov rsi, GL_TEXTURE_WRAP_T
   mov rdx, GL_REPEAT
   call glTexParameteri

   mov rdi, GL_TEXTURE_2D
   call glGenerateMipmap

%endmacro

%macro read_texture 0

   open_file texture_file, fd_in   ;open("textures.ipa");
   check_integrity

   movapd xmm0, [readed_data]
   movapd [textures_sizes], xmm0

   load_texture 0	;skybox
   load_texture 1	;fling
   load_texture 2	;grass

   close_file fd_in  ;close("textures.ipa");

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

%macro load_meshes 0

   open_file mesh_file, fd_in   ;open("meshes.ipa");
   check_integrity

   movapd xmm0, [readed_data]
   movapd [buffers_sizes], xmm0

   load_mesh 0 ;skybox
   load_mesh 1 ;flint

   close_file fd_in  ;close("meshes.ipa");

%endmacro

%macro load_mesh 1

   gen_buffer buffers_ids+(16*%1)
   gen_buffer buffers_ids+8+(16*%1)
   read_file 16

   movapd xmm1, [readed_data]
   movapd [buffers_sizes+16+(16*%1)], xmm1

   mov rdx, [readed_data]
   shl rdx, 5

   read_file_in_rdx

   buffer_data buffers_ids+(16*%1), readed_data, [buffers_sizes+16+(16*%1)]

   mov rdx, [buffers_sizes+24+(16*%1)]
   shl rdx, 2

   read_file_in_rdx

   element_buffer_data buffers_ids+8+(16*%1), readed_data, [buffers_sizes+24+(16*%1)]

%endmacro

%macro read_terrain 0

	mov rax, 3 ;read
	mov rbx, [fd_in]
	mov rcx, terrain_height
	mov rdx, 65536 		; 128*128*sizeof(float) = 65536
	int 0x80

%endmacro

%macro load_terrain 0

   open_file terrain_file, fd_in   ;open("terrain.ipa");
   read_terrain
   close_file fd_in  ;close("terrain.ipa");

   gen_buffer buffers_ids+(16*3)
   gen_buffer buffers_ids+8+(16*3)

   xor rcx,rcx
   movapd xmm7, [mask3]
   movapd xmm6, [terrain_size]
   movapd xmm5, [var1]
   xorpd xmm0, xmm0
   lea rdx, [terrain_height]	;pointer to terrain memory
   lea rbx, [readed_data]		;pointer to memory for graphic card

   jmp terrain_continue

terrain_new_row:

	movapd xmm5, xmm6
	shufps xmm5, xmm5, 225

	shufps xmm0, xmm0, 231
	addps xmm0, xmm5

terrain_continue:
   movapd xmm3, xmm0
   movapd xmm1, [rdx]	;xmm1 = Z1|Z2|Z3|Z4
   ;divps xmm1, xmm4
   movapd xmm2, xmm1
   andps xmm2, xmm7		;xmm2 = Z1|0.0|Z3|Z4

   shufpd xmm3, xmm2, 0 	;xmm3 = x|y|z|0.0
   movapd [rbx], xmm3

   shufpd xmm5, xmm3, 0		;xmm5 = 0.0, 1.0, x, y
   add rbx, 16
   movapd [rbx], xmm5

   addps xmm0, xmm6
   movapd xmm3, xmm0
   shufps xmm1, xmm1, 57	;rotate
   movapd xmm2, xmm1
   andps xmm2, xmm7		;xmm2 = Z2|0.0|Z4|Z1

   shufpd xmm3, xmm2, 0
   add rbx, 16
   movapd [rbx], xmm3

   shufpd xmm5, xmm3, 0		;xmm5 = 0.0, 1.0, x, y
   add rbx, 16
   movapd [rbx], xmm5

   addps xmm0, xmm6
   movapd xmm3, xmm0
   shufps xmm1, xmm1, 57	;rotate
   movapd xmm2, xmm1
   andps xmm2, xmm7		;xmm2 = Z2|0.0|Z4|Z1

   shufpd xmm3, xmm2, 0
   add rbx, 16
   movapd [rbx], xmm3

   shufpd xmm5, xmm3, 0		;xmm5 = 0.0, 1.0, x, y
   add rbx, 16
   movapd [rbx], xmm5

   addps xmm0, xmm6
   movapd xmm3, xmm0
   shufps xmm1, xmm1, 57	;rotate
   movapd xmm2, xmm1
   andps xmm2, xmm7		;xmm2 = Z2|0.0|Z4|Z1

   shufpd xmm3, xmm2, 0
   add rbx, 16
   movapd [rbx], xmm3

   shufpd xmm5, xmm3, 0		;xmm5 = 0.0, 1.0, x, y
   add rbx, 16
   movapd [rbx], xmm5

   add rdx, 16
   add rbx, 16
   addps xmm0, xmm6
   add rcx, 1
   mov r10, 4096
   cmp rcx, r10
   jz terrain_end
   mov rax, rcx
   and rax, 31
   mov r10, 0
   cmp rax, r10
   jz terrain_new_row
   jmp terrain_continue

terrain_end:

	buffer_data buffers_ids+(16*3), readed_data, 16384

	lea rcx, [readed_data]
	mov rdx,1

	movapd xmm3, [element_terrain_constant1]
	movapd xmm4, [element_terrain_constant2]
	movapd xmm5, [element_terrain_constant3]

	movapd xmm6, [element_terrain_add]

	jmp element_terrain_loop

element_terrain_row:

	add rdx, 1

	paddd xmm3, xmm6
	paddd xmm4, xmm6
	paddd xmm5, xmm6

element_terrain_loop:

	movapd [rcx], xmm3
	add rcx, 16
	movapd [rcx], xmm4
	add rcx, 16
	movapd [rcx], xmm5
	add rcx, 16

	paddd xmm3, xmm6
	paddd xmm4, xmm6
	paddd xmm5, xmm6

	add rdx, 1
	mov rax, rdx
	and rax, 63
	cmp rax, 0
	jz element_terrain_row
	mov rax, 7998;8128
	cmp rdx, rax
	jz element_terrain_end
	jmp element_terrain_loop

element_terrain_end:

	sub rcx, readed_data

	element_buffer_data buffers_ids+8+(16*3), readed_data, 95976

%endmacro

%macro draw_skybox 0

   call glPushMatrix
   movapd xmm0, [main_camera + Camera.eyeX]
   movapd xmm1, xmm0
   shufpd xmm1, xmm1, 1
   movapd xmm2, [main_camera + Camera.eyeZ]
   call glTranslated
   bind_texture 0
   draw_mesh 0
   mov rdi, GL_DEPTH_BUFFER_BIT
   call glClear
   call glPopMatrix

%endmacro

%macro draw_terrain 0

	bind_texture 2

	mov rdi, GL_ARRAY_BUFFER
	mov rsi, [buffers_ids+(16*3)]
	call glBindBuffer

	mov rdi, GL_ELEMENT_ARRAY_BUFFER
	mov rsi, [buffers_ids+8+(16*3)]  ;buffers_ids
	call glBindBuffer

	setup_graphic_dataptr

	mov rdi, GL_TRIANGLES
	mov rsi, 95976
	mov rdx, GL_UNSIGNED_INT
	mov rcx, 0
	call glDrawElements

%endmacro

%macro Debug_Vertex_Buffer 1

	movss xmm0, [readed_data+(%1*32)]
   call Debug_tool_float

   movss xmm0, [readed_data+4+(%1*32)]
   call Debug_tool_float

   movss xmm0, [readed_data+8+(%1*32)]
   call Debug_tool_float

   movss xmm0, [readed_data+12+(%1*32)]
   call Debug_tool_float

   movss xmm0, [readed_data+16+(%1*32)]
   call Debug_tool_float

   movss xmm0, [readed_data+20+(%1*32)]
   call Debug_tool_float

   movss xmm0, [readed_data+24+(%1*32)]
   call Debug_tool_float

   movss xmm0, [readed_data+28+(%1*32)]
   call Debug_tool_float

   mov rdi, 99999
   call Debug_tool_decimal
%endmacro

%macro Debug_Element_Buffer 1

	mov edi, [readed_data+(%1*24)]
	call Debug_tool_decimal

	mov edi, [readed_data+4+(%1*24)]
	call Debug_tool_decimal

	mov edi, [readed_data+8+(%1*24)]
	call Debug_tool_decimal

	mov edi, [readed_data+12+(%1*24)]
	call Debug_tool_decimal

	mov edi, [readed_data+16+(%1*24)]
	call Debug_tool_decimal

	mov edi, [readed_data+20+(%1*24)]
	call Debug_tool_decimal

   mov rdi, 99999
   call Debug_tool_decimal
%endmacro

%macro bind_texture 1
   mov rdi, GL_TEXTURE_2D
   mov rsi, [textures_ids+(8*%1)]
   call glBindTexture
%endmacro

%macro draw_mesh 1
   
   mov rdi, GL_ARRAY_BUFFER
   mov rsi, [buffers_ids+(16*%1)]
   call glBindBuffer

   mov rdi, GL_ELEMENT_ARRAY_BUFFER
   mov rsi, [buffers_ids+8+(16*%1)]  ;buffers_ids
   call glBindBuffer

   setup_graphic_dataptr

   mov rdi, GL_TRIANGLES
   mov rsi, [buffers_sizes+24+(16*%1)]
   mov rdx, GL_UNSIGNED_INT
   mov rcx, 0
   call glDrawElements

%endmacro

%macro setup_graphic_dataptr 0
   
   mov rdi, GL_VERTEX_ARRAY
   call glEnableClientState

   mov rdi, GL_NORMAL_ARRAY
   call glEnableClientState

   mov rdi, GL_TEXTURE_COORD_ARRAY
   call glEnableClientState

   mov rdi, 3
   mov rsi, GL_FLOAT
   mov rdx, 32
   mov rcx, 0
   call glVertexPointer

   mov rdi, GL_FLOAT
   mov rsi, 32
   mov rdx, 12
   call glNormalPointer

   mov rdi, 2
   mov rsi, GL_FLOAT
   mov rdx, 32
   mov rcx, 24
   call glTexCoordPointer

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

   open_fullscreen_window

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

   opengl_texture_start 1

   call _timer_start

   read_texture

   mov rcx, func_name_Load_Textures
   call _timer_stop

   ;load_texture 0

   ;call texture_create

   call _timer_start

   load_meshes

   mov rcx, func_name_Load_Meshes
   call _timer_stop

   call _timer_start
   load_terrain
   mov rcx, func_name_Load_Terrain
   call _timer_stop

   mov rdi, main_camera
   update_lookat

   setup_graphic_dataptr


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

;  ____                _           
; |  _ \ ___ _ __   __| | ___ _ __ 
; | |_) / _ \ '_ \ / _` |/ _ \ '__|
; |  _ <  __/ | | | (_| |  __/ |   
; |_| \_\___|_| |_|\__,_|\___|_|   
;

   mov rdi, 0x4100 ;GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT
   call glClear

   mov rdi, GL_MODELVIEW
   call glMatrixMode

   call glLoadIdentity

   ;update_lookat

   mov rax, 0x3FF0000000000000
   push rax

   movapd xmm0, [main_camera + Camera.eyeX]  ;eyeX
   movapd xmm1, xmm0
   shufpd xmm1, xmm1, 1                      ;eyeY
   movapd xmm2, [main_camera + Camera.eyeZ]  ;eyeZ
   movapd xmm3, xmm2
   shufpd xmm3, xmm3, 1                      ;centerX
   movapd xmm4, [main_camera + Camera.centerY]  ;centerY
   movapd xmm5, xmm4
   shufpd xmm5, xmm5, 1                      ;centerZ
   xorpd xmm6, xmm6  ; 0
   xorpd xmm7, xmm7  ; 0

   call gluLookAt
   add rsp, 8

   draw_skybox

   draw_terrain

   bind_texture 1
   draw_mesh 1

   ;mov rdi, GL_VERTEX_ARRAY
   ;call glEnableClientState

   ;mov rdi, GL_NORMAL_ARRAY
   ;call glEnableClientState

   ;mov rdi, GL_TEXTURE_COORD_ARRAY
   ;call glEnableClientState

   ;mov rdi, GL_ARRAY_BUFFER
   ;mov rsi, [buffers_ids]
   ;call glBindBuffer

   ;mov rdi, GL_ELEMENT_ARRAY_BUFFER
   ;mov rsi, [buffers_ids+8]  ;buffers_ids
   ;call glBindBuffer

   ;setup_graphic_dataptr

   ;mov rdi, 3
   ;mov rsi, GL_FLOAT
   ;mov rdx, 32
   ;mov rcx, 0
   ;call glVertexPointer

   ;mov rdi, GL_FLOAT
   ;mov rsi, 32
   ;mov rdx, 12
   ;call glNormalPointer

   ;mov rdi, 2
   ;mov rsi, GL_FLOAT
   ;mov rdx, 32
   ;mov rcx, 24
   ;call glTexCoordPointer

   ;mov rdi, GL_ARRAY_BUFFER
   ;mov rsi, [buffers_ids+8]
   ;call glBindBuffer

   ;mov rdi, GL_TEXTURE_2D
   ;mov rsi, [textures_ids]
   ;call glBindTexture


   ;mov rdi, GL_TRIANGLES           ;;WITH VBO NO LONGER NEEDED
   ;mov rsi, 0 ;first index
   ;mov rdx, [buffers_sizes+16]
   ;call glDrawArrays

   ;mov rdi, GL_ELEMENT_ARRAY_BUFFER
   ;mov rsi, [buffers_ids+8]  ;buffers_ids
   ;call glBindBuffer

   ;mov rdi, GL_TRIANGLES
   ;mov rsi, [buffers_sizes+24]
   ;mov rdx, GL_UNSIGNED_INT
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

end:
       
   mov   eax,1             ;system call number (sys_exit)
   int   0x80              ;call kernel

section  .data
mesh_file db 'meshes.ipa', 0
texture_file db 'textures.ipa', 0
terrain_file db 'terrain.ipa', 0
header db 'xkelem01'

window_title db 'IPA project xkelem01', 0

align 16
stack_start dq 0  ;init as NULL
continuer dq 1

align 16
main_camera dq 2.0, 3.0, 50.0, 0.0, 0.0, 0.0, 0.0, 180.0, 1.0, 0.0

general_switch dd 8, 16, 24, 32, 40, 48, 56, 64

switch1 dd 0x0 , 0x0 , SDL_KEYDOWN , SDL_QUIT
switch1_labels dq default_sw1, default_sw1, default_sw1, KEY_DOWN_sw1, SDL_QUIT_sw1

switch2 dd SDL_SCANCODE_W , SDL_SCANCODE_A , SDL_SCANCODE_S, SDL_SCANCODE_D, SDL_SCANCODE_UP, SDL_SCANCODE_LEFT, SDL_SCANCODE_DOWN, SDL_SCANCODE_RIGHT
switch2_labels dq default_sw1, FORWARD_sw2, LEFT_sw1, BACKWARD_sw2, SDL_QUIT_sw1, FORWARD_sw2, ROTATE_LEFT_sw2, BACKWARD_sw2, ROTATE_RIGHT_sw2

verticles dd 1.0, -1.0, 1.0,    -1.0, -1.0, -1.0,    1.0, -1.0, -1.0
indices dd 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 , 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32,33,34,35,36
test_image dd 1.0, 1.0, 1.0,  0.0,0.0,0.0,  0.0,0.0,0.0,  0.0,0.0,0.0

data dd 0.0,0.0,0.0,0.0,0.0,1.0,0.0,0.0,      1.0,0.0,0.0,0.0,0.0,1.0,1.0,0.0,     0.0,1.0,0.0,0.0,0.0,1.0,0.0,1.0
;32*3

M_PI_DIV_180 dq 0x3F91D746A2529D39

var0 dq 0x0
align 16
var1 dd 0.0, 1.0, 0.0, 0.0
terrain_size dd 4.0, 0.0, 0.0, 0.0
mask3 dd -1, 0, -1, -1
load_terrain_constant100 dd 10.0, 10.0, 10.0, 10.0
element_terrain_constant1 dd 0, 1, 128, 128
element_terrain_constant2 dd 129, 1, 1, 2
element_terrain_constant3 dd 129, 129, 130, 2
element_terrain_add dd 2, 2, 2, 2

timer_fmt db 'rdsct time difference: %d%d cycles (func %s)', 0xa, 0

;function names
func_name_SDL_Init db 'SDL_Init', 0
func_name_SDL_Quit db 'SDL_Quit', 0
func_name_SDL_CreateWindow db 'SDL_CreateWindow', 0
func_name_SDL_GL_CreateContext db 'SDL_GL_CreateContext', 0
func_name_SDL_PollEvent db 'SDL_PollEvent', 0
func_name_Update_LookAt db 'Update_LookAt', 0
func_name_Load_Textures db 'Load_Textures', 0
func_name_Load_Meshes db 'Load_Meshes', 0
func_name_Load_Terrain db 'Load_Terrain', 0

debug_Uint32_fmt db 'output decimal: %d', 0xa, 0
debug_double_fmt db 'output double: %f', 0xa, 0

;insta_args_gluPerspective dq 

section .bss   ;uninitialised data
align 16
xmm_something resq 2
timer_first resq 2 ;first time-stamp for compare (EDX:EAX = 64b)
SDL_event resb 64 ;event handler
align 16
textures_ids resd 16
buffers_ids resq 16
buffers_sizes resq 16
textures_sizes resq 16

fd_out resq 1
fd_in  resq 1
align 16
terrain_height resd 16384
readed_data resd 2097152