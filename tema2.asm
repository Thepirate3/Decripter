extern puts
extern printf
section .data
filename: db "./input.dat",0
inputlen: dd 2263
fmtstr: db "Key: %d",0xa,0

section .text
global main

;Functie auxiliara de cautare
cautare_ncuv:
    
    push ebp
    mov ebp,esp
    
    mov eax, [ebp +8]  ; pozitia de start a cuvantului cautat  
    mov ebx, [ebp +12] ; sirul unde caut stringul
    sub ebx,1   ;scad 1 deoarece numerotarea incepe de la 0
 
;Caut finalul stringului vecin celui cautat in functie de poztia acestuia   
cautare_final:
    
    cmp byte [eax],0
    jne increment 
    dec ebx
    inc eax
    test ebx,ebx
    jnz cautare_final
    jmp final    
    
increment:          
    inc eax
    jmp cautare_final
            
final:
    
    leave
    ret                

;Task1-------------------------------
xor_strings:
    
    push ebp
    mov ebp,esp
    
    mov ecx,[ebp +8]    ;memorez adresa stringului criptat
    mov eax,[ebp +12]   ;memorez adresa stringului cheie

;Verific daca nu am ajuns la finalul stringului   
flag1:
    cmp byte[ecx],0
    jne decript
    
    jmp final1

;Decriptez prin xor    
decript:
    mov dl, byte[ecx]   ;mut n dl byte-ul de decriptat
    mov bl, byte[eax]   ;mut in bl byte-ul cheie
    
    xor dl,bl
   
    mov [ecx],dl    ; salvez in place byte-ul decriptat
    inc ecx
    inc eax
    jmp flag1
        
final1:
    leave
    ret
 
;Task2------------------------------------------
rolling_xor:
    push ebp
    mov ebp,esp
    
    mov eax,[ebp+8]     ;salvez stringul criptat
    mov bl,byte [eax]   ;salvez primul byte cheie
    inc eax

;Verific daca am ajuns la finalul stringului    
verificare:
    cmp byte [eax],0
    je final2
        
rol_xor:
    mov dh,byte [eax] ;copiez byte ul de modificat
    xor dh,bl         ;decriptez byte-ul
 
    mov bl, byte[eax] ;salvez byte-ul cheie
    mov [eax],dh      ;fac modificarea in place
    inc eax
    jmp verificare
    
final2:    
    leave
    ret
    
;Task3-----------------------------------------------   

;Functie auxiliara
convert_hex_strings:
    push ebp
    mov ebp,esp
    
     mov ecx,[ebp+8]    ;salvez adresa stringului
     push eax           ;salvez pe stiva registrul
     xor eax,eax
     xor edx,edx
hex:
    xor ebx,ebx
    mov bl,byte [ecx+edx]
    cmp bl,58
    jl decrementare2

;Daca e litera scad 87 pentru a obtine valoarea  
decrementare1:
    sub bl,87
    shl bl,4
    jmp sumare

;Daca e cifra scad 48 pentru a obtine valoarea in 
decrementare2:
    sub bl,48
    shl bl,4    

;Creez noul byte din doi bytes     
sumare:
    mov bh,byte[ecx+edx+1] ;salvez a doua parte
    cmp bh,58
    jl decr2

;O decrementez corespunzator caracterului
decr1:
    sub bh,87
    add bl,bh

    mov byte [ecx+eax],bl
    add edx,2
    inc eax
    cmp byte[ecx+edx],0
    jne hex
    jmp fin3
    
decr2:   
    sub bh,48
    add bl,bh
    mov byte [ecx+eax],bl
    inc eax
    add edx,2
    cmp byte[ecx+edx],0
    
    jne hex
                            
                                                                          
fin3:
    pop eax
    leave
    ret                            
    
;Functie principala 
xor_hex_strings:
    push ebp
    mov ebp,esp
    
    mov ecx,[ebp+8] ;salvez adresa stringului 4
    mov eax,[ebp+12];salvez adresa stringului 5
   
;Convertex primul string in hex     
    push ecx
    call convert_hex_strings
    pop ecx
    
;Repet procedeul pentru cheie
    push ecx
    push eax
    call convert_hex_strings
    pop eax
    pop ecx
    
;Apelez functia utilizata la task-ul 1   
    push eax
    push ecx
    call xor_strings
    pop ecx
    pop eax
    
   leave
   ret
   
;Task4-------------------------------------
base32decode:
    push ebp
    mov ebp,esp
    
    mov eax, [ebp+8] ;salvez adresa stringului
    xor ecx,ecx

;Memorez numarul de biti pe care-i pot folosi       
    mov bl,5   
    push ecx
    
