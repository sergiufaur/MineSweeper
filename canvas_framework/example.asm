.586
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Exemplu proiect desenare",0
area_width EQU 640
area_height EQU 480
area DD 0

counter DD 0 ; numara evenimentele de tip timer
format db "%d %d ",0
Nr_bomb dd 0
button_start db 0
m dd 0,0,0,0,0,0,0,0
  dd 0,0,0,0,0,0,0,0
  dd 0,0,0,0,0,0,0,0
  dd 0,0,0,0,0,0,0,0
  dd 0,0,0,0,0,0,0,0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

button_x EQU 25
button_y EQU 377
Button_width EQU 80
button_height EQU 40

table_x EQU 180
table_y EQU 200
table_width EQU 400
table_height EQU 250

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

line_horizontal macro x,y,len,color
local bucla_line
	mov eax,y
	mov ebx,area_width
	mul ebx
	add eax,x
	shl eax,2
	add eax ,area
	mov ecx,len
	bucla_line:
	mov dword ptr[eax],color
	add eax,4
	loop bucla_line
endm
line_vertical macro x,y,len,color
local bucla_line
	mov eax,y
	mov ebx,area_width
	mul ebx
	add eax,x
	shl eax,2
	add eax ,area
	mov ecx,len
	bucla_line:
	mov dword ptr[eax],color
	add eax,area_width*4
	loop bucla_line
endm

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:
	mov eax,[ebp+arg2]
	cmp eax,button_x
	jl button_fail
	cmp eax,button_x+Button_width
	jg button_fail
	mov eax,[ebp+arg3]
	cmp eax,button_y
	jl button_fail
	cmp eax,button_y+button_height
	jg button_fail
	
	inc button_start
	line_horizontal 180,200,400,0
	line_vertical 180,200,250,0
	line_horizontal 180,450,400,0
	line_vertical 580,200,250,0
	line_horizontal 180,250,400,0
	line_horizontal 180,300,400,0
	line_horizontal 180,350,400,0
	line_horizontal 180,400,400,0
	line_vertical 230,200,250,0
	line_vertical 280,200,250,0
	line_vertical 330,200,250,0
	line_vertical 380,200,250,0
	line_vertical 430,200,250,0
	line_vertical 480,200,250,0
	line_vertical 530,200,250,0
	
	xor eax ,eax
	xor edx,edx
	xor ecx,ecx
	xor ebx,ebx
	rdtsc
	mov ebx,0
	xor eax,ebx
	mov ecx,5
	xor edx ,edx
	div ecx
	push edx
	
	xor eax ,eax
	xor edx,edx
	xor ecx,ecx
	xor ebx,ebx
	rdtsc
	mov ebx,1
	xor eax,ebx
	mov ecx,8
	xor edx ,edx
	div ecx
	mov ebx,edx
	pop edx
	
	
	xor ecx,ecx
	mov ecx,8
	xor eax,eax
	mov eax,edx
	mul ecx
	add eax,ebx
	mov ecx,11
	mov [m+eax*4],ecx
	
	xor eax ,eax
	xor edx,edx
	xor ecx,ecx
	xor ebx,ebx
	rdtsc
	mov ebx,0
	xor eax,ebx
	mov ecx,5
	xor edx ,edx
	div ecx
	push edx
	
	xor eax ,eax
	xor edx,edx
	xor ecx,ecx
	xor ebx,ebx
	rdtsc
	mov ebx,1
	xor eax,ebx
	mov ecx,8
	xor edx ,edx
	div ecx
	mov ebx,edx
	pop edx
	
	
	xor ecx,ecx
	mov ecx,8
	xor eax,eax
	mov eax,edx
	mul ecx
	add eax,ebx
	mov ecx,11
	mov [m+eax*4],ecx
	
	xor eax ,eax
	xor edx,edx
	xor ecx,ecx
	xor ebx,ebx
	rdtsc
	mov ebx,0
	xor eax,ebx
	mov ecx,5
	xor edx ,edx
	div ecx
	push edx
	
	xor eax ,eax
	xor edx,edx
	xor ecx,ecx
	xor ebx,ebx
	rdtsc
	mov ebx,1
	xor eax,ebx
	mov ecx,8
	xor edx ,edx
	div ecx
	mov ebx,edx
	pop edx
	
	
	xor ecx,ecx
	mov ecx,8
	xor eax,eax
	mov eax,edx
	mul ecx
	add eax,ebx
	mov ecx,11
	mov [m+eax*4],ecx
	
	xor eax ,eax
	xor edx,edx
	xor ecx,ecx
	xor ebx,ebx
	rdtsc
	mov ebx,0
	xor eax,ebx
	mov ecx,5
	xor edx ,edx
	div ecx
	push edx
	
	xor eax ,eax
	xor edx,edx
	xor ecx,ecx
	xor ebx,ebx
	rdtsc
	mov ebx,1
	xor eax,ebx
	mov ecx,8
	xor edx ,edx
	div ecx
	mov ebx,edx
	pop edx
	
	
	xor ecx,ecx
	mov ecx,8
	xor eax,eax
	mov eax,edx
	mul ecx
	add eax,ebx
	mov ecx,11
	mov [m+eax*4],ecx
	
	xor eax ,eax
	xor edx,edx
	xor ecx,ecx
	xor ebx,ebx
	rdtsc
	mov ebx,0
	xor eax,ebx
	mov ecx,5
	xor edx ,edx
	div ecx
	push edx
	
	xor eax ,eax
	xor edx,edx
	xor ecx,ecx
	xor ebx,ebx
	rdtsc
	mov ebx,1
	xor eax,ebx
	mov ecx,8
	xor edx ,edx
	div ecx
	mov ebx,edx
	pop edx
	
	
	xor ecx,ecx
	mov ecx,8
	xor eax,eax
	mov eax,edx
	mul ecx
	add eax,ebx
	mov ecx,11
	mov [m+eax*4],ecx
	
	xor eax ,eax
	xor edx,edx
	xor ecx,ecx
	xor ebx,ebx
	rdtsc
	mov ebx,0
	xor eax,ebx
	shl eax,2
	mov ecx,5
	xor edx ,edx
	div ecx
	push edx
	
	xor eax ,eax
	xor edx,edx
	xor ecx,ecx
	xor ebx,ebx
	rdtsc
	mov ebx,1
	xor eax,ebx
	shl eax,2
	mov ecx,8
	xor edx ,edx
	div ecx
	mov ebx,edx
	pop edx
	
	
	xor ecx,ecx
	mov ecx,8
	xor eax,eax
	mov eax,edx
	mul ecx
	add eax,ebx
	mov ecx,11
	mov [m+eax*4],ecx
	
	xor eax ,eax
	xor edx,edx
	xor ecx,ecx
	xor ebx,ebx
	rdtsc
	mov ebx,0
	xor eax,ebx
	mov ecx,5
	xor edx ,edx
	div ecx
	push edx
	
	xor eax ,eax
	xor edx,edx
	xor ecx,ecx
	xor ebx,ebx
	rdtsc
	mov ebx,1
	xor eax,ebx
	shl eax,1
	mov ecx,8
	xor edx ,edx
	div ecx
	mov ebx,edx
	pop edx
	
	
	xor ecx,ecx
	mov ecx,8
	xor eax,eax
	mov eax,edx
	mul ecx
	add eax,ebx
	mov ecx,11
	mov [m+eax*4],ecx
	
	
	
	
	
	
	
	
	
	
	
