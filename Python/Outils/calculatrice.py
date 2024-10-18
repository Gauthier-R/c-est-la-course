import customtkinter as ctk
import tkinter as tk
import time

#Config de la fenêtre
SCREEN = ctk.CTk()
SCREEN.title('Ma Calculatrice')
SCREEN.geometry((f"{300}x{400}"))

#Fond de la calculatrice
FRAME_BACKGROUND = ctk.CTkFrame(SCREEN, 
                                width=300, 
                                height=400, 
                                corner_radius=10, 
                                border_width= 5, 
                                bg_color= "transparent",
                                fg_color= "grey",
                                border_color="black", 
                                )
FRAME_BACKGROUND.pack(expand=True)


TEXT_CALCULATRICE = ""
LABEL_CALCULATRICE = ctk.CTkLabel(FRAME_BACKGROUND, 
                                  width=270, 
                                  height=50,
                                  text=TEXT_CALCULATRICE,
                                  corner_radius=10,
                                  bg_color="transparent", 
                                  fg_color="#cff3fc",
                                  text_color="black",
                                  font=("Arial", 18),
                                  anchor="w",
                                  wraplength=250
                                  
                                  )


LABEL_CALCULATRICE.place(x=15, y=30)

#(texte bouton, valeur afficher, couleur case, fonction appelé)
LISTE_TOUCHES = [("2nd", None, "#5c6061", "BUTTON_SECOND"),("π", "3,1415926535897932384626433832795","#5c6061","BUTTON_WRITER"),("e", "2,7182818284590452353602874713527", "#5c6061", "BUTTON_WRITER"),("C", None, "#5c6061", "BUTTON_DELETE"),("⏎", None, "#5c6061", "BUTTON_RETURN"),
                 ("ⅹ²", None, "#5c6061", "BUTTON_PUISSANCE_2"),("1/ⅹ", None, "#5c6061", "BUTTON_1/X"),("|ⅹ|", None, "#5c6061", "BUTTON_ABS"),("exp", None, "#5c6061", "BUTTON_EXP"),("mod", None, "#5c6061", "BUTTON_MOD"),
                 ("²√ⅹ", None, "#5c6061", "BUTTON_RACINE_CARRE"),("(", None, "#5c6061", "BUTTON_PARENTHESE_OPEN"),(")", None, "#5c6061", "BUTTON_PARENTHESE_CLOSE"),("៷!", None, "#5c6061", "BUTTON_FACTORIELLE"),("÷", None, "#5c6061", "BUTTON_DIVISER"),
                 ("ⅹ^Ⅴ", None, "#5c6061", "BUTTON_PUISSANCE"),("7","7","#6f7475","BUTTON_WRITER"),("8","8","#6f7475","BUTTON_WRITER"),("9","9","#6f7475","BUTTON_WRITER"),("x",None,"#5c6061","BUTTON_MULTIPLIER"),
                 ("10^ⅹ", None, "#5c6061", "BUTTON_PUISSANCE_DIX"),("4","4","#6f7475","BUTTON_WRITER"),("5","5","#6f7475","BUTTON_WRITER"),("6","6","#6f7475","BUTTON_WRITER"),("-", None, "#5c6061", "BUTTON_MOINS"),
                 ("㏒", None, "#5c6061", "BUTTON_LOGARITHME"),("1","1","#6f7475","BUTTON_WRITER"),("2","2","#6f7475","BUTTON_WRITER"),("3","3","#6f7475","BUTTON_WRITER"),("+", None, "#5c6061", "BUTTON_PLUS"),
                 ("㏑", None, "#5c6061", "BUTTON_LOGARITHME_NEPERIEN"),("+/-", "-", "#6f7475", "BUTTON_WRITER"),("0","0","#6f7475","BUTTON_WRITER"),(",", ",", "#6f7475", "BUTTON_WRITER"),("=",None,"#3eb8d6","BUTTON_EGALE")]
TOUCHE_NUMERO = 0


def management_button(event, btn_value, btn_action):
    if btn_action == "BUTTON_WRITER":
        BUTTON_WRITER(btn_value)


def BUTTON_WRITER(btn_value):
    global TEXT_CALCULATRICE
    TEXT_CALCULATRICE += btn_value
    LABEL_CALCULATRICE.configure(text=TEXT_CALCULATRICE)
    


for row in range(7):
    for column in range(5):
        btn_text = LISTE_TOUCHES[TOUCHE_NUMERO][0]
        btn_value = LISTE_TOUCHES[TOUCHE_NUMERO][1]
        fg_color = LISTE_TOUCHES[TOUCHE_NUMERO][2]
        btn_action = LISTE_TOUCHES[TOUCHE_NUMERO][3]
        
        button = ctk.CTkButton(FRAME_BACKGROUND,
                        width=50,
                        height=34,
                        corner_radius=5,
                        border_color="white",
                        border_spacing=2,
                        border_width=1,
                        bg_color="transparent",
                        fg_color=fg_color,
                        hover_color="#4b4e4f",
                        text=btn_text,
                        )
        button.place(x=15+column*54, y=120+row*38)
        button.bind("<Button-1>", lambda event, btn_value=btn_value, btn_action=btn_action: management_button(event, btn_value, btn_action))
        
        TOUCHE_NUMERO +=1





SCREEN.mainloop()
