from pytube import Search, YouTube, Playlist
import customtkinter
from tkinter import Tk, END, filedialog
import os
import json
import time
from PIL import Image


class Pytube_Search:
    
    def __init__(self, ENTRY = None, BUTTON1 = None, BUTTON2 = None, BUTTON3 = None, OPTION_MENU_RESOLUTION = None, FRAME=None):
        self.element = ''
        self.list_title_id = {}
        self.link_download = None
        self.RESOLUTION = ["HIGHEST", "LOWEST"]
        
        self.FRAME = FRAME
        self.ENTRY = ENTRY
        self.BUTTON1 = BUTTON1
        self.BUTTON2 = BUTTON2
        self.BUTTON3 = BUTTON3
        self.OPTION_MENU_RESOLUTION = OPTION_MENU_RESOLUTION
        
        
    
    def search_element(self): #Rechercher avec Pytube l'élément de la barre de recherche et stocker titre + url des 3 première vidéos
        self.list_title_id = {}
        self.RESOLUTION = ['HIGHEST','LOWEST']
        
        if 'youtube.com/playlist?list=' in str(self.element) :
            self.link_download = str(self.element)
            self.BUTTON1.configure(text='',command=lambda t="": self.select_element(t), hover=False, state='disabled')
            self.BUTTON2.configure(text='',command=lambda t="": self.select_element(t), hover=False, state='disabled')
            self.BUTTON3.configure(text='',command=lambda t="": self.select_element(t), hover=False, state='disabled')
           
            
        else:
            search = Search(str(self.element))
            
            for result in search.results[:3]:
                self.list_title_id[result.title] = str('https://youtu.be/' + result.video_id)
                
            first_key = next(iter(self.list_title_id))
            self.link_download = self.list_title_id[first_key]
            self.FRAME.update()
        print(f'Lien à télécharger : {self.link_download}')
        self.RESOLUTION = ["HIGHEST", "LOWEST"]
        self.OPTION_MENU_RESOLUTION.configure(values=self.RESOLUTION)
        if self.OPTION_MENU_RESOLUTION.get() != "LOWEST":
            self.OPTION_MENU_RESOLUTION.set("HIGHEST")
              
    
    def select_element(self, button_text): #Récupérer la vidéo et l'url de la proposition sélectionné par l'utilisateur
        if button_text != "":
            if button_text in self.list_title_id:
                self.link_download = self.list_title_id[button_text]
                
            print(f"Le texte du bouton est : {button_text}")
            print(f"Le lien à télécharger est : {self.link_download}")
            self.ENTRY.delete(0,END)
            self.ENTRY.insert(0,str(button_text))
            self.BUTTON1.configure(text='',command=lambda t="": self.select_element(t), hover=False, state='disabled')
            self.BUTTON2.configure(text='',command=lambda t="": self.select_element(t), hover=False, state='disabled')
            self.BUTTON3.configure(text='',command=lambda t="": self.select_element(t), hover=False, state='disabled')
            self.ENTRY.update()
            self.get_resolution()
            
            
    def get_resolution(self): #Obtenir les résolutions possible pour la vidéo recherché
        self.RESOLUTION = ["HIGHEST", "LOWEST"]
        yt = YouTube(self.link_download)
        yt_quality = yt.streams.filter(progressive=True, file_extension='mp4')
        liste_resolution = set()
        for stream in yt_quality:
            liste_resolution.add(stream.resolution)
        liste_resolution = sorted(liste_resolution)
        for resolution in liste_resolution:
            self.RESOLUTION.insert(1,resolution)
        self.OPTION_MENU_RESOLUTION.configure(values=self.RESOLUTION)
        print(self.RESOLUTION)
        
        
