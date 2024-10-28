import customtkinter as ctk

class Tache :
    
    def __init__(self, app, titre = None, tag = [], difficulte = None, valeur = None, description = None, commentaire = None, assignation = None) :
        #Info application
        self.app = app
        self.screen_w = app.winfo_width()
        self.screen_h = app.winfo_height()
        self.main_pos_x = app.winfo_x()
        self.main_pos_y = app.winfo_y()
        
        #Info Tache
        self.titre = titre
        self.tag = tag
        self.difficulte = difficulte
        self.valeur = valeur
        self.description = description
        self.commentaire = commentaire
        self.assignation = assignation
        
        
        
    def interface_tache(self):
        self.fenetre_tache()
        self.tache()
        
        
    def fenetre_tache(self): #Créer la fenêtre de la tache
        self.window_tache = ctk.CTkToplevel(self.app)
        self.window_tache.title("Créer une tâche")
        
        self.app.update_idletasks()
        
        # Calculer les coordonnées pour centrer la fenêtre secondaire
        x = self.main_pos_x + (self.screen_w // 2) - (self.screen_w // 4)
        y = self.main_pos_y + (self.screen_h // 2) - (self.screen_h // 4)
        self.window_tache.geometry(f"{self.screen_w//2}x{self.screen_h//2}+{x}+{y}")
        
        self.window_tache.grab_set() #Met la fenêtre au premier plan et la rend modale (Empêche l'interaction avec la fenêtre principale)
        
    
    def tache(self): #Créer l'interface de la fenêtre tache
        self.frame_main_tache = ctk.CTkFrame(self.window_tache, corner_radius=0)
        self.frame_main_tache.pack(expand = True, fill = "both", padx = 10)
        
        self.frame_main_tache.columnconfigure(0, weight=1)
        self.frame_main_tache.columnconfigure(1, weight=6)
        self.frame_main_tache.columnconfigure(2, weight=1)
        
        #TITRE
        self.label_titre = ctk.CTkLabel(self.frame_main_tache, text="Titre : ", font=("Arial", 16))
        self.label_titre.grid(row = 0, column = 0, sticky = 'e', padx = 10, pady = 20)
        
        self.entry_titre = ctk.CTkEntry(self.frame_main_tache)
        self.entry_titre.grid(row = 0, column = 1, sticky = 'ew', padx = 20, pady = 20)
        
        #TAG
        self.label_tag = ctk.CTkLabel(self.frame_main_tache, text="TAG : ", font=("Arial", 16))
        self.label_tag.grid(row = 1, column = 0, sticky = 'e', padx = 10, pady = 20)
        
        self.entry_tag = ctk.CTkEntry(self.frame_main_tache)
        self.entry_tag.grid(row = 1, column = 1, sticky = 'ew', padx = 20, pady = 20)
        
        #DIFFICULTE
        self.label_difficulte = ctk.CTkLabel(self.frame_main_tache, text="Difficulté : ", font=("Arial", 16))
        self.label_difficulte.grid(row = 2, column = 0, sticky = 'e', padx = 10, pady = 20)
        
        self.entry_difficulte = ctk.CTkEntry(self.frame_main_tache)
        self.entry_difficulte.grid(row = 2, column = 1, sticky = 'ew', padx = 20, pady = 20)
        
        
        
    