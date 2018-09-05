;°±²Û Useful code in VGA 320x200x256
;±²Û  Real Mode
;²Û   by brAun & YO6
;Û

%include "easy.i"

;----------------------------------------------------------------------------
SetVideoMode:
; Change de mode video.    
;
; Entrees:      AL    = numero du mode video requis
; Sorties:      Aucune
; Registres modifies: SI DI

                mov     ah,0                    ; fonction 00h de
                int     10h                     ; l'interruption 10h du BIOS
                ret



;----------------------------------------------------------------------------
SetPixelSlow:
; Affiche un pixel dans le buffer ecran.    
;
; Entrees:      GS    = segment d'un buffer ecran (aligne sur para.)
;               EAX   = Y
;               ECX   = X
;               BL    = couleur
; Sorties:      Aucune
; Registres modifies: EAX EDX

                mov edx,320                     ; Calcul de l'adresse du pixel
                mul edx                         ; EAX = Y * 320
                add eax,ecx                     ; EAX = Y * 320 + X
                mov b [gs:eax],bl               ; on l'affiche !
                ret



;----------------------------------------------------------------------------
SetPixel:
; Affiche un pixel dans le buffer ecran.    
;
; Entrees:      GS    = segment d'un buffer ecran (aligne sur para.)
;               EBX   = X
;               EDI   = Y
;               AL    = couleur
; Sorties:      Aucune
; Registres modifies: EDI
                                                ; Calcul de l'adresse du pixel
                shl edi,6                       ; EDI = Y * 64
                lea edi,[edi*4+edi]             ;     = 4 * (Y * 64) + Y * 64
                                                ;     = 5 * (Y * 64)                                              
                                                ;     = Y * 320
                add edi,ebx                     ; EDI = Y * 320 + X
                mov b [gs:edi],al               ; On l'affiche !
                ret



;----------------------------------------------------------------------------
SetRectangle:
; Affiche un rectangle de couleur unie dans le buffer ecran.    
;
; Entrees:      GS    = segment d'un buffer ecran (aligne sur para.)
;               EBX   = X
;               EDI   = Y
;               ECX   = largeur
;               EDX   = hauteur
;               AL    = couleur
; Sorties:      Aucune
; Registres modifies: EBX EDX ESI EDI

                                                ; Calcul de l'adresse du pixel
                                                ; du coin superieur gauche du
                                                ; rectangle
                shl  edi,6                      ; EDI = Y * 64
                lea  edi,[edi*4+edi]            ;     = 4 * (Y * 64) + Y * 64
                                                ;     = 5 * (Y * 64)                                              
                                                ;     = Y * 320
                add  edi,ebx                    ; EDI = Y * 320 + X

                mov  esi,320                    ; Calcul du saut d'adresse de
                sub  esi,ecx                    ; fin de ligne
                mov  ebx,ecx                    ; sauve la largeur dans EBX
          
                                                ; affiche une ligne
.inner:         mov  b [gs:edi],al              ; affiche un point
                inc  edi                        ; incremente son abscisse
                dec  ecx                        ; reste-t-il des points sur
                jnz  .inner                     ; la ligne courante ?
                                                ; non, calcule l'adresse de la
                add  edi,esi                    ; ligne suivante
                mov  ecx,ebx                    ; de largeur ECX
                dec  edx                        ; reste-t-il des lignes a
                jnz  .inner                     ; afficher ?
                
                ret                             ; non, c'est termine !



;----------------------------------------------------------------------------
PutSprite:
; Affiche un sprite dans le buffer ecran.    
;
; Entrees:      GS    = segment du buffer ecran destination (aligne sur para.)
;               FS:SI = adresse du buffer ecran source
;               EAX   = X source
;               EDI   = X destination
;               BL    = Y source
;               BH    = Y destination
;               CX    = largeur
;               DX    = hauteur

