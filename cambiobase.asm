segment codigo code
..start:
         mov   ax,datos
         mov   ds,ax
         mov   ax,pila
         mov   ss,ax
         call  prtBienv
         call  abrir
ciclo:    
         call  leer
;         call  validar
         call  procesar
         call  imprimir
         jmp   ciclo
abrir:         
         mov   al,0
         mov   dx,fileName
         mov   ah,3dh
         int   21h
         jc    errAbrir
         mov   [fHandle],ax
         ret
leer:
         mov   bx,[fHandle]
         mov   cx,4
         mov   dx,registro
         mov   ah,3fh
         int   21h
         jc    errLect
         cmp   ax,0
         je    cerrar
         ret
validar:
         mov   si,0
valOtro:
         cmp   byte[registro+si],99h
         jg    errInval
         inc   si
         cmp   si,3
         jl    valOtro
         cmp   byte[registro+si],0Ah
         jl    errInval
         ret
procesar:
         call  cargar
         call  aCaract
         call  cargar
         call  aOctal
         ret

cargar:
         mov   si,0
seguir:
         shl   edx,8
         mov   dl,[registro+si]
         inc   si
         cmp   si,4
         jl    seguir
         ret

aCaract:
         mov   eax,edx
         shl   al,4
         shr   al,4
         add   al,37h
         mov   [linea+7],al
         shr   edx,4
         mov   si,6
aCarOtro:
         mov   eax,edx
         shl   al,4
         shr   al,4
         add   al,30h
         mov   [linea+si],al
         dec   si
         shr   edx,4
         cmp   si,0
         jnl   aCarOtro

         mov   si,0
         mov   di,numero
         mov   cl,7
movOtro:
         mov   dl,[linea+si]
         mov   byte[di],dl
         inc   di
         inc   si
         dec   cl
         cmp   cl,0
         jg    movOtro
         cmp   byte[linea+7],42h
         je    esNeg
         cmp   byte[linea+7],44h
         je    esNeg
         mov   byte[signo],2bh
         jmp   finACar
esNeg:  
         mov   byte[signo],2dh
finACar:
         ret

aOctal:
         mov   si,10
aOcOtro:
         mov   eax,edx
         shl   al,5
         shr   al,5
         add   al,30h
         mov   [lineaB8+si],al
         dec   si
         shr   edx,3
         cmp   si,0
         jnl   aOcOtro
         ret

imprimir:
         mov   dx,linea
         mov   ah,9
         int   21h
         ret
errInval:
         mov   dx,msjErrInval
         mov   ah,9
         int   21h
         jmp   fin
errAbrir:
         mov   dx,msjErrAbrir
         mov   ah,9
         int   21h
         jmp   fin
errLect:
         mov    dx,msjErrLeer
         mov   ah,9
         int   21h
cerrar:
         mov   bx,[fHandle]
         mov   ah,3eh
         int   21h
         jc    errCerr
         jmp   fin
errCerr:
         mov   dx,msjErrCerrar
         mov   ah,9
         int   21h
fin:
         mov   ah,4ch
         int   21h
prtBienv:
         mov   dx,msjBienvenida
         mov   ah,9
         int   21h
         ret

segment datos data

fileName       db  "arch.dat",0
fHandle        resw 1
registro       resb 4
               db  ' $'

linea          resb 8
               db   ' ---- Octal --->> '
lineaB8        resb 11
               db   ' ---- Num --->> '
signo          resb 1
numero         resb 7
               db   0x0a,'$'

msjErrAbrir    db  "Error en apertura$"
msjErrLeer     db  "Error en lectura$"
msjErrCerrar   db  "Error en cierre$"
msjErrInval    db  "Registro invalido$"
msjBienvenida  db  "                   ___  ___     ___  ___ ",0x0a
               db  "                  |_  ||  _|   |   ||_  |",0x0a
               db  "                    | ||_  | _ | | ||_  |",0x0a
               db  "                    |_||___||_||___||___|",0x0a
               db  "  _____         _         _     ____          _           _ ",0x0a
               db  " |  _  |___ ___| |_ ___ _| |   |    \ ___ ___|_|_____ ___| |",0x0a
               db  " |   __| .'|  _| '_| -_| . |   |  |  | -_|  _| |     | .'| |",0x0a
               db  " |__|  |__,|___|_,_|___|___|   |____/|___|___|_|_|_|_|__,|_|",0x0a,"$"

segment pila stack