class Pytube_Download:
    
    def __init__(self, link_download = None, FORMAT = None, RESOLUTION = None, FOLDER = None, PROGRESSBAR = None, LABEL_POURCENTAGE = None, LABEL_INFO = None):
        self.LINK = link_download
        self.FORMAT = FORMAT
        self.RESOLUTION = RESOLUTION
        self.FOLDER = FOLDER
        self.PROGRESSBAR = PROGRESSBAR
        self.LABEL_POURCENTAGE = LABEL_POURCENTAGE
        self.LABEL_INFO = LABEL_INFO
        
        self.playlist = None #playlist à télécharger
        self.LABEL_NB_PLAYLIST = '' #Nombre de vidéos à télécharger dans la playlist
        self.search = None #Liste de vidéos recherché
        self.yt_video = [] #liste des vidéos à paramétrer
        self.yt_video_download = [] #liste des vidéos à télécharger
        
        
    def manage_step_downloading(self): #Déclencher les méthodes dans l'ordre pour télécharger les vidéos
        self.initialize_download()
        self.search_type_of_link()
        self.configure_download_type()
        self.download()
         
        
    def initialize_download(self): #Initialiser les paramêtres de vidéos
        self.playlist = None 
        self.search = None 
        self.yt_video = [] 
        self.yt_video_download = [] 
        
        
    def search_type_of_link(self) : #Vérifier si le lien est une vidéo ou une playlist
        #PLAYLIST
        if 'youtube.com/playlist?list=' in self.LINK:
            print("playlist")
            self.playlist = Playlist(self.LINK)
            for video in self.playlist:
                self.yt_video.append(YouTube(video, on_progress_callback=self.download_progress))
               
            
        #VIDEO
        elif 'https://youtu.be/' in self.LINK:
            print("Vidéo")
            self.yt_video.append(YouTube(self.LINK, on_progress_callback=self.download_progress))
             
        #ERREUR
        else :
            print("Erreur - Lien non conforme")
            self.search = Search(self.LINK)
            
        
    def get_titre_playlist(self): #Récupérer le titre d'une PlayList 
        return self.playlist.title

    
    def get_nb_video_in_playlist(self): #Récupérer le nombre de vidéos dans un Playlist 
        return len(self.playlist)
    
    
    def get_titre_video(self): #Récupérer le titre des vidéos 
        for video in self.yt_video:
            return video.title
    
    
    def get_author_video(self): #Récupérer l'auteur des vidéos 
        return self.yt_video[0].author

    
    def configure_download_type(self): #Définir le format de téléchargement (vidéo / musique)
        if self.FORMAT == 'MP3':
            for video in self.yt_video :
                self.yt_video_download.append(video.streams.get_audio_only())
        elif self.FORMAT == 'MP4':
            if self.RESOLUTION == "HIGHEST":
                for video in self.yt_video:
                    self.yt_video_download.append(video.streams.get_highest_resolution())
                    print("HIGHEST")
            elif self.RESOLUTION == "LOWEST":
                for video in self.yt_video:
                    self.yt_video_download.append(video.streams.get_lowest_resolution())
                    print("LOWEST")
            else:
                for video in self.yt_video:
                    self.yt_video_download.append(video.streams.get_by_resolution(resolution= self.RESOLUTION))
                    print(self.RESOLUTION)
                
     
    def download(self): #Télécharger les vidéos
        for index, video in enumerate(self.yt_video_download):
            if self.playlist != None:
                self.LABEL_INFO.configure(text = f'Téléchargement en cours ... ({index+1}/{len(self.playlist)})')
                self.LABEL_INFO.update()
            video.download(self.FOLDER)
        print("Téléchargement terminé")

    
    def download_progress(self, stream, chunk, bytes_restant): #Calculer la progression du téléchargement
        taille_totale = stream.filesize
        bytes_telecharge = taille_totale-bytes_restant
        pourcentage_telecharge = bytes_telecharge/taille_totale*100
        
        self.PROGRESSBAR.set(float(pourcentage_telecharge)/100) #Actualiser la barre de progression
             
        pourcentage_text = str(int(pourcentage_telecharge))
        self.LABEL_POURCENTAGE.configure(text=pourcentage_text+'%')
        self.LABEL_POURCENTAGE.update()
        print(pourcentage_telecharge, pourcentage_text)
                
                
