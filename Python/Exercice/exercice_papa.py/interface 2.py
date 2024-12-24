import customtkinter as ctk
from db_connect import Database

#On crée une instance de la classe Database
bdd = Database()

def envoyer_info(event = None):
    bdd.text_entry = entre1.get()
    bdd.bouton_radio = var_bouton.get()
    bdd.bouton_segment = bouton_segmente.get()
    bdd.bouton_option = optionmenu.get()
    bdd.checkbox_droit = var_check_droit.get()
    bdd.checkbox_cookie = var_check_cookie.get()
    bdd.envoyer_info_questionnaire() #On envoie les informations à la base de données
    
def recup_info(event = None):
    resultat = bdd.voir_info_questionnaire() #On récupère les informations de la base de données
    
    for row in resultat: #On parcourt les résultats
        
        for i in range(len(row)): #On parcourt les colonnes
                ctk.CTkLabel(frame2, text=row[i], bg_color= "white").grid(row=resultat.index(row), column=i)
                    
    

fenetre = ctk.CTk()
fenetre.title('Interface métier')
fenetre.geometry("700x900")
fenetre._set_appearance_mode("light")

frame1 = ctk.CTkFrame(fenetre, 
                      fg_color='lightblue', 
                      border_color='grey', 
                      border_width=5, 
                      bg_color='transparent')
frame1.pack(expand=True, fill='both')

frame2 = ctk.CTkFrame(fenetre,
                      height= 300,
                      fg_color='lightgrey',
                      border_width=5,
                      border_color='grey')
frame2.pack(expand= True, fill='x')
                      
                      
titre1 = ctk.CTkLabel(frame1,
                      text="Mon outil d'interface métier",
                      text_color='darkgrey',
                      font=('Arial', 30, 'underline')
                      )
titre1.grid(row=1,column=1, columnspan = 3, pady = 10)


text1 = ctk.CTkLabel(frame1, 
                     text="Ecrivez quelque chose :",
                     text_color= 'grey',
                     font=('Helvetica', 12, 'italic'))
text1.grid(row = 2, column = 1, padx = 10)

frame1.columnconfigure(1, weight=1)
frame1.columnconfigure(2, weight=2)
frame1.columnconfigure(3, weight=1)

entre1 = ctk.CTkEntry(frame1,
                      height=30,
                      width= 370 ,
                      text_color='orange',
                    placeholder_text='ICI',
                    placeholder_text_color='lightgrey')
entre1.grid(row = 2, column = 2, sticky = 'w')

bouton1 = ctk.CTkButton(frame1,
                        text='OK',
                        font=('Arial', 12, 'bold'),
                        text_color='white',
                        height=30,
                        width=50,
                        border_color='orange',
                        border_width=1,
                        corner_radius=0)
bouton1.grid(row = 2, column = 3, sticky = 'w')

def pop_up(event): 
        pop_up = ctk.CTkToplevel(fenetre)
        pop_up.minsize(400, 200)
        pop_up.title("Ceci est une fenêtre pop-up")
        pop_up.grab_set()
        
        test = ctk.CTkLabel(pop_up,
                                   text=f'Vous avez écrit : ',
                                   font=('Arial', 20))
        test.pack(side = 'left', expand= True, anchor = 'e')
        
        text_pop_up = ctk.CTkLabel(pop_up,
                                   text=f'{entre1.get()}',
                                   text_color= 'orange',
                                   font=('Arial', 20, 'underline', 'italic', 'bold'))
        text_pop_up.pack(side = 'left', expand= True, anchor = 'w')


bouton1.bind('<Button-1>', pop_up)

frame1.grid_rowconfigure(3,pad=50)

text2 = ctk.CTkLabel(frame1, 
                     text="Sélectionnez une valeur :",
                     text_color= 'grey',
                     font=('Helvetica', 12, 'italic'))
text2.grid(row = 3, column = 1, padx = 10)

var_bouton = ctk.StringVar(value="Homme")