button_fail:
	xor edx ,edx
	mov dl,button_start
	cmp dl,0
	je afisare_litere
	
	
	
	
	xor eax,eax
	mov eax,[ebp+arg2]
	cmp eax,table_x
	jl table_fail
	cmp eax,table_x+table_width
	jg table_fail
	mov eax,[ebp+arg3]
	cmp eax,table_y
	jl table_fail
	cmp eax,table_y+table_height
	jg table_fail
	
	xor eax,eax
	xor edx,edx
	 mov eax,[ebp+arg2]
	 sub eax,table_x
	 xor ecx,ecx
	 mov ecx,50
	 div ecx
	 xor ebx,ebx
	 mov ebx,eax
	
	 
	xor eax,eax
	xor edx,edx
	mov eax,[ebp+arg3]
	 sub eax,table_y
	 xor ecx,ecx
	 mov ecx,50
	 div ecx
	 xor edx,edx
	 push eax
	


	xor ecx,ecx
	mov ecx,8
	mov eax,ebx
	mul ecx
	xor edx,edx
	pop edx
	add eax,edx
	mov ecx,11
	cmp	[m+eax*4],ecx
	je afis_bomba
	
	
	
	mov Nr_bomb,0
	cmp edx,7
	je comp_2
	cmp [m+eax*4+4],ecx
	jne comp_2
	inc Nr_bomb
	comp_2:
	cmp edx,0
	je comp_3
	cmp [m+eax*4-4],ecx
	jne comp_3
	inc Nr_bomb
	comp_3:
	cmp edx,7
	je comp_4
	cmp ebx,0
	je comp_4
	cmp [m+eax*4-7*4],ecx
	jne comp_4
	inc Nr_bomb
	comp_4:
	cmp ebx,0
	je comp_5
	cmp [m+eax*4-8*4],ecx
	jne comp_5
	inc Nr_bomb
	comp_5:
	cmp edx,0
	je comp_6
	cmp ebx,0
	je comp_6
	cmp [m+eax*4-9*4],ecx
	jne comp_6
	inc Nr_bomb
	comp_6:
	cmp edx,0
	je comp_7
	cmp ebx,4
	je comp_7
	cmp [m+eax*4+7*4],ecx
	jne comp_7
	inc Nr_bomb
	comp_7:
	cmp ebx,4
	je comp_8
	cmp [m+eax*4+8*4],ecx
	jne comp_8
	inc Nr_bomb
	comp_8:
	cmp edx,7
	je Afis_cifre
	cmp ebx,4
	je Afis_cifre
	cmp [m+eax*4+9*4],ecx
	jne Afis_cifre
	inc Nr_bomb
	