; Sorties:      Aucune                    
; Registres modifies: AL EBX DX ESI EDI BP

                                                ; Calcul de l'adresse source
                                                ; du sprite
                push    bx                      ; sauve bx
                movzx   ebx,bl                  ; on travaille sur 32 bits !
                movzx   esi,si
                shl     ebx,6                   ; EBX = Y * 64
                lea     ebx,[ebx*4+ebx]         ; EBX = 4 * (Y * 64) + Y * 64
                add     ebx,eax                 ; EBX = Y * 320 + X
                add     esi,ebx                 ; ESI = Y * 320 + X + buf. ofs                

                                                ; Calcul de l'adresse
                                                ; destination du sprite
                pop     bx                      ; recupere bx
                movzx   ebx,bh                  ; on travaille sur 32 bits !
                movzx   edi,di
                shl     ebx,6                   ; EBX = Y * 64
                lea     ebx,[ebx*4+ebx]         ; EBX = 4 * (Y * 64) + Y * 64
                add     edi,ebx                 ; EDI = Y * 320 + X

                mov     bp,320                  ; Calcul du saut d'adresse de
                sub     bp,cx                   ; fin de ligne
                mov     bx,cx                   ; sauve la largeur dans EBX
                
                                                ; copie une ligne
.inner:         mov     al,b [fs:si]            ; copie un point
                mov     b [gs:di],al               
                inc     di                      ; incremente son abscisse
                inc     si                          
                dec     cx                      ; reste-t-il des points sur
                jnz     .inner                  ; la ligne courante ?
                                                ; non, calcule l'adresse de la
                add     si,bp                   ; ligne suivante
                add     di,bp                   ; ligne suivante
                mov     cx,bx                   ; de largeur CX
                dec     dx                      ; reste-t-il des lignes a
                jnz     .inner                  ; afficher ?
                
                ret                             ; non, c'est termine !



;----------------------------------------------------------------------------
FillBuffer:
; Remplit un buffer ecran avec la couleur specifiee.
;
; Entrees:      GS    = segment d'un buffer ecran (aligne sur para.)
;               EAX   = couleur (* 4)
; Sorties:      Aucune
; Registres modifies: CX DI

                mov     cx,320*200/4            ; on ecrit 4 pixels a la fois
                sub     di,di                   ; vers GS:0000

.inner:         mov     d [gs:di],eax
                add     di,4
                dec     cx
                jnz     .inner

                ret



;----------------------------------------------------------------------------
BlitScreen:
; Copie un buffer ecran vers la RAM video.
;
; Entrees:      GS    = segment du buffer ecran (aligne sur para.)
;               ES    = segment de la RAM video               
; Sorties:      Aucune
; Registres modifies: EAX CX SI DI

                mov     cx,320*200/4            ; on traite 4 pixels a la fois
                sub     si,si                   ; de      GS:0000
                sub     di,di                   ; vers 0A000:0000

.inner:         mov     eax,d [gs:si]          
                mov     d [es:di],eax
                add     si,4
                add     di,4
                dec     cx
                jnz     .inner

                ret



;----------------------------------------------------------------------------
WaitVBL:
; Attend le retour vertical du faisceau du tube cathodique.
;
; Entrees:      Aucune
; Sorties:      Aucune
; Registres modifies: AX DX

                mov     dx,03DAh                ; registre du CRTC

.wait_end:      in      al,dx
                test    al,00001000b            ; bit 3 = 1
                jnz     .wait_end               ; l'ecran est rafraichit

.wait_begin:    in      al,dx
                test    al,00001000b            ; bit 3 = 0
                jz     .wait_begin              ; retour vertical du faisceau

                ret



;----------------------------------------------------------------------------
SetPalette:
; Change les 256 couleurs de la palette VGA. 
;
; Entrees:      DS:SI = Adresse de la palette
; Sorties:      Aucune
; Registres modifies: AX CX DX SI

                mov     dx,3C8h               ; registre d'index du DAC
                sub     al,al                 ; couleur iniatiale = 0
                out     dx,al
                inc     dx                    ; registre de donnees du DAC
                mov     cx,256*3              ; 3 composantes: RVB par couleur
                rep     outsb                 ; on envoie tout octet par octet

                ret



;----------------------------------------------------------------------------
SetRGB:
; Change une couleur de la palette VGA. 
;
; Entrees:      AL = Couleur
;               AH = Rouge
;               BH = Vert
;               BL = Bleu
; Sorties:      Aucune
; Registres modifies: DX

                mov     dx,3C8h               ; registre d'index du DAC
                out     dx,al
                inc     dx                    ; registre de donnees du DAC
                mov     al,ah
                out     dx,al
                mov     al,bh
                out     dx,al
                mov     al,bl
                out     dx,al

                ret