class Folder:
    
    def __init__(self, LABEL_PATH=None) :
        self.path_json_file = "setup/Default_Localisation_Folder.json"
        self.LABEL_PATH = LABEL_PATH
    

    def load_preferences(self, filename): #Charger les préférences depuis un fichier JSON
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
        
 
    def save_preferences(self, filename, localisation): #Sauvegarder les préférences dans un fichier JSON
        with open(filename, 'w') as f:
            json.dump(localisation, f)
            

    def button_Folder_press(self): #Ouvrir l'explorateur au dossier de téléchargement défini
        folder = self.default_video_folder_first()
        if os.path.exists(folder):
            os.startfile(folder)
        else:
            os.makedirs(folder)
            os.startfile(folder)
            
    
    def default_video_folder_first(self): #Définir le répertoire de fichier par défault la première fois -> lié à bouton DOWNLOAD
        clefs = self.load_preferences(self.path_json_file)
        chemin_dossier = clefs.get("default_directory")
        if chemin_dossier is None:
            chemin_dossier = self.definir_dossier()
            clefs["default_directory"] = chemin_dossier
            self.save_preferences(self.path_json_file, clefs)
        return chemin_dossier
    
    
    def default_video_folder_get(self): #Obtenir le répertoire de fichier -> lié à label PATH
        clefs = self.load_preferences(self.path_json_file)
        chemin_dossier = clefs.get("default_directory")
        if chemin_dossier is None:
            return "Undefined"
        else:
            return chemin_dossier
        
        
    def default_video_folder_set(self): #REdéfinir le répertoire de fichier -> lié à bouton MODIFY
        clefs = self.load_preferences(self.path_json_file)
        save = clefs.get("default_directory")
        chemin_dossier = self.definir_dossier(save)
        clefs["default_directory"] = chemin_dossier
        self.save_preferences(self.path_json_file, clefs)
        self.LABEL_PATH.configure(text=f'Folder : {self.formater_chemin_dossier()}')
        self.LABEL_PATH.update()
    
    
    def definir_dossier(self, save = 'Undefined'): #Ouvrir l'interface pour le répertoire de dépôt par défaut
    #Ouvrir une fenêtre pour l'explorateur de fichier
        explorateur = Tk()
        explorateur.withdraw()
        chemin_dossier = filedialog.askdirectory()
        if chemin_dossier == '':
            chemin_dossier = save
        explorateur.destroy()
        return chemin_dossier
    

    def formater_chemin_dossier(self): #Formater le Label pour le répertoire par défaut
        chemin = self.default_video_folder_get()
        parties = chemin.split('/')
        if len(parties) > 3:
            chemin = parties[0]+'/'+parties[1]+'/'+parties[2]+'/[...]/'+parties[-1]
        else:
            chemin = self.default_video_folder_get()
        return chemin           
            
        
