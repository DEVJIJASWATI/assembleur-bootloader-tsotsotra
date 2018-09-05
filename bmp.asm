;°±²Û Minimal BMP loader. format VGA 320x200x256 only.
;±²Û  Real Mode
;²Û   by brAun & YO6
;Û

%include "easy.i"



;----------------------------------------------------------------------------
LoadBMP:
; Charge un fichier BMP en memoire
;
; Entrees:      DS:DX = adresse du nom de fichier (terminant par 0)
;               ES:DI = adresse du buffer BMP (Taille = 65088)
; Sorties:      SI = adresse de la palette
;               BX = adresse du buffer ecran
; Registres modifies: EAX BX ECX EDX SI DI
                                
                push    ds                      ; sauve DS
                push    es                      ; sauve ES

                mov     ah,03Dh                 ; ouverture du fichier
                mov     al,10010000b            ; mode d'acces en lecture
                int     21h                        
                mov     bx,ax                   ; BX = Handle du fichier

                mov     ah,03Fh                 ; lecture du fichier
                mov     cx,65078                ; 65078 octets a lire
                pop     ds                      ; segment de la RAM reserve
                mov     dx,di                   ; son offset
                int     21h

                mov     ah,03Eh                 ; fermeture du fichier
                int     21h

                lea     si,[di+1078]            ; l'offset du buffer ecran
                mov     bx,si                   ; on la sauve pour le retour

                                                ; retourne l'image
                lea     di,[si+320*199]         ; on se place au debut de la
                                                ; derniere ligne
                mov     edx,100                 ; cent lignes a echanger
.scanline:      mov     ecx,320/4               ; on copie 4 octets par 4
.inner:         mov     eax,d [ds:si]           ; on echange 4 pixels source
                xchg    d [ds:di],eax           ; avec 4 pixels destination
                mov     d [ds:si],eax 
                add     si,4                    ; passe aux 4 pixels suivant
                add     di,4                    ; passe aux 4 pixels suivant
                dec     ecx                        
                jnz     .inner                  ; fin de ligne ?

                sub     di,320*2                ; on se place au debut de la
                dec     edx                     ; ligne precedente
                jnz     .scanline               ; reste-t-il encore une ligne
                                                ; a traiter ?

                lea     si,[bx-1024]            ; retrouve l'adresse du
                                                ; debut de la palette !
                mov     cx,256                  ; 256 couleurs a traiter
                mov     di,si
                mov     dx,si                   ; adresse du debut de la pal 

.pal:           mov     eax,d [si]              ; charge xRVB dans EAX
                bswap   eax                     ; EAX = BVRx
                shr     ah,2                    ; encode le rouge sur 6 bits
                mov     b [di],ah               ; et le sauve
                shr     eax,8                   ; puis composante suivante(V)
                shr     ah,2                    ; Idem pour vert
                mov     b [di+1],ah
                shr     eax,8                   ; puis composante suivante(B)
                shr     ah,2                    ; Idem pour bleu
                mov     b [di+2],ah
                add     di,3                    ;
                add     si,4                    ; Passe a la couleur suivante
                dec     cx                      ; encore une couleur ?
                jnz     .pal

                                                ; renvoie:
                mov     si,dx                   ; l'offset de la palette

                pop     ds                      ; retablit DS
                ret                             ; retour a l'appelant !

