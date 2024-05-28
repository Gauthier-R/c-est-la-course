from pytube import YouTube
from tkinter import Tk, Label, Button, END, Frame, Entry, filedialog
from PIL import Image, ImageTk
import os
import customtkinter
import json




#----FONCTION----

# Fonction pour charger les préférences depuis un fichier JSON
def load_preferences(filename):
    try:
        with open(filename, 'r') as f:
            preferences = json.load(f)
    except FileNotFoundError:
        # Si le fichier n'existe pas, on crée un nouveau fichier avec un dictionnaire vide
        with open(filename, 'w') as f:
            json.dump({}, f)
        preferences = {}
    except json.decoder.JSONDecodeError:
        # Si le fichier existe mais est vide, on ajoute un dictionnaire vide
        with open(filename, 'w') as f:
            json.dump({}, f)
        preferences = {}
    
    return preferences
    

# Fonction pour sauvegarder les préférences dans un fichier JSON
def save_preferences(filename, localisation):
    with open(filename, 'w') as f:
        json.dump(localisation, f)
        

#Récupérer le répertoire de dépôt par défaut
def default_video_folder():
    fichier_json = "setup/Default_Localisation_Folder.json"
    clefs = load_preferences(fichier_json)
    chemin_dossier = clefs.get("default_directory")
    if chemin_dossier is None:
        chemin_dossier = definir_dossier()
        clefs["default_directory"] = chemin_dossier
        save_preferences(fichier_json, clefs)
    return chemin_dossier

def default_video_folder_get():
    fichier_json = "setup/Default_Localisation_Folder.json"
    clefs = load_preferences(fichier_json)
    chemin_dossier = clefs.get("default_directory")
    if chemin_dossier is None:
        return "Undefined"
    else:
        return chemin_dossier
    
    
def default_video_folder_set(event):
    fichier_json = "setup/Default_Localisation_Folder.json"
    clefs = load_preferences(fichier_json)
    save = clefs.get("default_directory")
    chemin_dossier = definir_dossier(save)
    clefs["default_directory"] = chemin_dossier
    save_preferences(fichier_json, clefs)
    label_Repertoire.configure(text=f'Folder : {formater_chemin_dossier()}')
    label_Repertoire.update()
    
    
#Définir le répertoire de dépôt par défaut
def definir_dossier(save = 'Undefined'):
   #Ouvrir une fenêtre pour l'explorateur de fichier
    explorateur = Tk()
    explorateur.withdraw()
    chemin_dossier = filedialog.askdirectory()
    if chemin_dossier == '':
        chemin_dossier = save
    explorateur.destroy()
    return chemin_dossier     


def search_bar_on_click(event):
    if entry_Search_bar.get() == "Entrez l'URL de la vidéo":
        entry_Search_bar.delete(0, END)
        if customtkinter.get_appearance_mode() == 'Light':
            entry_Search_bar.configure(text_color='black')
        else:
            entry_Search_bar.configure(text_color='white')
    
    
def button_search_press(event):
    progressBar.set(0)
    label_Pourcentage.configure(text='')
    global yt
    try:
        search_video(entry_Search_bar.get())
        label_Validation.configure(text=f'Vidéo Youtube Trouvé ! \nTitre : {yt.title} | Chaîne : {yt.author}\nCliquez sur Télécharger', text_color='green')
    except:
        print('ERREUR - URL de la vidéo introuvable.')
        entry_Search_bar.delete(0, END)
        entry_Search_bar.delete(0, END)
        entry_Search_bar.configure(text_color='grey')
        entry_Search_bar.insert(0,"Entrez l'URL de la vidéo")
        button_search.focus_set()
        label_Validation.configure(text='ERREUR - Vidéo Youtube Introuvable !', text_color='red')
        yt = ''
        
    
def button_cancel_press(event):
    global yt
    #Reinitialiser la barre de recherche
    entry_Search_bar.delete(0, END)
    entry_Search_bar.configure(text_color='grey')
    entry_Search_bar.insert(0,"Entrez l'URL de la vidéo")
    #Reinitialiser le label Validation
    label_Validation.configure(text='')
    button_cancel.focus_set()
    yt = ''


def search_video(link):
    global yt
    yt = YouTube(link, on_progress_callback=download_progress)     
    print("Title", yt.title)
    print("View", yt.views)

def download_progress(stream, chunk, bytes_restant):
    taille_totale = stream.filesize
    bytes_telecharge = taille_totale-bytes_restant
    pourcentage_telecharge = bytes_telecharge/taille_totale*100
    
    progressBar.set(float(pourcentage_telecharge)/100)
    
    pourcentage_text = str(int(pourcentage_telecharge))
    label_Pourcentage.configure(text=pourcentage_text+'%')
    label_Pourcentage.update()
    
        
def download_video(event):
    #Afficher la barre de progression
    if label_Validation.cget("text_color") == 'green':
        progressBar.grid(row=5, column=0, columnspan=4, pady=10)
        #Afficher le message
        label_Validation.configure(text='Téléchargement en cours ...')
    #Reinitialiser la barre de recherche
    entry_Search_bar.delete(0, END)
    entry_Search_bar.configure(text_color='grey')
    entry_Search_bar.insert(0,"Entrez l'URL de la vidéo")
    button_Download.focus_set()
    #Définir le dossier de téléchargement
    dossier = default_video_folder()
    label_Repertoire.configure(text=f'Folder : {formater_chemin_dossier()}')
    label_Repertoire.update()
    
    #Télécharger la vidéo
    try:
        global yt
        yd = yt.streams.get_highest_resolution()
        yd.download(dossier)
        label_Validation.configure(text='Téléchargement Réussi !')
        progressBar.grid_remove()
        label_Pourcentage.configure(text='')
    except:
        label_Validation.configure(text='ERREUR - Veuillez rechercher une vidéo avant de la télécharger !', text_color='red')

        
