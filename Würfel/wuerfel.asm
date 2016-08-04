; W�rfel f�r Siebensegmentanzeige

; Programm mit ausf�hrlichen Kommentaren von
; Tom Kranz und Philipp Hacker
;--------------------------------------------------------------------------------------------------

; Initialisierung des PIC
  #include "p16f84.inc"                     ; Bezeichner- und Konstantendefinition
  LIST     p=pic16F84                       ; Auswahl des Mikrocontrollers
  __CONFIG _XT_OSC & _PWRTE_OFF & _WDT_OFF  ; Takterzeugung durch externen Quartz
;--------------------------------------------------------------------------------------------------

; Definition menschenlesbarer Bezeichner f�r Adressen der Anzeige-Bitmuster
  Aeins EQU 0x21
  Azwei EQU 0x22
  Adrei EQU 0x23
  Avier EQU 0x24
  Afuenf EQU 0x25
  Asechs EQU 0x26
;--------------------------------------------------------------------------------------------------

; Initialisierung der Ports
  BSF STATUS, RP0          ; Auswahl von bank 1                                                 (1)
  MOVLW       B'11111111'  ;                                                                    (1)
  MOVWF       TRISA        ; Festlegung: RA4..RA0 sind Eingaenge                                (1)
  MOVLW       B'00000000'  ;                                                                    (1)
  MOVWF       TRISB        ; Festlegung: RB7..RB0 sind Ausg�nge                                 (1)
  BCF STATUS, RP0          ; Auswahl von bank 0                                                 (1)
;---------------------------------------------------------------------------------Total:        (6)

; Bitmuster in Registern ablegen
;               abcdefg
  MOVLW      b'00110000'   ;                                                                    (1)
  MOVWF Aeins              ; Anzeige "1" definiert                                              (1)
  MOVLW      b'01101101'   ;                                                                    (1)
  MOVWF Azwei              ; Anzeige "2" definiert                                              (1)
  MOVLW      b'01111001'   ;                                                                    (1)
  MOVWF Adrei              ; Anzeige "3" definiert                                              (1)
  MOVLW      b'00110011'   ;                                                                    (1)
  MOVWF Avier              ; Anzeige "4" definiert                                              (1)
  MOVLW      b'01011011'   ;                                                                    (1)
  MOVWF Afuenf             ; Anzeige "5" definiert                                              (1)
  MOVLW      b'01011111'   ;                                                                    (1)
  MOVWF Asechs             ; Anzeige "6" definiert                                              (1)
;---------------------------------------------------------------------------------Total:       (12)

; Power-On Self Test
  CALL RESETFSR            ; File Select Register auf Adresse von "1" zur�cksetzen            (2+4)
  CALL POST                ; Von 1 bis 6 hochz�hlen                                     (2+2365562)
  CLRW                     ; 0 -> W                                                             (1)
  MOVWF PORTB              ; W -> PORTB (Anzeige schw�rzen)                                     (1)
;---------------------------------------------------------------------------------Total:  (2365570)

; W�rfeln
MAIN
  BTFSC PORTA,4            ; Wenn PORTA/Pin4 high, ...                                     (2||  1)
  CALL OUTPUT              ; ... zeige Inhalt der aktuellen Adresse                       (0||USER)
  INCF FSR,F               ; Gehe zur n�chsten Anzeigeadresse                                   (1)
  CALL TEST7               ; Anzeigeadresse, wenn n�tig, zur�cksetzen                        (2+14)
  GOTO MAIN                ; Weiterz�hlen                                                       (2)
;---------------------------------------------------------------------------------Total: (21||USER)

; Anzeigeadresse, wenn n�tig, zur�cksetzen
TEST7
  MOVLW 0x27               ; F�lle W mit Bitmuster der Adresse, bei der r�ckgesetzt werden soll (2)
  XORWF FSR,W              ; Vergleiche Bitmuster aktueller Adresse mit W                       (1)
  BTFSS STATUS,2           ; Wenn Bitmuster nicht gleich waren, ...                      (1  ||  2)
  CALL BEFAIR              ; ... tu etwas, um das Zur�cksetzen auszugleichen             (4+2||  0)
  BTFSC STATUS,2           ; Wenn Bitmuster gleich waren, ...                            (2  ||  1)
  CALL RESETFSR            ; ... setze Adresse auf "1" zur�ck                            (0  ||4+2)
  RETURN                   ;                                                                    (2)
;---------------------------------------------------------------------------------Total:       (14)