flag4:
    mov dl,[eax]    ;salvez primul byte criptat
    mov dh,[eax +1] ;salvez urmatorul byte criptat

;Decriptez byte-ul conform tabelei de conversiei    
    cmp dl,65   
    jl cifra
    sub dl,65
    jmp next
cifra:
    sub dl,24

next:
    cmp dh,65
    jl cifra1
    sub dh,65
    jmp next1
cifra1:
    sub dh,24

      
next1:    
    mov cl,8    ;salvez numaru de biti
    sub cl,bl   ;aflam cu cat shiftam primul byte
    shl dl,cl   ;shiftez primul byte
    
 
    push ebx    ;salvez numarul de biti folositi
    cmp cl,5    ;daca nu am nevoie de mai mult de 5 biti
    jle fl      
    sub cl,5    ;iau toti cei 5 biti ai byte-ul
    shl dh,cl   
    mov cl,5
    add dl,dh
    jmp revenire
    
;Daca am nevoie de mai putin de 5 biti pentru completare   
fl:
    mov bl,cl
    mov cl,5
    sub cl,bl    
    shr dh,cl
    mov cl,bl
;Compun byte-ul iar daca mai am nevoie de biti sar  
revenire:
    pop ebx
    add bl,cl
    cmp bl,8
    jl inca_cuv
    
copiere:
    add dl,dh

    mov bl,5
    sub bl,cl ;memorez cati biti am in urmatoarea trecere
    
    pop ecx
    push eax
    mov eax,[ebp+8]
    mov [eax+ecx],dl
    pop eax
    inc ecx
    push ecx ;pozitia byte-ului decriptat in string
    inc eax
    cmp byte[eax+1],0x00 ;verific daca nu am terminat
    jne flag4
    jmp fin4
    
;Daca doi bytes nu au fost de ajuns   
inca_cuv:
    mov dh,byte[eax+2]
    
    cmp dh,65
    jl cifra2
    sub dh,65
    jmp next2
cifra2:
    sub dh,24
next2:
    mov cl,8
    sub cl,bl
    
    mov bl,5
    sub bl,cl
    
    mov cl,bl
    shr dh,cl
    add dl,dh
    
    pop ecx
    push eax
   
    mov eax,[ebp+8]
    mov [eax+ecx],dl
    pop eax
    cmp byte[eax],0x00
    je fin4
    
    add eax,2
    inc ecx
    push ecx
    
    jmp flag4     
    
    
fin4:
    pop ecx
    mov eax,[ebp+8]
    sub ecx,3
    mov byte[eax +ecx],0 ;inchei stringul decriptat
    leave 
    ret
    
;Task5-----------------------------------------------
bruteforce_singlebyte_xor:   
    push ebp
    mov ebp,esp
    
    push ecx
    push eax
    
    mov ebx,[ebp+8] ;salvez adresa stringului
    
    xor ecx,ecx
    
flag5:
    mov al,byte[ebx]
    cmp al,0x00 ;verific finalul stringului
    je increment_key
    xor al,cl
    cmp al,'f' ;daca gasesc 'f' continui
    jne increment_ebx
    
    inc ebx
    
    mov al,byte[ebx]
    cmp al,0x00
    je increment_key     
    xor al,cl
    cmp al,'o'
    jne increment_ebx
    
    inc ebx
    mov al,byte[ebx]
    cmp al,0x00
    je increment_key     
    xor al,cl
    cmp al,'r'
    jne increment_ebx
    
    inc ebx
    mov al,byte[ebx]
    cmp al,0x00
    je increment_key   
    xor al,cl
    cmp al,'c'
    jne increment_ebx
    
    inc ebx
    mov al,byte[ebx]
    cmp al,0x00
    je increment_key 
    xor al,cl
    cmp al,'e'
    jne increment_ebx
    
    jmp decriptare
    
increment_ebx:
    inc ebx ;nu am gasit o litera corespunzatoare 'force'
    jmp flag5   
;Nu am gasit cuvantul 'force' incercam alta cheie
increment_key:
    mov ebx,[ebp+8]
    inc cl
    cmp cl,0xff
    je fin5
    jmp flag5
    
decriptare:
    mov ebx,[ebp+8] ;am repozitionez la inceput

;Decriptez cuvantul dupa ce am gasit cheia        
repeta:
    mov al,byte[ebx]
    xor al,cl
    mov byte[ebx],al
    inc ebx
    cmp byte[ebx],0x00
    jne repeta

fin5:
    pop eax
    mov edx,[ebp+12] ;memorez adresa cheii
    
    mov [edx],ecx;  ;salvez adresa cheii
   
    pop ecx
    
    leave
    ret    
    
    
    
