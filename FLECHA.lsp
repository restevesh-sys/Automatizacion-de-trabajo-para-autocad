;;; =====================================================================
;;; FLECHA.lsp
;;; Version     : 1.0
;;; Fecha       : 2026-10-18
;;; Descripcion : Flechas de direccion para acompanar textos y notas
;;;               (no son directrices). Menu con vista previa de 10 estilos.
;;;               Todas se dibujan en la capa NOTAS AD.
;;;
;;; Comandos:
;;;   FLECHA    Abre el menu, eliges estilo y tamano, y dibujas
;;;   FLECHAR   Repite el ultimo estilo sin abrir el menu
;;;
;;; Estilos:
;;;    1 Simple abierta        6 Gruesa rellena
;;;    2 Simple rellena        7 Con punto de origen
;;;    3 Doble punta           8 Curva (3 puntos)
;;;    4 Media punta           9 Recorrido (varios puntos)
;;;    5 Gruesa contorno      10 Chevrones
;;;
;;; Casi todos los estilos quedan como UNA sola polilinea: se mueve,
;;; copia o borra de un clic. Chevrones son 3 polilineas.
;;; Todo lo dibujado en un comando se deshace con un solo U.
;;; =====================================================================

(vl-load-com)

;;; ---------------------------------------------------------------------
;;; CONFIGURACION
;;; ---------------------------------------------------------------------
(setq fl:*capa*       "NOTAS AD")  ; capa donde se dibujan las flechas
(setq fl:*capa-color* 2)           ; color de la capa si se crea (2 = amarillo)
(setq fl:*auto*       2.0)         ; largo de punta automatico = TEXTSIZE x este valor
(setq fl:*ancho*      0.6)         ; ancho de punta = largo de punta x este valor
(setq fl:*ancho-g*    0.9)         ; ancho de punta en flechas gruesas
(setq fl:*cuerpo-g*   0.35)        ; ancho del cuerpo en flechas gruesas
(setq fl:*sep-texto*  0.5)         ; separacion texto-cola = altura de texto x este valor

(setq fl:*nombres*
  '("SIMPLE ABIERTA" "SIMPLE RELLENA" "DOBLE PUNTA" "MEDIA PUNTA"
    "GRUESA CONTORNO" "GRUESA RELLENA" "CON PUNTO DE ORIGEN"
    "CURVA (3 PUNTOS)" "RECORRIDO (VARIOS PUNTOS)" "CHEVRONES"))

;;; ---------------------------------------------------------------------
;;; AJUSTES GUARDADOS (se recuerdan entre sesiones)
;;; ---------------------------------------------------------------------
(defun fl:get (k def / v) (if (setq v (getenv k)) v def))

(defun fl:estilo (/ n)
  (setq n (atoi (fl:get "FLECHA_ESTILO" "2")))
  (if (and (>= n 1) (<= n 10)) n 2)
)
(defun fl:punta-cfg  () (atof (fl:get "FLECHA_PUNTA" "0")))
(defun fl:grosor-cfg () (atof (fl:get "FLECHA_GROSOR" "0")))
(defun fl:texto-cfg  () (fl:get "FLECHA_TEXTO" "0"))

;;; ---------------------------------------------------------------------
;;; UTILIDADES
;;; ---------------------------------------------------------------------
(defun fl:doc () (vla-get-ActiveDocument (vlax-get-acad-object)))

