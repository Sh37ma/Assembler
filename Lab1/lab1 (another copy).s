.data
SYSREAD = 0
SYSWRITE = 1
SYSEXIT = 60
STDOUT = 1
STDIN = 0
EXIT_SUCCESS = 0
POCZATEK = 0
KONIEC = 7

tekstN: .ascii "Niepoprawne dane\n"
tekstN_len = .-tekstN

tekstP: .ascii "Poprawne dane\n"
tekstP_len = .-tekstP

BUFLEN = 512

.bss
.comm liczba_u8, 512
.comm odwrotna_u6, 512
.comm liczba_u6, 512

.text
.global main

main:
movq $SYSREAD, %rax	#wczytanie z klawiatury
movq $STDIN, %rdi
movq $liczba_u8, %rsi
movq $BUFLEN, %rdx
syscall

jmp e_sprawdzZnak
#____________________________
e_sprawdzZnak:

mov $0, %rbx
mov $0, %rdi
mov liczba_u8(, %rdi, 1), %bl	#odczyt pierwszej liczby
sub $48, %bl			#zamiana na liczbe z ascii

cmp $3, %bl
jg e_ujemnyZnak
jmp e_dodatniZnak

#____________________
e_ujemnyZnak:			#zapis 1 do %cl, jak liczba pobrana jest ujemna
mov $0, %rcx
mov $1, %cl
jmp e_dalej

#___________________
e_dodatniZnak:			#zapis 0 do %cl, jak liczba pobrana jest dodatnia
mov $0, %rcx
mov $0, %cl
jmp e_dalej

#_____________________________________________________________________________________________
e_dalej:

dec %rax		#'\n'
dec %rax		#liczymy od 0

mov $1, %rsi		#8^0 czyli 1
mov $0, %r8		#pojemnik na wynik
movq %rax, %rdi		#kopiuj dlugosc tekstu, licznik od konca 

jmp e_mnozenie
#_________________________
e_mnozenie:

cmp $0, %rdi	
jl e_zakonczenieMnozenia
mov $0, %rax			#zerowanie rax
mov liczba_u8(, %rdi, 1), %al	#odczyt ostatniej liczby
sub $48, %al			#z ascii na liczbe

#cmp $8, %al			#czy liczba jest w u8
#jge blad
#cmp $0, %al
#jl blad

mul %rsi			#mnozenie rax przed aktualna potege 8-ki	
add %rax, %r8			#dodanie do naszego wyniku

mov %rsi, %rax			#zwiekszenie potegi *8
mov $8, %rbx
mul %rbx
mov %rax, %rsi

dec %rdi			#zmniejszamy licznik, by przejsc do kolejnego znaku
JMP e_mnozenie 

#______________
e_zakonczenieMnozenia:
cmp $0, %cl
jg e_uwzglednijZnak
jmp e_dopisanieRozszerzeniaDodatniego

#_____________
e_uwzglednijZnak:
movq %rsi, %rax			#%rsi posiada w sobie najwyzsza potrzebna nam potege 8
movq $-1, %rbx
mul %rbx			
add %rax, %r8			# dodajemy do wyniku -1*8^n aby otrzymac liczbe przeciwna

movq $-1, %rbx			
movq %r8, %rax
mul %rbx			#mnożymy przez -1 by mieć liczbe z dodatnim znakiem
movq %rax, %r8
jmp e_dopisanieRozszerzeniaUjemnego 

#_______________
e_dopisanieRozszerzeniaUjemnego:              #dopisanie ujemnego rozszerzenia do wyniku
movq $0, %r10
movb $40, liczba_u6(, %r10, 1)  #kod ascii '('                          
inc %r10
movb $53, liczba_u6(, %r10, 1)  #kod ascii '5'
inc %r10
movb $41, liczba_u6(, %r10, 1)  #kod ascii ')'
inc %r10
jmp e_przygotowanieDzielenia

#_________________________
e_dopisanieRozszerzeniaDodatniego:		#dopisanie dodatniego rozszerzenia do wyniku
movq $0, %r10
movb $40, liczba_u6(, %r10, 1)	#kod ascii '('				
inc %r10
movb $48, liczba_u6(, %r10, 1)	#kod ascii '0'
inc %r10
movb $41, liczba_u6(, %r10, 1)	#kod ascii ')'
inc %r10
jmp e_przygotowanieDzielenia


#______________________________________________________________________________________________
e_przygotowanieDzielenia:			#zapis liczby z rejestru do kodu ascii w buforze U10 na U6

mov %r8, %rax		#przygotowanie do dzielenia
mov $6, %rbx		
mov $0, %rcx
jmp e_dzielenie

#________________
e_dzielenie:			#dzielenie rax przez rbx, wynik do rax a reszta do rdx
mov $0, %rdx
div %rbx
add $48, %rdx		#dodanie 48 by było ascii

movb %dl, odwrotna_u6(, %rcx, 1)
inc %rcx
cmp $0, %rax
jne e_dzielenie
jmp e_przygotowanieOdwracania

#______________________________________________________________________________________________
e_przygotowanieOdwracania:		#odwrocenie kolejnosci liczb w celu uzyskania wyniku
mov $3, %rdi
mov %rcx, %r10
add $3, %r10
mov %rcx, %rsi
dec %rsi

mov $1, %rcx				#sprawdzanie czy w wyniku rozszerzenia jest '0' lub '5'
movb liczba_u6(, %rcx, 1), %ah		#co okresla nam liczbe jako dodatnia lub ujemna
cmp $48, %ah
jg e_odwracanieUjemnejU6
jmp e_odwracanieDodatniejU6


#______________________________________________
e_odwracanieUjemnejU6:
mov odwrotna_u6(, %rsi, 1), %al
sub $48, %al				#odkodowanie z ascii w celu uzyskania poprawnego wyniku
mov $5, %cl				#aby uniknac 5-48 = -43
sub %al, %cl
add $48, %cl
mov %cl, liczba_u6(, %rdi, 1)

inc %rdi
dec %rsi
cmp %r10, %rdi
jle e_odwracanieUjemnejU6                #jl e_odwracanie
jmp e_dodajJeden

#_________________
e_dodajJeden:				#dodajemy jeden do wyniku by zamiana na przeciwna liczbe
dec %r10				#byla poprawna
movb liczba_u6(, %r10, 1), %al
inc %al
movb %al, liczba_u6(, %r10, 1)
inc %r10

jmp e_wyswietlWynik

#________________
e_odwracanieDodatniejU6:
mov odwrotna_u6(, %rsi, 1), %al
mov %al, liczba_u6(, %rdi, 1)

inc %rdi
dec %rsi
cmp %r10, %rdi			
jle e_odwracanieDodatniejU6		#jl e_odwracanie
jmp e_wyswietlWynik

#______________________________________________________________________________________________
e_wyswietlWynik:		
movb $'\n', liczba_u6(, %r10, 1)
inc %r10

#wyswietlenie tekstu z buffora
mov $SYSWRITE, %rax
mov $STDOUT, %rdi
mov $liczba_u6, %rsi
mov %r10, %rdx
syscall




movq $SYSEXIT, %rax
movq $EXIT_SUCCESS, %rdi
syscall

