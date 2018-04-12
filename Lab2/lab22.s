
SYSREAD = 0
SYSWRITE = 1
SYSOPEN = 2
SYSCLOSE = 3
FREAD = 0
FWRITE = 1
file_out: .ascii "plik3.txt\0" # Nazwa pliku musi kończyć się zerowym bajtem
 
.bss
.comm out_buffer, 1024

.text
.global main

main:


# Otwarcie pliku $file_out do zapisu
 
# Jeśli plik nie istnieje, zostanie on utworzony z prawami dostępu 644:
# 6 - zapis (2) i odczyt (4) przez właściciela - użytkownika tworzącego plik
# 4 - odczyt przez grupę do której należy właściciel i został przypisany plik
# (Właściciel może znajdować się w wielu grupach, ale plik musi przynależeć
# do dokładnie jednej z nich. Domyślnie jest to grupa zawierająca jedynie
# właściciela.)
# 4 (kolejne) - odczyt przez wszystkich pozostałych użytkowników
mov $0, %rax
movb $54, out_buffer(, %rax, 1)

mov $SYSOPEN, %rax  # Pierwszy parametr - numer wywołania systemowego
mov $file_out, %rdi # Drugi parametr - nazwa pliku
mov $FWRITE, %rsi   # Trzeci parametr - sposób otwarcia
mov $0644, %rdx     # Czwarty parametr - prawa dostępu
syscall             # Wywołanie przerwania
mov %rax, %r8       # Przeniesienia wartości zwróconej przez wywołanie
                    # - identyfikatora otwartego pliku, do rejestru R8
 
# Zapis zawartości bufora out_buffer do pliku
mov $SYSWRITE, %rax
mov %r8, %rdi       # Zamiast STDOUT, podajemy id otwartego pliku
mov $out_buffer, %rsi
mov $1024, %rdx
syscall
 
# Zamknięcie pliku
mov $SYSCLOSE, %rax # Pierwszy parametr - numer wywołania
mov %r8, %rdi       # Drugi parametr - ID otwartego pliku
syscall             # Wywołanie przerwania