(defun fl:capa ()
  (if (not (tblsearch "LAYER" fl:*capa*))
    (entmake (list '(0 . "LAYER") '(100 . "AcDbSymbolTableRecord")
                   '(100 . "AcDbLayerTableRecord") (cons 2 fl:*capa*) '(70 . 0)
                   (cons 62 fl:*capa-color*) '(6 . "Continuous")))
  )
  fl:*capa*
)

;; Punto del usuario (SCP) -> SCU en 2D
(defun fl:w (p / q) (setq q (trans p 1 0)) (list (car q) (cadr q)))

;; Polilinea. verts = lista de (punto ancho-inicial ancho-final bulge)
(defun fl:pl (verts cerrada)
  (entmake
    (append
      (list '(0 . "LWPOLYLINE") '(100 . "AcDbEntity") (cons 8 (fl:capa))
            '(100 . "AcDbPolyline") (cons 90 (length verts))
            (cons 70 (if cerrada 1 0)) '(210 0.0 0.0 1.0))
      (apply 'append
        (mapcar '(lambda (v) (list (cons 10 (car v)) (cons 40 (cadr v))
                                   (cons 41 (caddr v)) (cons 42 (cadddr v))))
                verts))
    )
  )
)

(defun fl:v (p w1 w2 b) (list (list (car p) (cadr p)) w1 w2 b))

;; Normaliza un angulo a [0, 2pi)
(defun fl:ang (a) (rem (+ (rem a (* 2 pi)) (* 4 pi)) (* 2 pi)))

;;; ---------------------------------------------------------------------
;;; GEOMETRIA DE ARCO POR 3 PUNTOS
;;; ---------------------------------------------------------------------
(defun fl:centro (a b c / ax ay bx by cx cy d)
  (setq ax (car a) ay (cadr a) bx (car b) by (cadr b) cx (car c) cy (cadr c)
        d  (* 2.0 (+ (* ax (- by cy)) (* bx (- cy ay)) (* cx (- ay by)))))
  (if (> (abs d) 1e-9)
    (list
      (/ (+ (* (+ (* ax ax) (* ay ay)) (- by cy))
            (* (+ (* bx bx) (* by by)) (- cy ay))
            (* (+ (* cx cx) (* cy cy)) (- ay by))) d)
      (/ (+ (* (+ (* ax ax) (* ay ay)) (- cx bx))
            (* (+ (* bx bx) (* by by)) (- ax cx))
            (* (+ (* cx cx) (* cy cy)) (- bx ax))) d))
  )
)

;; Arco de a a b pasando por m -> (bulge antihorario-p centro) o nil
(defun fl:arco (a m b / c a1 s tm)
  (if (setq c (fl:centro a m b))
    (progn
      (setq a1 (angle c a)
            s  (fl:ang (- (angle c b) a1))
            tm (fl:ang (- (angle c m) a1)))
      (if (< tm s)
        (list (/ (sin (/ s 4.0)) (cos (/ s 4.0))) T c)
        (list (- (/ (sin (/ (- (* 2 pi) s) 4.0)) (cos (/ (- (* 2 pi) s) 4.0)))) nil c)
      )
    )
  )
)

;; Direccion tangente del arco en el punto p
(defun fl:tangente (arc p)
  (if (cadr arc)
    (+ (angle (caddr arc) p) (/ pi 2.0))
    (- (angle (caddr arc) p) (/ pi 2.0))
  )
)

;;; ---------------------------------------------------------------------
;;; TEXTO OPCIONAL EN LA COLA
;;; ---------------------------------------------------------------------
;; p0 = cola, a = direccion de la flecha en la cola
(defun fl:texto (p0 a / s h tp rot j)
  (setq s (getstring T "\nTexto en la cola (Enter = sin texto): "))
  (if (/= s "")
    (progn
      (setq h  (getvar "TEXTSIZE")
            tp (polar p0 (+ a pi) (* h fl:*sep-texto*))
            a  (fl:ang a))
      ;; Siempre legible: si la flecha apunta a la izquierda se voltea el texto
      (if (and (> a (/ pi 2.0)) (<= a (* 1.5 pi)))
        (setq rot (+ a pi) j 0)   ; medio-izquierda
        (setq rot a j 2)          ; medio-derecha
      )
      (entmake (list '(0 . "TEXT") (cons 8 (fl:capa)) (cons 10 tp) (cons 11 tp)
                     (cons 40 h) (cons 1 s) (cons 50 rot) (cons 7 (getvar "TEXTSTYLE"))
                     (cons 72 j) (cons 73 2)))
    )
  )
)

;;; ---------------------------------------------------------------------
;;; DIBUJO DE CADA ESTILO
;;; ---------------------------------------------------------------------
;; Ajusta el largo de punta si la flecha es corta
(defun fl:hl (hl d f) (if (< d (* f hl)) (/ d f) hl))

;; Estilos de 2 puntos. Devuelve la direccion en la cola (para el texto)
(defun fl:dos (est p0 p1 hl0 wl / a d hl hw pb l1 l2 sw hwg pa dd q1 q2 i ti bi cw)
  (setq a  (angle p0 p1)
        d  (distance p0 p1))
  (cond
    ;; 1 Simple abierta
    ((= est 1)
     (setq hl (fl:hl hl0 d 1.5) hw (* hl fl:*ancho*)
           pb (polar p1 (+ a pi) hl)
           l1 (polar pb (+ a (/ pi 2)) (/ hw 2)) l2 (polar pb (- a (/ pi 2)) (/ hw 2)))
     (fl:pl (list (fl:v p0 wl wl 0) (fl:v p1 wl wl 0) (fl:v l1 wl wl 0)
                  (fl:v p1 wl wl 0) (fl:v l2 wl wl 0)) nil))
    ;; 2 Simple rellena
    ((= est 2)
     (setq hl (fl:hl hl0 d 1.5) hw (* hl fl:*ancho*)
           pb (polar p1 (+ a pi) hl))
     (fl:pl (list (fl:v p0 wl wl 0) (fl:v pb hw 0.0 0) (fl:v p1 0.0 0.0 0)) nil))
    ;; 3 Doble punta
    ((= est 3)
     (setq hl (fl:hl hl0 d 2.5) hw (* hl fl:*ancho*)
           pa (polar p0 a hl) pb (polar p1 (+ a pi) hl))
     (fl:pl (list (fl:v p0 0.0 hw 0) (fl:v pa wl wl 0) (fl:v pb hw 0.0 0)
                  (fl:v p1 0.0 0.0 0)) nil))
    ;; 4 Media punta
    ((= est 4)
     (setq hl (fl:hl hl0 d 1.5) hw (* hl fl:*ancho*)
           pb (polar p1 (+ a pi) hl)
           l1 (polar pb (+ a (/ pi 2)) (/ hw 2)))
     (fl:pl (list (fl:v p0 wl wl 0) (fl:v p1 wl wl 0) (fl:v l1 wl wl 0)) nil))
    ;; 5 Gruesa contorno
    ((= est 5)
     (setq hl (fl:hl hl0 d 1.5) hwg (* hl fl:*ancho-g*) sw (* hl fl:*cuerpo-g*)
           pb (polar p1 (+ a pi) hl))
     (fl:pl (list (fl:v (polar p0 (+ a (/ pi 2)) (/ sw 2)) wl wl 0)
                  (fl:v (polar pb (+ a (/ pi 2)) (/ sw 2)) wl wl 0)
                  (fl:v (polar pb (+ a (/ pi 2)) (/ hwg 2)) wl wl 0)
                  (fl:v p1 wl wl 0)
                  (fl:v (polar pb (- a (/ pi 2)) (/ hwg 2)) wl wl 0)
                  (fl:v (polar pb (- a (/ pi 2)) (/ sw 2)) wl wl 0)
                  (fl:v (polar p0 (- a (/ pi 2)) (/ sw 2)) wl wl 0)) T))
    ;; 6 Gruesa rellena
    ((= est 6)
     (setq hl (fl:hl hl0 d 1.5) hwg (* hl fl:*ancho-g*) sw (* hl fl:*cuerpo-g*)
           pb (polar p1 (+ a pi) hl))
     (fl:pl (list (fl:v p0 sw sw 0) (fl:v pb hwg 0.0 0) (fl:v p1 0.0 0.0 0)) nil))
    ;; 7 Con punto de origen
    ((= est 7)
     (setq hl (fl:hl hl0 d 2.0) hw (* hl fl:*ancho*) dd (* hw 0.8)
           pb (polar p1 (+ a pi) hl)
           q1 (polar p0 (+ a pi) (/ dd 4)) q2 (polar p0 a (/ dd 4)))
     (fl:pl (list (fl:v q1 (/ dd 2) (/ dd 2) 1.0) (fl:v q2 (/ dd 2) (/ dd 2) 1.0)
                  (fl:v q1 wl wl 0) (fl:v pb hw 0.0 0) (fl:v p1 0.0 0.0 0)) nil))
    ;; 10 Chevrones
    ((= est 10)
     (setq hl (fl:hl hl0 d 2.0) hw (* hl fl:*ancho*) cw (* hl 0.15) i 1)
     (repeat 3
       (setq ti (polar p0 a (* d (/ i 3.0)))
             bi (polar ti (+ a pi) (* hl 0.7)))
       (fl:pl (list (fl:v (polar bi (+ a (/ pi 2)) (/ hw 2)) cw cw 0)
                    (fl:v ti cw cw 0)
                    (fl:v (polar bi (- a (/ pi 2)) (/ hw 2)) cw cw 0)) nil)
       (setq i (1+ i))
     ))
  )
  a
)

;; 8 Curva por 3 puntos
(defun fl:curva (p0 pm p1 hl0 wl / arc1 arc2 ta hl hw pb)
  (setq arc1 (fl:arco p0 pm p1))
  (if (null arc1)
    (fl:dos 2 p0 p1 hl0 wl)
    (progn
      (setq hl (fl:hl hl0 (distance p0 p1) 2.0)
            hw (* hl fl:*ancho*)
            ta (fl:tangente arc1 p1)
            pb (polar p1 (+ ta pi) hl)
            arc2 (fl:arco p0 pm pb))
      (if (null arc2) (setq arc2 (list 0.0 T p0)))
      (fl:pl (list (fl:v p0 wl wl (car arc2)) (fl:v pb hw 0.0 0) (fl:v p1 0.0 0.0 0)) nil)
      (if (equal (car arc2) 0.0 1e-12) (angle p0 pb) (fl:tangente arc2 p0))
    )
  )
)

;; 9 Recorrido por varios puntos
(defun fl:recorrido (pts hl0 wl / n ult pen d hl hw pb vs)
  (setq n   (length pts)
        ult (last pts)
        pen (nth (- n 2) pts)
        d   (distance pen ult)
        hl  (fl:hl hl0 d 1.2)
        hw  (* hl fl:*ancho*)
        pb  (polar ult (+ (angle pen ult) pi) hl))
  ;; todos los puntos menos el ultimo, luego base de punta y punta
  (setq vs (mapcar '(lambda (p) (fl:v p wl wl 0)) (reverse (cdr (reverse pts)))))
  (setq vs (append vs (list (fl:v pb hw 0.0 0) (fl:v ult 0.0 0.0 0))))
  (fl:pl vs nil)
  (angle (car pts) (cadr pts))
)

;;; ---------------------------------------------------------------------
;;; BUCLE DE DIBUJO
;;; ---------------------------------------------------------------------
(defun fl:ejecuta (est / *error* oce hl wl txt p0 pm p1 p pts a n)
  (defun *error* (m)
    (if (not (wcmatch (strcase m) "*CANCEL*,*QUIT*,*BREAK*")) (princ (strcat "\nError: " m)))
    (vla-EndUndoMark (fl:doc))
    (if oce (setvar "CMDECHO" oce))
    (princ)
  )
  (setq oce (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (vla-StartUndoMark (fl:doc))
  (setq hl  (fl:punta-cfg)
        wl  (max 0.0 (fl:grosor-cfg))
        txt (= (fl:texto-cfg) "1"))
  (if (<= hl 0.0) (setq hl (* fl:*auto* (getvar "TEXTSIZE"))))
  (princ (strcat "\nEstilo: " (nth (1- est) fl:*nombres*)
                 "   Punta: " (rtos hl 2 2) "   Capa: " fl:*capa*))
  (setq n 0)
  (while (setq p0 (getpoint "\nCola de la flecha (origen) <Enter termina>: "))
    (setq a nil)
    (cond
      ((= est 8)
       (if (and (setq pm (getpoint p0 "\nPunto intermedio de la curva: "))
                (setq p1 (getpoint pm "\nPunta de la flecha: ")))
         (setq a (fl:curva (fl:w p0) (fl:w pm) (fl:w p1) hl wl))))
      ((= est 9)
       (setq pts (list p0) p p0)
       (while (setq p (getpoint p (if (< (length pts) 2)
                                    "\nSiguiente punto: "
                                    "\nSiguiente punto <Enter = punta en el ultimo>: ")))
         (setq pts (append pts (list p)))
       )
       (if (>= (length pts) 2)
         (setq a (fl:recorrido (mapcar 'fl:w pts) hl wl))
         (princ "\nSe necesitan al menos 2 puntos.")))
      (T
       (if (setq p1 (getpoint p0 "\nPunta de la flecha: "))
         (if (> (distance p0 p1) 1e-6)
           (setq a (fl:dos est (fl:w p0) (fl:w p1) hl wl))
           (princ "\nLos puntos coinciden."))))
    )
    (if a
      (progn
        (setq n (1+ n))
        (if txt (fl:texto (fl:w p0) a))
      )
    )
  )
  (princ (strcat "\n" (itoa n) " flecha(s) en la capa " fl:*capa* ". Se deshacen con U."))
  (vla-EndUndoMark (fl:doc))
  (setvar "CMDECHO" oce)
  (princ)
)

;;; ---------------------------------------------------------------------
;;; VISTA PREVIA EN EL MENU
;;; ---------------------------------------------------------------------
;; Primitivas normalizadas (0..1, y hacia arriba):
;;   (L x1 y1 x2 y2)        linea
;;   (T x1 y1 x2 y2 x3 y3)  triangulo relleno
(defun fl:prev (i)
  (cond
    ((= i 1) '((L .12 .5 .88 .5) (L .88 .5 .66 .70) (L .88 .5 .66 .30)))
    ((= i 2) '((L .12 .5 .66 .5) (T .88 .5 .66 .70 .66 .30)))
    ((= i 3) '((T .12 .5 .34 .70 .34 .30) (L .34 .5 .66 .5) (T .88 .5 .66 .70 .66 .30)))
    ((= i 4) '((L .12 .5 .88 .5) (L .88 .5 .66 .72)))
    ((= i 5) '((L .12 .6 .62 .6) (L .62 .6 .62 .8) (L .62 .8 .88 .5) (L .88 .5 .62 .2)
               (L .62 .2 .62 .4) (L .62 .4 .12 .4) (L .12 .4 .12 .6)))
    ((= i 6) '((T .12 .6 .62 .6 .62 .4) (T .12 .6 .12 .4 .62 .4) (T .88 .5 .62 .8 .62 .2)))
    ((= i 7) '((T .10 .5 .16 .66 .22 .5) (T .10 .5 .16 .34 .22 .5)
               (L .16 .5 .66 .5) (T .88 .5 .66 .70 .66 .30)))
    ((= i 8) '((L .12 .30 .22 .52) (L .22 .52 .34 .67) (L .34 .67 .47 .74) (L .47 .74 .60 .72)
               (L .60 .72 .71 .66) (L .71 .66 .79 .55) (T .80 .20 .69 .57 .89 .53)))
    ((= i 9) '((L .10 .25 .35 .25) (L .35 .25 .50 .75) (L .50 .75 .70 .75) (T .90 .75 .70 .92 .70 .58)))
    ((= i 10) '((L .26 .74 .40 .5) (L .40 .5 .26 .26) (L .27 .74 .41 .5) (L .41 .5 .27 .26)
                (L .48 .74 .62 .5) (L .62 .5 .48 .26) (L .49 .74 .63 .5) (L .63 .5 .49 .26)
                (L .70 .74 .84 .5) (L .84 .5 .70 .26) (L .71 .74 .85 .5) (L .85 .5 .71 .26)))
  )
)

(defun fl:tri (x1 y1 x2 y2 x3 y3 col / n k)
  (setq n (fix (max 1 (distance (list x2 y2) (list x3 y3)))) k 0)
  (while (<= k n)
    (vector_image x1 y1
                  (fix (+ x2 (* (- x3 x2) (/ k (float n)))))
                  (fix (+ y2 (* (- y3 y2) (/ k (float n))))) col)
    (setq k (1+ k))
  )
)

(defun fl:pinta (i sel / key w h px py)
  (setq key (strcat "i" (itoa i))
        w   (dimx_tile key)
        h   (dimy_tile key))
  (defun px (x) (fix (* x w)))
  (defun py (y) (fix (* (- 1.0 y) h)))
  (start_image key)
  (fill_image 0 0 w h 250)
  (foreach g (fl:prev i)
    (if (eq (car g) 'L)
      (vector_image (px (nth 1 g)) (py (nth 2 g)) (px (nth 3 g)) (py (nth 4 g)) 2)
      (fl:tri (px (nth 1 g)) (py (nth 2 g)) (px (nth 3 g)) (py (nth 4 g))
              (px (nth 5 g)) (py (nth 6 g)) 2)
    )
  )
  (if sel
    (foreach o '(0 1 2)
      (vector_image o o (- w 1 o) o 4)
      (vector_image (- w 1 o) o (- w 1 o) (- h 1 o) 4)
      (vector_image (- w 1 o) (- h 1 o) o (- h 1 o) 4)
      (vector_image o (- h 1 o) o o 4)
    )
  )
  (end_image)
)

(defun fl:selec (i / ant)
  (setq ant fl:*sel* fl:*sel* i)
  (if (and ant (/= ant i)) (fl:pinta ant nil))
  (fl:pinta i T)
  (set_tile "lst" (itoa (1- i)))
  (set_tile "info" (strcat "Estilo " (itoa i) ": " (nth (1- i) fl:*nombres*)))
)

(defun fl:leer (/ v)
  (if (setq v (distof (get_tile "hl"))) (setenv "FLECHA_PUNTA" (rtos (max 0.0 v) 2 4)))
  (if (setq v (distof (get_tile "lw"))) (setenv "FLECHA_GROSOR" (rtos (max 0.0 v) 2 4)))
  (setenv "FLECHA_TEXTO" (get_tile "txt"))
  (setenv "FLECHA_ESTILO" (itoa fl:*sel*))
)

(defun fl:dcl (fn / f img)
  (setq img (lambda (k) (strcat ": image_button { key = \"" k "\"; width = 15; height = 4; color = 250; }")))
  (setq f (open fn "w"))
  (foreach l
    (list
      "fla : dialog {"
      "  label = \"Seleccione estilo de flecha\";"
      "  : row {"
      "    : list_box { key = \"lst\"; width = 28; height = 13; }"
      "    : column {"
      (strcat "      : row { " (img "i1") (img "i2") (img "i3") (img "i4") (img "i5") " }")
      (strcat "      : row { " (img "i6") (img "i7") (img "i8") (img "i9") (img "i10") " }")
      "    }"
      "  }"
      "  : boxed_row {"
      "    label = \"Opciones\";"
      "    : edit_box { key = \"hl\";  label = \"Largo de punta (0 = auto):\"; edit_width = 7; }"
      "    : edit_box { key = \"lw\";  label = \"Grosor de linea:\";           edit_width = 7; }"
      "    : toggle   { key = \"txt\"; label = \"Agregar texto en la cola\"; }"
      "  }"
      "  : text { key = \"info\"; label = \"\"; width = 60; }"
      "  ok_cancel;"
      "}"
    )
    (write-line l f)
  )
  (close f)
)

;;; ---------------------------------------------------------------------
;;; COMANDOS
;;; ---------------------------------------------------------------------
(defun c:FLECHA (/ fn id r i)
  (setq fl:*sel* nil)
  (setq fn (vl-filename-mktemp "flecha" nil ".dcl"))
  (fl:dcl fn)
  (setq id (load_dialog fn))
  (if (and (> id 0) (new_dialog "fla" id))
    (progn
      (start_list "lst")
      (setq i 1)
      (foreach nm fl:*nombres* (add_list (strcat (itoa i) ". " nm)) (setq i (1+ i)))
      (end_list)
      (set_tile "hl"  (rtos (fl:punta-cfg) 2 2))
      (set_tile "lw"  (rtos (fl:grosor-cfg) 2 2))
      (set_tile "txt" (fl:texto-cfg))
      (setq i 1)
      (repeat 10 (fl:pinta i nil) (setq i (1+ i)))
      (fl:selec (fl:estilo))
      (setq i 1)
      (repeat 10
        (action_tile (strcat "i" (itoa i)) (strcat "(fl:selec " (itoa i) ")"))
        (setq i (1+ i))
      )
      (action_tile "lst" "(fl:selec (1+ (atoi $value))) (if (= $reason 4) (progn (fl:leer) (done_dialog 1)))")
      (action_tile "accept" "(fl:leer) (done_dialog 1)")
      (action_tile "cancel" "(done_dialog 0)")
      (setq r (start_dialog))
      (unload_dialog id)
    )
    (princ "\nNo se pudo abrir el menu.")
  )
  (vl-file-delete fn)
  (if (= r 1) (fl:ejecuta fl:*sel*))
  (princ)
)

(defun c:FLECHAR () (fl:ejecuta (fl:estilo)))

(princ "\nFLECHA v1.0 cargado. FLECHA = menu, FLECHAR = repetir ultimo estilo.")
(princ)
