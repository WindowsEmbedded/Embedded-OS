org 0xc200
jmp near start
;testmsg db "hello world",'$'
inputdup db "                                               "
welcomemsg db "Welcome to Embedded OS v0.01:Alpha 1",0dh,0ah,'$'
prompt db ">>>",'$'
unknownmsg db "Unknown command",0dh,0ah,'$'
vercmdmsg db "v0.01:Alpha 1",0dh,0ah,'$'

vercom db "ver"
start:
	mov ax,0
	mov ds,ax
	mov es,ax
	mov sp,0xc200
	
	mov si,welcomemsg
	call print
putstart:	
	call newline
	mov si,prompt
	call print
	mov si,0
usrinput:
	mov ah,0
	int 16h ;输入一个字符
	cmp al,08h ;退格键
	je .backspace
	mov ah,0eh
	int 10h ;然后把输入的字符显示出来
	
	cmp al,0dh
	je .over ;回车键输入结束
	
	
	mov [inputdup+si],al
	inc si
	
	jmp usrinput
.backspace: ;退格
	cmp si,0
	je usrinput
	dec si
	mov word[inputdup+si],' ' ;删除字符
	mov al,08h
	mov ah,0eh
	int 10h
	mov al,' '
	int 10h
	mov al,08h
	int 10h
	jmp usrinput
	
.over:
	cmp byte[inputdup],"                                               " ;判断是否输入
	je .noneinput
	call cmdswitch
	jmp putstart
.noneinput:
	call newline
	jmp putstart
print:
	mov al,[si]
	cmp al,'$' 
	je .end
	mov ah,0eh
	int 10h
	inc si ;;si指向下一个字符
	jmp print
	call .end
.end:
	ret
newline:
	;新行
	mov ah,0eh
	mov al,0dh
	int 10h
	mov al,0ah
	int 10h
	ret
cmdswitch:
	mov si,0
	mov cx,3
.nextcom1:
	mov ah,[vercom+si]
	mov al,[inputdup+si]
	cmp al,ah
	jne .unknowncmd
	inc si
	loop .nextcom1
	jmp .ver
.unknowncmd:
	call newline
	mov si,unknownmsg
	call print
	jmp .dealover
.ver:
	call newline
	mov si,vercmdmsg
	call print
	jmp .dealover
.dealover:
	mov si,0
	mov byte[inputdup],"                                              "
.end:
	ret
	