def button_Folder_press(event):
    folder = default_video_folder()
    if os.path.exists(folder):
        os.startfile(folder)
    else:
        os.makedirs(folder)
        os.startfile(folder)
        

def formater_chemin_dossier():
    chemin = default_video_folder_get()
    parties = chemin.split('/')
    if len(parties) > 3:
        chemin = parties[0]+'/'+parties[1]+'/'+parties[2]+'/[...]/'+parties[-1]
    else:
        chemin = default_video_folder_get()
    return chemin
        

#----Variable Global----
yt = ''
    


#----Parametrage de l'apparence----
customtkinter.set_appearance_mode("system")
customtkinter.set_default_color_theme("blue")


#----AFFICHAGE----
#Créer ma fenetre
fenetre = customtkinter.CTk()

#Paramètre de la fenêtre
fenetre.title("YT_Video_Downloader.exe")
fenetre_longueur,fenetre_largeur = fenetre.winfo_screenwidth(),fenetre.winfo_screenheight()
fenetre.geometry((f"{round(fenetre_longueur//1.5)}x{round(fenetre_largeur//1.5)}"))
fenetre.iconbitmap('setup/youtube.ico')



#Créer un Frame pour afficher mes éléments
frame = customtkinter.CTkFrame(fenetre, fg_color="transparent")
frame.pack(expand=True, pady=5)


#Définir espacement entre les lignes / colones
frame.rowconfigure(2, weight=1, minsize=100)





#Créer les éléments de la fenêtre

#----Ligne 0----(Logo)
    
#Logo
image = Image.open('setup/logo_yt.png')
image_tk = customtkinter.CTkImage(light_image=image, size=(400,175))


label_Logo = customtkinter.CTkLabel(frame, text="", image=image_tk)
label_Logo.grid(row=0,column=1, columnspan=2)

#----Ligne 1----(Nom, Version)

#Nom de l'app
label_AppName = customtkinter.CTkLabel(frame, text='Video Downloader', font=("Arial", 18))
label_AppName.grid(row=1, column=2, sticky='NE')

#Version de l'app
label_Version = customtkinter.CTkLabel(frame, text='V2.3', font=("Arial", 10))
label_Version.grid(row=1, column=3, sticky='SW', ipadx=8, pady=2)


#----Ligne 2----(Search-Bar, )

#Barre de recherche
entry_Search_bar = customtkinter.CTkEntry(frame, width=680, height=40, font=("Arial", 18), text_color='grey')
entry_Search_bar.insert(0,"Entrez l'URL de la vidéo")
entry_Search_bar.grid(row=2, column=0, columnspan=4)

entry_Search_bar.bind('<Button-1>', search_bar_on_click)


#----Ligne 3----(Search-button, Download-button, Cancel-button, Folder-button)

#Boutton de recherche
button_search = customtkinter.CTkButton(frame, text='Rechercher 🔍', font=('Arial', 18))
button_search.grid(row=3, column=0, padx = 5)
button_search.bind('<Button-1>', button_search_press)

#Boutton de Téléchargement 
button_Download = customtkinter.CTkButton(frame, text='Télécharger 💾', font=('Arial', 18))
button_Download.grid(row=3, column=1, padx = 5)
button_Download.bind('<Button-1>', download_video)

#Boutton annuler 
button_cancel = customtkinter.CTkButton(frame, text='Annuler ❌', font=('Arial', 18))
button_cancel.grid(row=3, column=2, padx = 5)
button_cancel.bind('<Button-1>', button_cancel_press)

#Boutton de répertoire
button_Folder = customtkinter.CTkButton(frame, text='Répertoire 📁', font=('Arial', 18))
button_Folder.grid(row=3,column=3, padx = 5)
button_Folder.bind('<Button-1>',button_Folder_press)


#----Ligne 4----(Validation-Message)

#Message de Validation
label_Validation = customtkinter.CTkLabel(frame, text='', font=('Arial', 14), text_color='grey')
label_Validation.grid(row=4, column=0, columnspan=4, pady=10)

#----Ligne 5----(Progress-Bar)

#Barre de Progression
label_Pourcentage = customtkinter.CTkLabel(frame, text='', font=('Arial', 14))
label_Pourcentage.grid(row=5, column=3, sticky='e', padx=5, pady=10)

progressBar = customtkinter.CTkProgressBar(frame, width=600, height=8)
progressBar.set(0)


#----Ligne 6----()

label_Repertoire = customtkinter.CTkLabel(frame, text=f'Folder : {formater_chemin_dossier()}', font=('Arial', 14), text_color='orange')
label_Repertoire.grid(row=6, column=0, columnspan=3)

button_Folder = customtkinter.CTkButton(frame, text='Modify', fg_color='grey', width=5)
button_Folder.grid(row=6, column = 3)
button_Folder.bind('<Button-1>', default_video_folder_set)

#Ouvrir la fenêtre
fenetre.mainloop()