;Main---------------------------------   
main:

    
    mov ebp, esp; for correct debugging
    push ebp
    mov ebp, esp
    sub esp, 2300
    
    ; fd = open("./input.dat", O_RDONLY);
    mov eax, 5
    mov ebx, filename
    xor ecx, ecx
    xor edx, edx
    int 0x80
    
	; read(fd, ebp-2300, inputlen);
	mov ebx, eax
	mov eax, 3
	lea ecx, [ebp-2300]
	mov edx, [inputlen]
	int 0x80

       
	; close(fd);
	mov eax, 6
	int 0x80

	; all input.dat contents are now in ecx (address on stack)

	
;Task1-----------------------------------------------------------------------
        
        push edx    ; salvam pe stiva edx
        push ebx    ; salvam pe stiva ebx
        
        ;Apelam functia de cautare a adresei stringului
        mov eax,2
        push eax    ; punem pe stiva numarul stringului de cautat
        push ecx    ; punem pe stiva unde cautam
        call cautare_ncuv 
        pop ecx     ; restauram adresa de inceput a stringului
        add esp,4   ; refacem stiva
       
        
        push eax    ;push addr_str2
        push ecx    ;push addr_str1
        call xor_strings
        pop ecx     ;refacem ecx
        add esp,4   ;restauram stiva
        
      
	; Print the first resulting string
        push ecx    ;push addr_str1
        call puts
	pop ecx    ;restauram ecx



;TASK2---------------------------------------------------------
       
        ;Caut al 3 lea string
        mov eax,3
        push eax    ; punem pe stiva numarul stringului de cautat
        push ecx    ; punem pe stiva unde cautam
        call cautare_ncuv ;caut al 3 lea string
        pop ecx     ; restauram ecx
        add esp,4   ; restauram stiva
        
        
         
        push eax  ;push addr_str3
        call rolling_xor
        pop eax   ;refacem eax
        
        
        ; Printez al doilea string rezultat
        push ecx  ;salvam ecx pentru a nu fi modificat
        push eax  
        call puts
        add esp,4
        pop ecx   ;restauram ecx
        

;TASK3----------------------------------------------------
 
        ;Caut al 4 lea string
        mov eax,5
        push eax
        push ecx
        call cautare_ncuv 
        pop ecx
        add esp,4
        
        push eax   ;push addr_str5
        
        ;Caut al 5 lea string
        mov eax,4
        push eax
        push ecx
        call cautare_ncuv 
        pop ecx
        add esp,4
        	
        push eax    ;push addr_str4
       
        
	call xor_hex_strings
	pop ecx
        add esp,4   ;refac stiva
        
        ; Printez al treilea string
        push ecx    ;push addr_str4
        call puts
        pop ecx
    
;Task4------------------------------------------------------------------------	
	

        ;Caut al 6 lea string
        mov eax,6
        push eax
        push ecx
        call cautare_ncuv 
        pop ecx
        add esp,4
   
        push ecx    ;salvez ecx-ul 
        push eax    ;push addr_str6

	call base32decode
	pop eax
        
       ; Printez al 4 lea string
        push eax
        call puts
        pop eax
        pop ecx 
	

;Task5-----------------------------------------------------------------------------
	

        ;Retrag toate elementele de pe stiva pentru a aloca loc pentru key
        pop eax
        pop ebx
        pop edx
       
       ; Rezerv spatiu cheii
        sub esp,4
        lea edx,[esp]
       
        push edx    ;push key_addr
        
        ;Caut al 7 lea string
        mov eax,8
        push eax
        push ecx
        call cautare_ncuv 
        pop ecx
        add esp,4
        
        push eax    ;push addr_str7
        call bruteforce_singlebyte_xor
        pop eax
 
	; Printez al 5 lea string 
        push ecx
        push eax
        call puts
        add esp, 4
        pop ecx
        
        ; Printez cheia gasita
        pop edx
        mov eax,[edx]  ; salvez cheia de la adresa rezevata
        push eax       ; pun cheia pe stiva de printat
        push fmtstr
        call printf
        add esp, 8

;Task 6-----------------------------------------------------------------------------
	; TASK 6: Break substitution cipher
	; TODO: determine address on stack for string 8
	; TODO: implement break_substitution
	;push substitution_table_addr
	;push addr_str8
	;call break_substitution
	;add esp, 8

	; Print final solution (after some trial and error)
	;push addr_str8
	;call puts
	;add esp, 4

	; Print substitution table
	;push substitution_table_addr
	;call puts
	;add esp, 4

	; Phew, finally done
    

fi:
    xor eax, eax
    leave
    ret