; File Select Register auf Adresse von "1" zur�cksetzen
RESETFSR
  MOVLW Aeins              ; Adresse von "1" -> W                                               (1)
  MOVWF FSR                ; W -> FSR                                                           (1)
  RETURN                   ; R�cksprung ins aufrufende Programm                                 (2)
;---------------------------------------------------------------------------------Total:        (4)

; Etwas tun, um die Cycles des Zur�cksetzens auszugleichen
BEFAIR
  NOP                      ; NOP                                                                (1)
  NOP                      ; NOP                                                                (1)
  RETURN                   ; R�cksprung ins aufrufende Programm                                 (2)
;---------------------------------------------------------------------------------Total:        (4)

; Anzeigen des Inhalts der aktuellen Adresse
OUTPUT
  MOVF INDF,W              ; Inhalt der aktuellen Adresse -> W                                  (1)
  MOVWF PORTB              ; W -> PORTB (Bitmuster der ausgew�hlten Zahl auf PORTB anzeigen)    (1)
  BTFSC PORTA,4            ; Solange PORTA/Pin4 high, ...                                    (1||2)
  GOTO OUTPUT              ; ... zeige Zahl weiter an                                        (2||0)
  CLRW                     ; 0 -> W                                                             (1)
  MOVWF PORTB              ; W -> PORTB (Anzeige schw�rzen wenn Schalter nicht mehr gedr�ckt)   (1)
  RETURN                   ; R�cksprung ins aufrufende Programm                                 (2)
;---------------------------------------------------------------------------------Total:       USER

; Von 1 bis 6 hochz�hlen
POST
  MOVF INDF,W              ; F�lle W mit Daten, auf die FSR zeigt                             (6*1)
  MOVWF PORTB              ; Zeige Bitmuster auf PORTB an                                     (6*1)
  CALL Delay3              ; Warte eine Weile, um Z�hlen sichtbar zu machen          (6*[394249+2])
  MOVLW 0x27               ; F�lle W mit Bitmuster der Adresse, bei der beendet werden soll   (6*1)
  INCF FSR,F               ; Gehe zur n�chsten Adresse                                        (6*1)
  XORWF FSR,W              ; Vergleiche Bitmuster dieser Adresse mit W                        (6*1)
  BTFSS STATUS,2           ; Wenn Bitmuster gleich waren, �berspringe ...                   (6*1+2)
  GOTO POST                ; ... das Zur�ckspringen zum Anfang der Routine                    (5*2)
  CALL RESETFSR            ; File Select Register auf Adresse von "1" zur�cksetzen            (4+2)
  RETURN                                                                                        (2)
;---------------------------------------------------------------------------------Total:  (2365562)

; Einfache Verz�gerungsschleife
Delay1
  MOVLW 0xFF               ; 255 -> W                                                           (1)
  MOVWF 0x0C               ; W -> Adresse 0x0C                                                  (1)
Marke1
  DECFSZ 0x0C, F           ; Inhalt von 0x0C - 1 -> Adresse 0x0C                          (254*1+2)
  GOTO Marke1              ; Wiederholen, bis Inhalt von 0x0C == 0                          (254*2)
  RETURN                   ; R�cksprung ins aufrufende Programm                                 (2)
;---------------------------------------------------------------------------------Total:      (768)

; Einfach verschachtelte Verz�gerungsschleife
Delay2
  MOVLW 0xFF               ; 255 -> W                                                           (1)
  MOVWF 0x0D               ; W -> Adresse 0x0D                                                  (1)
Marke2
  CALL Delay1              ; Eine einfache Verz�gerungsschleife aufrufen              (255*[768+2])
  DECFSZ 0x0D, F           ; Inhalt von 0x0D - 1 -> Adresse 0x0D                          (254*1+2)
  GOTO Marke2              ; Wiederholen, bis Inhalt von 0x0D == 0                          (254*2)
  RETURN                   ; R�cksprung ins aufrufende Programm                                 (2)
;---------------------------------------------------------------------------------Total:   (197118)

; Doppelt verschachtelte Verz�gerungsschleife
Delay3
  MOVLW 0x02               ; 2 -> W                                                             (1)
  MOVWF 0x0E               ; W -> Adresse 0x0D                                                  (1)
Marke3
  CALL Delay2              ; Eine einmal verschachtelte Schleife aufrufen            (2*[197118+2])
  DECFSZ 0x0E, F           ; Inhalt von 0x0E - 1 -> Adresse 0x0E                            (1*1+2)
  GOTO Marke3              ; Wiederholen, bis Inhalt von 0x0E == 0                            (1*2)
  RETURN                   ; R�cksprung ins aufrufende Programm                                 (2)
;---------------------------------------------------------------------------------Total:   (394249)
END