bouton_radio_h = ctk.CTkRadioButton(frame1,
                                  height=30,
                                  text="Homme",
                                  variable=var_bouton,
                                  textvariable="Homme",
                                  text_color='grey',
                                  border_color='orange')
bouton_radio_h.grid(row = 3, column = 2, sticky = 'w')

bouton_radio_f = ctk.CTkRadioButton(frame1,
                                  height=30,
                                  text="Femme",
                                  variable=var_bouton,
                                  textvariable="Femme",
                                  text_color='grey',
                                  border_color='orange',
                                  hover_color= 'violet',
                                  fg_color='violet')
bouton_radio_f.grid(row = 3, column = 2, sticky = 'e', ipadx = 75)


text3 = ctk.CTkLabel(frame1, 
                     text="Faites un choix :",
                     text_color= 'grey',
                     font=('Helvetica', 12, 'italic'))
text3.grid(row = 4, column = 1, padx = 10)



bouton_segmente = ctk.CTkSegmentedButton(frame1,
                                         width=150,
                                         height=30,
                                         values=['Choix 1', 'Choix 2', 'Choix 3'])
bouton_segmente.set("Choix 1")
bouton_segmente.grid(row = 4, column = 2, sticky = 'w')

frame1.grid_rowconfigure(5,pad=50)

text4 = ctk.CTkLabel(frame1, 
                     text="Faites un second choix :",
                     text_color= 'grey',
                     font=('Helvetica', 12, 'italic'))
text4.grid(row = 5, column = 1, padx = 10)

optionmenu = ctk.CTkOptionMenu(frame1, 
                               values=["option 1", "option 2"])
optionmenu.set("option 1")
optionmenu.grid(row = 5, column = 2, sticky = 'w')


text5 = ctk.CTkLabel(frame1, 
                     text="Et pour finir approuvez le document :",
                     text_color= 'grey',
                     font=('Helvetica', 12, 'italic'))
text5.grid(row = 6, column = 1, padx = 10)

var_check_droit = ctk.StringVar(value=0)
checkbox_droit = ctk.CTkCheckBox(frame1, 
                           text="Accepter les droits",
                           text_color= 'grey',
                           border_color= 'orange',
                           variable=var_check_droit, 
                           onvalue=1, 
                           offvalue=0)
checkbox_droit.grid(row = 6, column = 2, sticky = 'w')



var_check_cookie = ctk.StringVar(value=False)
checkbox_cookie = ctk.CTkCheckBox(frame1, 
                           text="Accepter les cookies",
                           text_color= 'grey',
                           border_color= 'orange',
                           variable=var_check_cookie, 
                           onvalue=True, 
                           offvalue=False)
checkbox_cookie.grid(row = 6, column = 2, sticky = 'e', ipadx = 10)

frame1.grid_rowconfigure(7,pad=100)

bouton_conn_bd = ctk.CTkButton(frame1,
                               text='Envoyer les données',
                                   font=('Arial', 12, 'bold'),
                                          text_color='orange',
                                                height=30,
                                                width=50,
                                                border_color='orange',
                                                fg_color= "green",
                                                hover_color= '#00FF00',
                                                border_width=1,
                                                corner_radius=0,
                                                command=envoyer_info)
bouton_conn_bd.place(x=350, y=400, anchor='center')


frame2.grid_rowconfigure(0,pad=50)
frame2.columnconfigure((0,1,2,3,4,5), weight=1)
bouton_voir_bd = ctk.CTkButton(frame2,
                               text='Voir les données',
                                   font=('Arial', 12, 'bold'),
                                          text_color='orange',
                                                height=30,
                                                width=50,
                                                border_color='orange',
                                                fg_color= "green",
                                                hover_color= '#00FF00',
                                                border_width=1,
                                                corner_radius=0,
                                                command=recup_info)

bouton_voir_bd.grid(row = 0, column = 0, sticky = 'w')











fenetre.mainloop()
bdd.deconnexion_bdd() #On se déconnecte de la base de données