Afis_cifre:

xor eax,eax
 xor ebx ,ebx
	mov eax,[ebp+arg2]
	   sub eax,table_x
	 xor ecx,ecx
	 mov ecx,50
	 div ecx
	 xor edx,edx
	 mul ecx
	 add eax,table_x
	 add eax,15
	 mov ebx,eax
	 
	 xor eax,eax
	 mov eax,[ebp+arg3]
	 sub eax,table_y
	 xor ecx,ecx
	 mov ecx,50
	 div ecx
	 xor edx,edx
	 mul ecx
	 add eax,table_y
	 add eax,10
	 xor edx,edx
	 mov edx,Nr_bomb
	 cmp edx,0
	 jne v_1
	  make_text_macro '0', area, ebx, eax
	  jmp afisare_litere
	  v_1:
	  cmp edx,1
	 jne v_2
	  make_text_macro '1', area, ebx, eax
	  jmp afisare_litere
	  v_2:
	  cmp edx,2
	 jne v_3
	  make_text_macro '2', area, ebx, eax
	  jmp afisare_litere
	  v_3:
	  cmp edx,3
	 jne v_4
	  make_text_macro '3', area, ebx, eax
	  jmp afisare_litere
	  v_4:
	  cmp edx,4
	 jne v_5
	  make_text_macro '4', area, ebx, eax
	  jmp afisare_litere
	  v_5:
	  cmp edx,5
	 jne v_6
	  make_text_macro '5', area, ebx, eax
	  jmp afisare_litere
	  v_6:
	  cmp edx,6
	 jne afisare_litere
	  make_text_macro '6', area, ebx, eax
	  jmp afisare_litere
	  
	 
 afis_bomba :
 xor eax,eax
 xor ebx ,ebx
	mov eax,[ebp+arg2]
	 
	  sub eax,table_x
	 xor ecx,ecx
	 mov ecx,50
	 div ecx
	 xor edx,edx
	 mul ecx
	 add eax,table_x
	 add eax,15
	 mov ebx,eax
	 xor eax,eax
	 mov eax,[ebp+arg3]
	 sub eax,table_y
	 xor ecx,ecx
	 mov ecx,50
	 div ecx
	 xor edx,edx
	 mul ecx
	 add eax,table_y
	 add eax,10
	 make_text_macro 'B', area, ebx, eax
	 
	 
	 line_horizontal 285,85,120,0
	line_vertical 285,85,50,0
	line_horizontal 285,135,120,0
	line_vertical 405,85,50,0
	make_text_macro 'G', area, 295, 110
	make_text_macro 'A', area, 305, 110
	make_text_macro 'M', area, 315, 110
	make_text_macro 'E', area, 325, 110
	make_text_macro 'O', area, 345, 110
	make_text_macro 'V', area, 355, 110
	make_text_macro 'E', area, 365, 110
	make_text_macro 'R', area, 375, 110
	dec button_start
	
	
	
table_fail	:
	jmp afisare_litere
	
evt_timer:
	inc counter
	
afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	;scriem un mesaj
	make_text_macro 'P', area, 110, 100
	make_text_macro 'R', area, 120, 100
	make_text_macro 'O', area, 130, 100
	make_text_macro 'I', area, 140, 100
	make_text_macro 'E', area, 150, 100
	make_text_macro 'C', area, 160, 100
	make_text_macro 'T', area, 170, 100
	
	make_text_macro 'L', area, 130, 120
	make_text_macro 'A', area, 140, 120
	
	make_text_macro 'A', area, 100, 140
	make_text_macro 'S', area, 110, 140
	make_text_macro 'A', area, 120, 140
	make_text_macro 'M', area, 130, 140
	make_text_macro 'B', area, 140, 140
	make_text_macro 'L', area, 150, 140
	make_text_macro 'A', area, 160, 140
	make_text_macro 'R', area, 170, 140
	make_text_macro 'E', area, 180, 140
	
	
	
	line_horizontal button_x,button_y,Button_width,0
	line_vertical button_x,button_y,button_height,0
	line_horizontal button_x,button_y+button_height,Button_width,0
	line_vertical button_x+Button_width,button_y,button_height,0
	make_text_macro 'S', area, 35, 390
	make_text_macro 'T', area, 45, 390
	make_text_macro 'A', area, 55, 390
	make_text_macro 'R', area, 65, 390
	make_text_macro 'T', area, 75, 390
final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
