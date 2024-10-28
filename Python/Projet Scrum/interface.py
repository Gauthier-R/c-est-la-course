import customtkinter as ctk

from ajouter_tache import Tache


class Application :
    
    def __init__(self) :
        self.app = ctk.CTk()
        self.screen_w = self.app.winfo_screenwidth()
        self.screen_h = self.app.winfo_screenheight()
        
        self.app.geometry(f"{self.screen_w//2}x{self.screen_h//2}")
        self.app.title("SCRUM BOARD")
        
        ctk.set_appearance_mode("light")
        
        
    def interface(self):
        
        self.onglets() 
        
        self.onglet_sprint()
        
        for sprint in range(4) :
            self.sprint(sprint=sprint)
            
            for tache in range(20):
                self.tache(tache=tache)
        
        
        
        
    def onglets(self): #Créer les onglets
        
        self.onglet = ctk.CTkTabview(self.app)
        self.onglet.pack(expand = True, fill = "both")
        
        self.onglet.add("Sprint")
        self.onglet.add("To DO") 
        
    def onglet_sprint(self): #Créer l'interface de l'onglet sprint
        self.frame_main_sprints = ctk.CTkFrame(self.onglet.tab("Sprint"), fg_color= "white")
        self.frame_main_sprints.pack(expand = True, fill="both", padx=50, pady=20)
        
        self.label_sprint = ctk.CTkLabel(self.frame_main_sprints, text="Vos Sprints :", font=("Arial", 25))
        self.label_sprint.pack(anchor = "nw", padx = 10, pady = 10)
        
        self.frame_all_sprints = ctk.CTkScrollableFrame(self.frame_main_sprints)
        self.frame_all_sprints.pack(expand = True, fill = "both", padx = 10, pady = 10)
        
        self.button_sprint_add = ctk.CTkButton(self.frame_main_sprints, text="+ Ajouter Sprint")
        self.button_sprint_add.pack(pady = 10)
        
    def sprint(self, sprint): #Afficher des sprints
        
            self.frame_sprint = ctk.CTkFrame(self.frame_all_sprints, height=200, fg_color="yellow")
            self.frame_sprint.pack(fill= "x", padx = 10, pady = 10)
            
            self.frame_sprint.columnconfigure(1, weight=1)
            
            self.label_sprint_num = ctk.CTkLabel(self.frame_sprint, text=f"Sprint n°{sprint+1}", font=("Arial",16))
            self.label_sprint_num.grid(row = 0, column = 0, sticky = "nw", padx = 10, pady = 5)
            
            self.button_sprint_run = ctk.CTkButton(self.frame_sprint, text="RUN",  text_color="white", font=("Arial",14), fg_color="green")
            self.button_sprint_run.grid(row = 0, column = 1, sticky = "e", padx = 10, pady = 5)
            
            self.button_sprint_run = ctk.CTkButton(self.frame_sprint, text="Supprimer",  text_color="white", font=("Arial",14), fg_color="red")
            self.button_sprint_run.grid(row = 0, column = 2, sticky = "e", padx = 10, pady = 5)
            
            self.button_tache_add = ctk.CTkButton(self.frame_sprint, text="Ajouter une\n\nTâche", font=("Arial", 18,), fg_color="green",height= 150, width=120, anchor="center", command= self.creer_tache)
            self.button_tache_add.grid(row = 1, column = 0, padx = 10, pady =5)
            
            self.frame_all_taches = ctk.CTkScrollableFrame(self.frame_sprint, orientation="horizontal", height=150, fg_color="transparent")
            self.frame_all_taches.grid(row = 1, column = 1, columnspan = 2, sticky = "ew")
            
    def tache(self, tache): #Afficher des taches
        
            self.button_tache = ctk.CTkButton(self.frame_all_taches, text=f"Tâche n°{tache+1}", font=("Arial", 18,),height= 145, width=150, anchor="center")
            self.button_tache.grid(row = 1, column = tache+1, padx = 10, pady =5)
        
    def creer_tache(self): #Créer une nouvelle tache
        tache_test = Tache(app=self.app)
        tache_test.interface_tache()     
        

    
                
        
    def run_app(self):
        self.app.mainloop()