bits 64
global _start

LF   equ 10
NULL equ 0

STDIN  equ 0
STDOUT equ 1

SYS_WRITE equ 1
SYS_EXIT  equ 60
SYS_KILL equ 62

section .data
	err db 'kill : utilisation : kill [signal] pid', LF, NULL
	taille_err equ $ - err

section .text

_start:
	pop rax ; nombre d'argument
	cmp rax, 2
	jz arg1 ; 1 argument (pid)
	jg arg2 ; 2 argument (sig,pid)
	jl erreur ; pas d'argument

arg1:
	mov rdi, [rsp+8] ; premier argument

	xor rax,rax
	xor rcx, rcx
	call convertisseur

	mov rdi, rax ; le pid 
	mov rsi, 15

	call kill

	jmp exit

arg2:
	mov rdi, [rsp+8]
	xor rax,rax
	xor rcx, rcx
	call convertisseur

	mov rsi, rax
	mov rdi, [rsp+16]

	xor rax,rax
	xor rcx, rcx
	call convertisseur
	mov rdi, rax

	call kill

	jmp exit

convertisseur:
	movzx rdx, byte [rdi + rcx]

	cmp rdx, NULL      ; On verifie si on a atteint la fin de la chaîne
	je .fin_conversion ; Si oui, on termine la conversion

	cmp rdx, '0'; on verifie si le caractere est bien un chiffre
	jb erreur   ; sinon on renvoie une erreur
	cmp rdx, '9'
	ja erreur

	sub rdx, '0'      ; on convertie le caractère ASCII en valeur numérique
	imul rax, rax, 10 ; on mutliplie le résultat actuel par 10
	add rax, rdx      ; on ajoute la nouvelle valeur numérique

	inc rcx ; on passe au caractere suivant au caractère suivant
	jmp convertisseur

	.fin_conversion:
		ret

kill:
	mov rax, SYS_KILL
	syscall

exit:
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall

erreur_pid:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, err
	mov rdx, taille_err
	syscall

erreur:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, err
	mov rdx, taille_err
	syscall

	jmp exit

