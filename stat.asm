bits 64

NULL equ 0
TAB equ 9
LF equ 10

STDIN equ 0
STDOUT equ 1

O_RDONLY equ 0

SYS_READ equ 0
SYS_WRITE equ 1
SYS_OPEN equ 2
SYS_CLOSE equ 3
SYS_STAT equ 4
SYS_EXIT equ 60

section .bss
	stat_struct resb 144 ; 144 octets pour la structure stat
section .data
	sautLigne db LF, NULL

	messageFichier db 'Fichier : ', NULL
	taille_messageFichier equ $ - messageFichier

	messageTaille db 'Taille : ', NULL
	taille_messageTaille equ $ - messageTaille

	messageBloc db TAB,'Blocs : ', NULL
	taille_messageBloc equ $ - messageBloc

	messageBlocES db TAB,'Blocs d E/S : ', NULL
	taille_messageBlocES equ $ - messageBlocES

	messagePeripherique db 'Peripherique : ', NULL
	taille_messagePeripherique equ $ - messagePeripherique

	messageInode db TAB,'Inode : ', NULL
	taille_messageInode equ $ - messageInode

	messageLien db TAB,'Liens : ', NULL
	taille_messageLien equ $ - messageLien

	messageAcces db 'Acces : ', NULL
	taille_messageAcces equ $ - messageAcces

	messageUID db TAB,'UID : ', NULL
	taille_messageUID equ $ - messageUID

	messageGID db TAB,'GID : ', NULL
	taille_messageGID equ $ - messageGID

	info times 8 db NULL, NULL
	taille_info equ $ - info

	errArg       db 'Erreur d arguments'                           , LF, NULL
	taille_errArg       equ $ - errArg
	errStat      db 'Erreur de recuperation des stats du fichier'  , LF, NULL
	taille_errStat      equ $ - errStat

section .text
	global _start

_start:
	pop rax ; récupérer le nombre d'arguments

	cmp rax, 2 ; vérifier si le nombre d'arguments est correct
	jl erreur_arguments

	mov rdi, [rsp+8] ; récupérer le premier argument

	; Stat
	mov rax, SYS_STAT
	lea rsi, stat_struct ; pointeur vers la structure stat
	syscall

	; Vérifier si stat a réussi
	cmp rax, 0
	jl  erreur_stat ; Si rax est négatif, il y a eu une erreur lors de l'appel à stat

	push rax ; sauvegarder le descripteur de fichier pour le fermer plus tard

	; Afficher le nom du fichier
	mov rsi, messageFichier
	mov rdx, taille_messageFichier

	call affiche

	mov rdi, [rsp+16] ; récupérer le premier argument
	call calcul_taille_chaine
	mov rsi, [rsp+16] ; récupérer le premier argument
	mov rdx, rcx ; taille maximale du nom de fichier

	call affiche

	; Afficher un retour à la ligne
	mov rsi, sautLigne
	mov rdx, 1

	call affiche

	call afficheTaille
	call afficheBloc
	call afficheBlocES

	; Afficher un retour à la ligne
	mov rsi, sautLigne
	mov rdx, 1

	call affiche

	call affichePeripherique
	call afficheInode
	call afficheLien

	mov rsi, sautLigne
	mov rdx, 1

	call affiche

	call afficheAcces
	call afficheUID
	call afficheGID

	; Afficher un retour à la ligne
	mov rsi, sautLigne
	mov rdx, 1

	call affiche

	; Fermer le fichier
	mov rax, SYS_CLOSE
	xor rdi, rdi ; descripteur de fichier à fermer
	syscall

fin:
	; Terminer le programme
	mov rax, SYS_EXIT
	xor rdi, rdi
	syscall

affiche:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	syscall

	ret

calcul_taille_chaine:
	mov rcx, -1
	mov rax, NULL
	repne scasb
	not rcx
	dec rcx

	ret

erreur_arguments:
	; Gérer l'erreur d'arguments
	mov rsi, errArg
	mov rdx, taille_errArg
	call affiche

	call fin

