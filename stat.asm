bits 64

NULL EQU 0
TAB EQU 9
LF EQU 10

STDIN EQU 0
STDOUT EQU 1

O_RDONLY EQU 0

SYS_READ EQU 0
SYS_WRITE EQU 1
SYS_OPEN EQU 2
SYS_CLOSE EQU 3
SYS_STAT EQU 4
SYS_EXIT EQU 60

section .bss
	stat_struct RESB 18 ; 18 octets = 144 bits pour la structure stat
section .data
	sautLigne DB LF, NULL

	messageFichier DB 'Fichier : ', NULL
	taille_messageFichier EQU $ - messageFichier

	messageTaille DB 'Taille : ', NULL
	taille_messageTaille EQU $ - messageTaille

	messageBloc DB TAB,'Blocs : ', NULL
	taille_messageBloc EQU $ - messageBloc

	messageBlocES DB TAB,'Blocs d E/S : ', NULL
	taille_messageBlocES EQU $ - messageBlocES

	messagePeripherique DB 'Peripherique : ', NULL
	taille_messagePeripherique EQU $ - messagePeripherique

	messageInode DB TAB,'Inode : ', NULL
	taille_messageInode EQU $ - messageInode

	messageLien DB TAB,'Liens : ', NULL
	taille_messageLien EQU $ - messageLien

	messageAcces DB 'Acces : ', NULL
	taille_messageAcces EQU $ - messageAcces

	messageUID DB TAB,'UID : ', NULL
	taille_messageUID EQU $ - messageUID

	messageGID DB TAB,'GID : ', NULL
	taille_messageGID EQU $ - messageGID

	info TIMES 8 DB NULL, NULL
	taille_info EQU $ - info

	errArg       DB 'Erreur d arguments'                           , LF, NULL
	taille_errArg       EQU $ - errArg
	errStat      DB 'Erreur de recuperation des stats du fichier'  , LF, NULL
	taille_errStat      EQU $ - errStat

section .text
	global _start

_start:
	POP RAX ; récupérer le nombre d'arguments

	CMP RAX, 2 ; vérifier si le nombre d'arguments est correct
	JL erreur_arguments

	MOV RDI, [RSP+8] ; récupérer le premier argument

	; Stat
	MOV RAX, SYS_STAT
	LEA RSI, stat_struct ; pointeur vers la structure stat
	SYSCALL

	; Vérifier si stat a réussi
	CMP RAX, 0
	JL  erreur_stat ; Si RAX est négatif, il y a eu une erreur lors de l'appel à stat

	push RAX ; sauvegarder le descripteur de fichier pour le fermer plus tard

	; Afficher le nom du fichier
	MOV RSI, messageFichier
	MOV RDX, taille_messageFichier

	CALL affiche

	MOV RDI, [RSP+16] ; récupérer le premier argument
	CALL calcul_taille_chaine
	MOV RSI, [RSP+16] ; récupérer le premier argument
	MOV RDX, RCX ; taille maximale du nom de fichier

	CALL affiche

	; Afficher un RETour à la ligne
	MOV RSI, sautLigne
	MOV RDX, 1

	CALL affiche

	CALL afficheTaille
	CALL afficheBloc
	CALL afficheBlocES

	; Afficher un RETour à la ligne
	MOV RSI, sautLigne
	MOV RDX, 1

	CALL affiche

	CALL affichePeripherique
	CALL afficheInode
	CALL afficheLien

	MOV RSI, sautLigne
	MOV RDX, 1

	CALL affiche

	CALL afficheAcces
	CALL afficheUID
	CALL afficheGID

	; Afficher un RETour à la ligne
	MOV RSI, sautLigne
	MOV RDX, 1

	CALL affiche

	; Fermer le fichier
	MOV RAX, SYS_CLOSE
	XOR RDI, RDI ; descripteur de fichier à fermer
	SYSCALL

fin:
	; Terminer le programme
	MOV RAX, SYS_EXIT
	XOR RDI, RDI
	SYSCALL

affiche:
	MOV RAX, SYS_WRITE
	MOV RDI, STDOUT
	SYSCALL

	RET

calcul_taille_chaine:
	MOV RCX, -1
	MOV RAX, NULL
	REPNE SCASB
	NOT RCX
	DEC RCX

	RET

