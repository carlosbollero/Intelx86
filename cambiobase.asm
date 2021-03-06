;*************************************************************************
; 75.03 ORGANIZACION DEL COMPUTADOR                                      *
;                                                                        *
;                   Intel 80x86 Packed Decimal (II)                      *
; Se pide desarrollar un programa en assembler Intel 80x86 que lea       *
; desde un archivo registros de 4 bytes que representan la configuración *
; binaria de números almacenados en formato BCD (decimal  empaquetado).  *
; Deberá permitir visualizar por pantalla su configuración octal y además*
; el número almacenado, en base 10.                                      *
; Nota: no es correcto generar el archivo con un editor de textos de     *
; forma tal que cada registro sea una tira de 16 caracteres de los rangos*
; 0..9 y A..F. Se aconseja el uso de un editor hexadecimal.              *
;*************************************************************************

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
         call  validar
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
         mov   dx,0
         mov   dh,byte[registro+si]
         shr   dx,4
         shr   dl,4
         cmp   dh,09h
         jg    errInval
         cmp   dl,09h
         jg    errInval
         inc   si
         cmp   si,3
         jl    valOtro
         mov   dx,0
         mov   dh,byte[registro+si]
         shr   dx,4
         shr   dl,4
         cmp   dh,09h
         jg    errInval
         cmp   dl,0Ah
         jl    errInval
         ret
procesar:
         call  cargar
         call  aCaract
         call  cargar
         call  aOctal
         call  empaqABin
         call  binAOctal
         ret

; Carga el registro de como si fuera Big-Endian,
; entonces carga 1234567F en lugar de cargar 7F563412
cargar:
         mov   si,0
         mov   edx,0
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
         mov   [empaquetado+7],al
         shr   edx,4
         mov   si,6
aCarOtro:
         mov   eax,edx
         shl   al,4
         shr   al,4
         add   al,30h
         mov   [empaquetado+si],al
         dec   si
         shr   edx,4
         cmp   si,0
         jnl   aCarOtro

         mov   si,0
         mov   di,numero
         mov   cl,7
movOtro:
         mov   dl,[empaquetado+si]
         mov   byte[di],dl
         inc   di
         inc   si
         dec   cl
         cmp   cl,0
         jg    movOtro
         cmp   byte[empaquetado+7],42h
         je    esNeg
         cmp   byte[empaquetado+7],44h
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

empaqABin:
         mov   cx,0
         mov   dword[numBin],0
         mov   eax,0
         call  cargar
         shr   edx,4
         mov   ebx,0
         mov   bl,dl
         shl   bl,4
         shr   bl,4
         add   dword[numBin],ebx
siguiente:
         mov   ebx,0
         shr   edx,4
         mov   bl,dl
         shl   bl,4
         shr   bl,4

         mov   eax,10
         push  cx
         cmp   cx,0
         je    salto
mult:
         push  edx
         mul   dword[diez]
         pop   edx
         loop  mult
salto:
         push  edx
         mul   ebx
         pop   edx
         add   dword[numBin],eax
         pop   cx
         inc   cx
         cmp   cx,6
         jl    siguiente
finABin:
         ret

binAOctal:
         mov   si,0
         mov   cx,8
blanquear:
         mov   byte[octal+si],30h
         loop  blanquear
         mov   ebx,[octal]
         mov   ecx,[octal+4]
         mov   edx,0
         mov   edx,[numBin]
         mov   si,7
numOcOtro:
         mov   eax,edx
         shl   al,5
         shr   al,5
         add   al,30h
         mov   [octal+si],al
         dec   si
         shr   edx,3
         cmp   si,0
         jnl   numOcOtro
         mov   dl,byte[signo]
         mov   byte[signoOct],dl
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
         jmp   ciclo
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

linea          resb 0
empaquetado    resb 8
               db   ' ---->> '
lineaB8        resb 11
               db   '        Num : '
signo          resb 1
numero         resb 7
               db   ' ---->> '
signoOct       resb 1
octal          resb 8
               db   0x0a,"$"
numBin      resb 4
diez           dd   10

msjErrAbrir    db  "Error en apertura$"
msjErrLeer     db  "Error en lectura$"
msjErrCerrar   db  "Error en cierre$"
msjErrInval    db  "Registro invalido$"
msjBienvenida  db  "                    ___  ___     ___  ___ ",0x0a
               db  "                   |_  ||  _|   |   ||_  |",0x0a
               db  "                     | ||_  | _ | | ||_  |",0x0a
               db  "                     |_||___||_||___||___|",0x0a
               db  "   _____         _         _     ____          _           _ ",0x0a
               db  "  |  _  |___ ___| |_ ___ _| |   |    \ ___ ___|_|_____ ___| |",0x0a
               db  "  |   __| .'|  _| '_| -_| . |   |  |  | -_|  _| |     | .'| |",0x0a
               db  "  |__|  |__,|___|_,_|___|___|   |____/|___|___|_|_|_|_|__,|_|",0x0a
               db  "  ",0x0a
               db  "Empaquetado |  Octal c/formato  |  Num sin Formato   |  Octal s/formato",0x0a,"$"

segment pila stack