erreur_stat:
	; Gérer l'erreur d'écriture dans le fichier
	mov rsi, errStat
	mov rdx, taille_errStat
	call affiche

	call fin

convertisseur:
	xor rdx,rdx
	div rcx
	add dl, '0'
	dec rdi
	mov [rdi], dl

	test rax, rax
	jnz convertisseur

	ret

afficheTaille:
	; Afficher la taille du fichier
	mov rsi, messageTaille
	mov rdx, taille_messageTaille

	call affiche

	mov rax, [stat_struct+48] ; Taille du fichier 48 octets après le début de 
	; la structure stat

	mov rcx, 10 ; Base 10
	call afficheInfo

	ret

afficheBloc:
	; Afficher le nombre de blocs du fichier
	mov rsi, messageBloc
	mov rdx, taille_messageBloc

	call affiche
	movzx rax, word [stat_struct+64] ; Nombre de blocs du fichier 48 octets après 
	; le début de la structure stat

		mov rcx, 10 ; Base 10
	call afficheInfo

	ret

afficheBlocES:
	; Afficher le nombre de blocs d'E/S du fichier
	mov rsi, messageBlocES
	mov rdx, taille_messageBlocES

	call affiche
	mov rax, [stat_struct+56] ; Nombre de blocs du fichier 48 octets après 
	; le début de la structure stat

	mov rcx, 10 ; Base 10
	call afficheInfo

	ret

affichePeripherique:
	; Afficher le peripherique du fichier
	mov rsi, messagePeripherique
	mov rdx, taille_messagePeripherique

	call affiche

	mov rax, [stat_struct+0] ; Taille du fichier 0 octets après le début de 
	; la structure stat

	mov rcx, 10 ; Base 10
	call afficheInfo

	ret


afficheInode:
	; Afficher l'inode du fichier
	mov rsi, messageInode
	mov rdx, taille_messageInode

	call affiche

	mov rax, [stat_struct+8] ; Taille du fichier 8 octets après le début de 
	; la structure stat

	mov rcx, 10 ; Base 10
	call afficheInfo

	ret

afficheLien:
	; Afficher le peripherique du fichier
	mov rsi, messageLien
	mov rdx, taille_messageLien

	call affiche

	mov rax, [stat_struct+16] ; Taille du fichier 16 octets après le début de 
	; la structure stat

	mov rcx, 10 ; Base 10
	call afficheInfo

	ret

afficheAcces:
	; Afficher les acces du fichier
	mov rsi, messageAcces
	mov rdx, taille_messageAcces

	call affiche
	movzx rax, word[stat_struct+24] ; Nombre de blocs du fichier 24 octets après 
	; le début de la structure stat

	sub rax, 0x8000 ; on enleve 10000

	mov rcx, 8 ; Base octal
	call afficheInfo

	ret

afficheUID:
	; Afficher les acces du fichier
	mov rsi, messageUID
	mov rdx, taille_messageUID

	call affiche
	movzx rax, word[stat_struct+28] ; Nombre de blocs du fichier 24 octets après 
	; le début de la structure stat

	mov rcx, 10 ; Base 10
	call afficheInfo

	ret

afficheGID:
	; Afficher les acces du fichier
	mov rsi, messageGID
	mov rdx, taille_messageGID

	call affiche
	movzx rax, word[stat_struct+32] ; Nombre de blocs du fichier 24 octets après 
	; le début de la structure stat

	mov rcx, 10 ; Base 10
	call afficheInfo

	ret

afficheInfo:
	lea rdi, [info]
	add rdi, taille_info
	mov byte [rdi], 0

	call convertisseur

	lea rsi, [info]
	mov rdx, taille_info

	call affiche

	call nettoyage

	ret

nettoyage:
	lea rdi, [info]
	mov rcx, taille_info

	.boucle:
		mov byte [rdi], NULL
		inc rdi
		loop .boucle
	ret