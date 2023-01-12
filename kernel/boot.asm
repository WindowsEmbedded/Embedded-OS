

CYLS   equ   10               

  org   0x7c00            


  jmp   entry           
  nop                    
  db    "EMBEDDED"   
  dw    512             
  db    1               
  dw    1            
  db    2         
  dw    224           
  dw    2880             
  db    0xf0             
  dw    9                 
  dw    18                
  dw    2                 
  dd    0                 
  dd    2880              
  db    0                 
  db    0                 
  db    0x29              
  dd    0xffffffff        
  db    "EMBEDDEDDOS"     
  db    "FAT12   "        
  resb  18                



entry:
  mov   ax, 0             
  mov   ss, ax
  mov   sp, 0x7c00
  mov   ds, ax

; 读盘
  mov   ax, 0x0820
  mov   es, ax
  mov   ch, 0       
  mov   dh, 0       
  mov   cl, 2        

readloop:
  mov   si, 0         
retry:
  mov   ah, 0x02      
  mov   al, 1       
  mov   bx, 0
  mov   dl, 0x00 
  int	13h     
  jnc   next            

  add   si, 1     
  cmp   si, 5         
  jae   error       
  mov   ah, 0x00
  mov   dl, 0x00      
  int	13h        ; 重置驱动器
  jmp   retry

next:
  mov	ax,es     
  add   ax, 0x0020
  mov	es,ax  

  add   cl, 1        
  cmp   cl, 18     
  jbe   readloop   

  mov   cl, 1         

  add   dh, 1
  cmp   dh, 2
  jb    readloop    

  mov   dh, 0

  add   ch, 1
  cmp   ch, CYLS
  jb    readloop          


  mov   [0x0ff0], CH      
  jmp   0xc200 ;跳转到内存的0xc200处

fin:
  hlt                    
  jmp   fin 

error:
  mov   si, msg

print:
  mov   al, [si]
  add   si, 1      
  cmp   al, 0

  je    fin
  mov   ah, 0x0e      
  MOV   bx, 15       
  int   10h            
  jmp   print

msg:
  db    0x0a, 0x0a     
  db    "ERROR:kernel.bin IS NOT FOUND"
  db    0x0a          
  db    0

  resb  0x1fe - ($ - $$)  
  db    0x55, 0xaa