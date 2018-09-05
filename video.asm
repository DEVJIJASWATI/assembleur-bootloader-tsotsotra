mov     ax,0A000h
mov     gs,ax                   ; GS = segment de la RAM video
mov     ax,data
mov     ds,ax                   ; DS = segment de donnees
mov     ax,BMP
mov     es,ax                   ; ES = segment du fichier BMP
mov     fs,ax                   ; FS = segment du fichier BMP               
mov     al,13h                  ; Initialise le mode video
call    SetVideoMode            ; 320x200x256               
mov     dx,filename             ; DS:DX = nom du fichier
sub     di,di                   ; ES:DI = fichier BMP
call    LoadBMP                 ; Charge le fichier               
mov     ax,es
mov     ds,ax                   ; DS:SI= adresse de la palette
call    SetPalette              ; Charge la palette du BMP              
mov     si,bx                   ; FS:SI= buffer source
mov     eax,0                   ; X source
mov     edi,121                 ; X destination
mov     bl,0                    ; Y source
mov     bh,53                   ; Y destination
mov     cx,77                   ; largeur
mov     dx,94                   ; hauteur
call    PutSprite               ; Affiche le sprite a l'ecran               
sub     ax,ax                   ; Attend la pression d'une
int     16h                     ; touche               
mov     al,3                    ; Commute en mode texte
call    SetVideoMode             
mov     ax,4C00h                ; Rend la main au DOS
int     21h