class Main_Screen:
    
    def __init__(self) :
        self.SEARCH = Pytube_Search()
        self.DOWNLOAD = Pytube_Download()
        self.FOLDER = Folder()
        self.TIMER_ID = None
        
        #Paramétrage type affichage
        customtkinter.set_appearance_mode("system")
        customtkinter.set_default_color_theme("blue")
    
        
        #Configuration de la fenêtre principale
        self.SCREEN = customtkinter.CTk()
        self.SCREEN.title("YTV_Downloader")
        screen_widht,screen_height = self.SCREEN.winfo_screenwidth(),self.SCREEN.winfo_screenheight()
        self.SCREEN.geometry((f"{round(screen_widht//1.5)}x{round(screen_height//1.5)}"))
        self.SCREEN.iconbitmap('setup/youtube.ico')
        
        #Créer un Frame pour afficher les éléments
        self.FRAME = customtkinter.CTkFrame(self.SCREEN, fg_color="transparent")
        self.FRAME.pack(expand=True, pady=5)
        
        #Créer le Logo
        image = Image.open('setup/logo_yt.png')
        image_tk = customtkinter.CTkImage(light_image=image, size=(400,175))


        self.LABEL_LOGO = customtkinter.CTkLabel(self.FRAME, text="", image=image_tk)
        self.LABEL_LOGO.grid(row=0,column=0, columnspan=2)
        
        #Créer la barre de recherche
        self.ENTRY = customtkinter.CTkEntry(self.FRAME, width=680, height=40, font=("Arial", 18), text_color='grey')
        self.ENTRY.insert(0,"Rechercher le nom ou l'URL de la vidéo")
        self.ENTRY.grid(row=1, column=0, padx = 5, pady = 5)
        self.ENTRY.bind('<Button-1>', self.entry_on_click)
        self.ENTRY.bind("<KeyRelease>", self.reset_timer)

        #Créer les boutons de proposition :
        self.BUTTON_SEARCH1 = customtkinter.CTkButton(self.FRAME,text="", text_color=("black", "white"), font=('Arial', 12), width=680, fg_color='transparent', border_width=0, hover=False)
        self.BUTTON_SEARCH1.grid(row=2, column=0)
        self.BUTTON_SEARCH2 = customtkinter.CTkButton(self.FRAME,text="", text_color=("black", "white"), font=('Arial', 12), width=680, fg_color='transparent', border_width=0, hover=False)
        self.BUTTON_SEARCH2.grid(row=3, column=0)
        self.BUTTON_SEARCH3 = customtkinter.CTkButton(self.FRAME,text="", text_color=("black", "white"), font=('Arial', 12), width=680, fg_color='transparent', border_width=0, hover=False)
        self.BUTTON_SEARCH3.grid(row=4, column=0)
        
        #Créer une liste déroulante pour choisir le format:
        self.SELECTED_FORMAT = customtkinter.StringVar(value="MP4")
        self.FORMAT = ["MP4", "MP3"]
        self.OPTION_MENU_FORMAT = customtkinter.CTkOptionMenu(self.FRAME, variable=self.SELECTED_FORMAT, values=self.FORMAT, width=100)
        self.OPTION_MENU_FORMAT.grid(row=1, column=1)
        
        #Créer une liste déroulante pour choisir la résolution :
        self.SELECTED_RESOLUTION = customtkinter.StringVar(value="HIGHEST")
        self.OPTION_MENU_RESOLUTION = customtkinter.CTkOptionMenu(self.FRAME, variable=self.SELECTED_RESOLUTION, values=self.SEARCH.RESOLUTION, width=100)
        self.OPTION_MENU_RESOLUTION.grid(row=2, column=1)
        
        # Passer les références d'ENTRY, BUTTON_SEARCH et OPTION_MENU_RESOLUTION à l'instance de Pytube_Search
        self.SEARCH.FRAME = self.FRAME
        self.SEARCH.ENTRY = self.ENTRY
        self.SEARCH.BUTTON1 = self.BUTTON_SEARCH1
        self.SEARCH.BUTTON2 = self.BUTTON_SEARCH2
        self.SEARCH.BUTTON3 = self.BUTTON_SEARCH3
        self.SEARCH.OPTION_MENU_RESOLUTION = self.OPTION_MENU_RESOLUTION 
        
        #Créer le bouton de Téléchargement :
        self.BUTTON_DOWNLOAD = customtkinter.CTkButton(self.FRAME, text='Télécharger 💾', font=('Arial', 18), command=self.button_download_click)
        self.BUTTON_DOWNLOAD.grid(row=1, column=2)
        
        #Créer le bouton pour ouvrir son répertoire de fichier :
        self.BUTTON_FOLDER = customtkinter.CTkButton(self.FRAME, text='Répertoire 📁', font=('Arial', 18), command=self.FOLDER.button_Folder_press)
        self.BUTTON_FOLDER.grid(row=3,column=2, pady = 5)
        
        #Créer le bouton pour définir le répertoire par défaut :
        self.BUTTON_MODIFY = customtkinter.CTkButton(self.FRAME, text='Modify', fg_color='grey', command=self.FOLDER.default_video_folder_set)
        self.BUTTON_MODIFY.grid(row=4, column = 2)
        
        #Créer le label pour connaître le répertoire par défaut :
        self.LABEL_PATH = customtkinter.CTkLabel(self.FRAME, text=f'Folder : {self.FOLDER.formater_chemin_dossier()}', font=('Arial', 10), text_color='orange')
        self.LABEL_PATH.grid(row=5, column=2)
        self.FOLDER.LABEL_PATH = self.LABEL_PATH
        
        #Barre de Progression
        self.LABEL_POURCENTAGE = customtkinter.CTkLabel(self.FRAME, text='', font=('Arial', 14))
        self.LABEL_POURCENTAGE.grid(row=5, column=1, sticky = "w")

        self.PROGRESSBAR = customtkinter.CTkProgressBar(self.FRAME, width=600, height=8)
        self.PROGRESSBAR.set(0)
        
        #Label Informatif
        self.LABEL_INFO = customtkinter.CTkLabel(self.FRAME, text='', font=('Arial', 20), text_color='grey')
        self.LABEL_INFO.grid(row=6, column=0)
        
        

        #Créer la fenêtre
        self.SCREEN.mainloop()
        
        
              
    def vérifier_contenu(self): #Vérifier le contenu de la barre de recherche
        
        if self.ENTRY.get() != '' and self.ENTRY.get() != self.SEARCH.element:
            self.SEARCH.element = self.ENTRY.get()
            self.SEARCH.search_element()

            
            if len(self.SEARCH.list_title_id) == 1:
                for element in self.SEARCH.list_title_id:
                    self.BUTTON_SEARCH1.configure(text=str(element), command=lambda t=str(element): self.SEARCH.select_element(t), hover=True, state='normal')
                    self.BUTTON_SEARCH2.configure(text="", command=lambda t="": self.SEARCH.select_element(t))
                    self.BUTTON_SEARCH3.configure(text="", command=lambda t="": self.SEARCH.select_element(t))
                    
            else:
                for index, element in enumerate(self.SEARCH.list_title_id):
                    if index == 0: self.BUTTON_SEARCH1.configure(text=str(element), command=lambda t=str(element): self.SEARCH.select_element(t), hover=True, state='normal')
                    if index == 1: self.BUTTON_SEARCH2.configure(text=str(element), command=lambda t=str(element): self.SEARCH.select_element(t), hover=True, state='normal')
                    if index == 2: self.BUTTON_SEARCH3.configure(text=str(element), command=lambda t=str(element): self.SEARCH.select_element(t), hover=True, state='normal')
        
        else:
            self.BUTTON_SEARCH1.configure(text='',command=lambda t="": self.SEARCH.select_element(t), hover=False, state='disabled')
            self.BUTTON_SEARCH2.configure(text='',command=lambda t="": self.SEARCH.select_element(t), hover=False, state='disabled')
            self.BUTTON_SEARCH3.configure(text='',command=lambda t="": self.SEARCH.select_element(t), hover=False, state='disabled')
    
    
    def entry_on_click(self, event): #Si l'utilisateur clique sur la barre de recherche
        if self.ENTRY.cget('text_color') == "grey":
            self.ENTRY.delete(0, END)
            self.ENTRY.configure(text_color= ("black", "white"))
        
        
    def reset_timer(self, event=None): #Reset le timer si l'utilisateur écrit dans la barre de recherche
        if self.TIMER_ID is not None:
            self.SCREEN.after_cancel(self.TIMER_ID)
        self.TIMER_ID = self.SCREEN.after(800, self.on_timeout)
        

    def on_timeout(self): #Si l'utilisateur n'écrit plus faire vérifier le contenu et réinitialiser le timer
        self.TIMER_ID
        self.vérifier_contenu()
        self.TIMER_ID = None

    
    def button_download_click(self): #Si l'utilisateur clique sur le boutton téléchargement
        
        #Réinitialiser le self.SEARCH.element
        self.SEARCH.element = ''
        
        #Nettoyer la barre de recherche
        self.ENTRY.delete(0, END)
        self.ENTRY.configure(text_color="grey")
        self.ENTRY.insert(0,"Rechercher le nom ou l'URL de la vidéo")
        self.BUTTON_DOWNLOAD.focus_set()
        self.FRAME.update()
        
        #Nettoyer les elements de recherche
        self.BUTTON_SEARCH1.configure(text='',command=lambda t="": self.select_element(t), hover=False, state='disabled')
        self.BUTTON_SEARCH2.configure(text='',command=lambda t="": self.select_element(t), hover=False, state='disabled')
        self.BUTTON_SEARCH3.configure(text='',command=lambda t="": self.select_element(t), hover=False, state='disabled')
        
        #Afficher la barre de téléchargement et les labels
        self.LABEL_INFO.configure(text=f'Téléchargement en cours ...', text_color="grey")
        self.PROGRESSBAR.grid(row=5, column=0)
        self.DOWNLOAD.PROGRESSBAR = self.PROGRESSBAR
        self.DOWNLOAD.LABEL_POURCENTAGE = self.LABEL_POURCENTAGE
        self.FRAME.update()
        time.sleep(1)
        
        #Récupérer le répertoire de FOLDER et l'envoyer vers DOWNLOAD
        self.DOWNLOAD.FOLDER = self.FOLDER.default_video_folder_first()
        #Récupérer le lien de SEARCH et l'envoyer dans DOWNLOAD
        self.DOWNLOAD.LINK = self.SEARCH.link_download
        #Récupérer le format et l'envoyer dans DOWNLOAD
        self.DOWNLOAD.FORMAT = self.SELECTED_FORMAT.get()
        #Récupérer la résolution et l'envoyer dans DOWNLOAD
        self.DOWNLOAD.RESOLUTION = self.OPTION_MENU_RESOLUTION.get()
        #Récupérer le label info et l'envoyer dans DOWNLOAD
        self.DOWNLOAD.LABEL_INFO = self.LABEL_INFO
        
        #Lancer les étapes de téléchargement
        self.DOWNLOAD.manage_step_downloading()
        #Retirer la barre de téléchargement et les labels
        self.LABEL_INFO.configure(text='Téléchargement Terminé ! ', text_color="green")
        self.PROGRESSBAR.grid_remove()
        self.LABEL_POURCENTAGE.configure(text='')
               

if __name__ == '__main__':
    main = Main_Screen()
    
    