erreur_arguments:
	; Gérer l'erreur d'arguments
	MOV RSI, errArg
	MOV RDX, taille_errArg
	CALL affiche

	CALL fin

erreur_stat:
	; Gérer l'erreur d'écriture dans le fichier
	MOV RSI, errStat
	MOV RDX, taille_errStat
	CALL affiche

	CALL fin

convertisseur:
	XOR RDX,RDX
	DIV RCX
	ADD dl, '0'
	dec RDI
	MOV [RDI], dl

	TEST RAX, RAX
	JNZ convertisseur

	RET

afficheTaille:
	; Afficher la taille du fichier
	MOV RSI, messageTaille
	MOV RDX, taille_messageTaille

	CALL affiche

	MOV RAX, [stat_struct+48] ; Taille du fichier 48 octets après le début de 
	; la structure stat

	MOV RCX, 10 ; Base 10
	CALL afficheInfo

	RET

afficheBloc:
	; Afficher le nombre de blocs du fichier
	MOV RSI, messageBloc
	MOV RDX, taille_messageBloc

	CALL affiche
	MOVZX RAX, WORD [stat_struct+64] ; Nombre de blocs du fichier 48 octets après 
	; le début de la structure stat

	MOV RCX, 10 ; Base 10
	CALL afficheInfo

	RET

afficheBlocES:
	; Afficher le nombre de blocs d'E/S du fichier
	MOV RSI, messageBlocES
	MOV RDX, taille_messageBlocES

	CALL affiche
	MOV RAX, [stat_struct+56] ; Nombre de blocs du fichier 48 octets après 
	; le début de la structure stat

	MOV RCX, 10 ; Base 10
	CALL afficheInfo

	RET

affichePeripherique:
	; Afficher le peripherique du fichier
	MOV RSI, messagePeripherique
	MOV RDX, taille_messagePeripherique

	CALL affiche

	MOV RAX, [stat_struct+0] ; Taille du fichier 0 octets après le début de 
	; la structure stat

	MOV RCX, 10 ; Base 10
	CALL afficheInfo

	RET


afficheInode:
	; Afficher l'inode du fichier
	MOV RSI, messageInode
	MOV RDX, taille_messageInode

	CALL affiche

	MOV RAX, [stat_struct+8] ; Taille du fichier 8 octets après le début de 
	; la structure stat

	MOV RCX, 10 ; Base 10
	CALL afficheInfo

	RET

afficheLien:
	; Afficher le peripherique du fichier
	MOV RSI, messageLien
	MOV RDX, taille_messageLien

	CALL affiche

	MOV RAX, [stat_struct+16] ; Taille du fichier 16 octets après le début de 
	; la structure stat

	MOV RCX, 10 ; Base 10
	CALL afficheInfo

	RET

afficheAcces:
	; Afficher les acces du fichier
	MOV RSI, messageAcces
	MOV RDX, taille_messageAcces

	CALL affiche
	MOVZX RAX, WORD[stat_struct+24] ; Nombre de blocs du fichier 24 octets après 
	; le début de la structure stat

	SUB RAX, 0x8000 ; on enleve 10000

	MOV RCX, 8 ; Base octal
	CALL afficheInfo

	RET

afficheUID:
	; Afficher les acces du fichier
	MOV RSI, messageUID
	MOV RDX, taille_messageUID

	CALL affiche
	MOVZX RAX, WORD[stat_struct+28] ; Nombre de blocs du fichier 24 octets après 
	; le début de la structure stat

	MOV RCX, 10 ; Base 10
	CALL afficheInfo

	RET

afficheGID:
	; Afficher les acces du fichier
	MOV RSI, messageGID
	MOV RDX, taille_messageGID

	CALL affiche
	MOVZX RAX, WORD[stat_struct+32] ; Nombre de blocs du fichier 24 octets après 
	; le début de la structure stat

	MOV RCX, 10 ; Base 10
	CALL afficheInfo

	RET

afficheInfo:
	LEA RDI, [info]
	ADD RDI, taille_info
	MOV BYTE [RDI], 0

	CALL convertisseur

	LEA RSI, [info]
	MOV RDX, taille_info

	CALL affiche

	CALL nettoyage

	RET

nettoyage:
	LEA RDI, [info]
	MOV RCX, taille_info

	.boucle:
		MOV BYTE [RDI], NULL
		inc RDI
		loop .boucle
	RET