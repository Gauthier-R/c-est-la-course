import customtkinter as ctk
from tkinter import messagebox  # Importation pour les messages d'avertissement
from scrum import ScrumBoard  # Importe la classe ScrumBoard depuis ton fichier de base de données

class SprintApp(ctk.CTk):  
    def __init__(self):
        super().__init__()
        self.title("Application Scrum")
        self.geometry("800x600")

        # Utilisation du mode sombre de customtkinter
        ctk.set_appearance_mode("light")
        ctk.set_default_color_theme("blue")

        # Connexion à la base de données
        self.board = ScrumBoard('scrum.db')

        # Onglets
        self.notebook = ctk.CTkTabview(self)  
        self.notebook.pack(expand=True, fill='both')

        self.notebook.add("Sprints")
        self.notebook.add("To Do / Doing / Done")

        self.sprint_frame = self.notebook.tab("Sprints")
        
        self.main_frame = ctk.CTkFrame(self.sprint_frame)
        self.main_frame.pack(fill=ctk.BOTH, expand=True)

        self.left_frame = ctk.CTkFrame(self.main_frame)
        self.left_frame.pack(side='left', fill=ctk.BOTH, expand=True, padx=10, pady=10)

        self.task_container = ctk.CTkFrame(self.left_frame)
        self.task_container.pack(fill=ctk.BOTH, expand=True, padx=5, pady=5)
        
        add_task_button = ctk.CTkButton(self.left_frame, text="Ajouter une tâche", command=self.open_task_window)
        add_task_button.pack(pady=5)

        # Charger les tâches de la base de données lors de l'initialisation
        self.load_taches()

        self.right_frame = ctk.CTkFrame(self.main_frame)
        self.right_frame.pack(side='right', fill=ctk.BOTH, expand=True, padx=10, pady=10)

        self.label = ctk.CTkLabel(self.right_frame, text="Nombre de sprints souhaité")
        self.label.pack(pady=10)

        self.nb_sprints = ctk.CTkEntry(self.right_frame)
        self.nb_sprints.pack(pady=5)

        self.generer_bouton = ctk.CTkButton(self.right_frame, text="Générer les sprints", command=self.generer_sprints)
        self.generer_bouton.pack(pady=10)

        self.sprint_container = ctk.CTkFrame(self.right_frame)
        self.sprint_container.pack(fill=ctk.BOTH, expand=True)

        self.canvas = ctk.CTkCanvas(self.sprint_container)
        self.canvas.pack(side='top', fill=ctk.BOTH, expand=True)

        self.sprint_inner_frame = ctk.CTkFrame(self.canvas)
        self.canvas.create_window((0, 0), window=self.sprint_inner_frame, anchor='nw')

        self.scrollbar = ctk.CTkScrollbar(self.sprint_container, orientation="horizontal", command=self.canvas.xview)
        self.scrollbar.pack(side="bottom", fill="x")
        self.canvas.configure(xscrollcommand=self.scrollbar.set)

        self.todo_frame = self.notebook.tab("To Do / Doing / Done")
        self.create_todo_board()

    def load_taches(self):
        taches = self.board.get_all_taches()

        # Vider le container avant de recharger les tâches
        for widget in self.task_container.winfo_children():
            widget.destroy()

        # Boucle sur chaque tâche pour créer un ticket graphique avec un bouton de suppression et de modification
        for tache in taches:
            task_frame = ctk.CTkFrame(self.task_container, corner_radius=10, border_color="black", border_width=2)
            task_frame.pack(fill="x", padx=5, pady=5)

            # Titre de la tâche
            task_title = ctk.CTkLabel(task_frame, text=f"Titre: {tache[0]}", font=('Arial', 14, 'bold'))
            task_title.pack(anchor='w', padx=10, pady=2)

            # Description de la tâche
            task_description = ctk.CTkLabel(task_frame, text=f"Description: {tache[1]}")
            task_description.pack(anchor='w', padx=10, pady=2)

            # Informations supplémentaires
            task_info = ctk.CTkLabel(task_frame, text=f"Priorité: {tache[2]}, Valeur: {tache[3]}, Coût: {tache[4]}")
            task_info.pack(anchor='w', padx=10, pady=2)

            # Bouton pour supprimer la tâche
            delete_button = ctk.CTkButton(task_frame, text="Supprimer", fg_color="red", command=lambda tache=tache: self.supprimer_tache(tache[0]))
            delete_button.pack(anchor='e', padx=10, pady=2)

            # Bouton pour modifier la tâche
            modify_button = ctk.CTkButton(task_frame, text="Modifier", command=lambda tache=tache: self.open_modify_window(tache))
            modify_button.pack(anchor='e', padx=10, pady=2)

    def open_modify_window(self, tache):
        # Fenêtre affichée pour modifier les détails de la tâche
        modify_window = ctk.CTkToplevel(self)
        modify_window.title("Modifier la tâche")
        modify_window.attributes("-topmost", True)
        modify_window.focus_force()

        # Champ pour le nom de la tâche
        ctk.CTkLabel(modify_window, text="(*) Nom de la tâche:").pack(pady=5)
        task_name_entry = ctk.CTkEntry(modify_window)
        task_name_entry.insert(0, tache[0])  # Remplir avec le titre existant
        task_name_entry.pack(pady=5)

        # Champ pour la description de la tâche
        ctk.CTkLabel(modify_window, text="Description:").pack(pady=5)
        task_description_entry = ctk.CTkEntry(modify_window)
        task_description_entry.insert(0, tache[1])  # Remplir avec la description existante
        task_description_entry.pack(pady=5)

        # Créer les variables pour les listes déroulantes
        selected_value = ctk.StringVar(value=tache[3])  # Remplir avec la valeur existante
        selected_cost = ctk.StringVar(value=tache[4])  # Remplir avec le coût existant
        selected_priority = ctk.StringVar(value=tache[2])  # Remplir avec la priorité existante

        VALUE_OPTIONS = ["1", "2", "3", "4", "5"]
        ctk.CTkLabel(modify_window, text="Valeur:").pack(pady=5)
        value_menu = ctk.CTkOptionMenu(modify_window, variable=selected_value, values=VALUE_OPTIONS, width=100)
        value_menu.pack(pady=5)

        COST_OPTIONS = ["1", "2", "3", "4", "5"]
        ctk.CTkLabel(modify_window, text="Coût:").pack(pady=5)
        cost_menu = ctk.CTkOptionMenu(modify_window, variable=selected_cost, values=COST_OPTIONS, width=100)
        cost_menu.pack(pady=5)

        PRIORITY_OPTIONS = ["P1", "P2", "P3"]
        ctk.CTkLabel(modify_window, text="Priorité:").pack(pady=5)
        priority_menu = ctk.CTkOptionMenu(modify_window, variable=selected_priority, values=PRIORITY_OPTIONS, width=100)
        priority_menu.pack(pady=5)

        # Fonction de soumission des modifications
        def submit_modification():
            new_task_name = task_name_entry.get()
            new_task_description = task_description_entry.get()
            priority = selected_priority.get()
            value = selected_value.get()
            cost = selected_cost.get()

            if new_task_name and priority and value and cost:
                # Mettre à jour la tâche dans la base de données
                self.board.update_tache(
                    old_title=tache[0],
                    titre=new_task_name, 
                    description=new_task_description, 
                    priorite=priority, 
                    valeur=value, 
                    cout=cost
                )

                messagebox.showinfo("Succès", f"Tâche '{new_task_name}' modifiée avec succès.")
                modify_window.destroy()

                # Recharger les tâches après modification
                self.load_taches()
            else:
                messagebox.showwarning("Erreur", "(*) Valeurs obligatoires manquantes.")

        # Bouton de validation
        submit_button = ctk.CTkButton(modify_window, text="Valider", command=submit_modification)
        submit_button.pack(pady=10)

    def supprimer_tache(self, task_title):
        # Confirmer la suppression
        confirm = messagebox.askyesno("Confirmer la suppression", f"Voulez-vous vraiment supprimer la tâche '{task_title}' ?")
        if confirm:
            # Suppression de la tâche dans la base de données
            self.board.remove_tache(task_title)
            messagebox.showinfo("Succès", f"Tâche '{task_title}' supprimée avec succès.")
            self.load_taches()  # Recharge les tâches après suppression

    def open_task_window(self):
        # Fenêtre pour ajouter une nouvelle tâche
        task_window = ctk.CTkToplevel(self)
        task_window.title("Ajouter une tâche")
        task_window.attributes("-topmost", True)
        task_window.focus_force()

        # Champ pour le nom de la tâche
        ctk.CTkLabel(task_window, text="(*) Nom de la tâche:").pack(pady=5)
        task_name_entry = ctk.CTkEntry(task_window)
        task_name_entry.pack(pady=5)

        # Champ pour la description de la tâche
        ctk.CTkLabel(task_window, text="Description:").pack(pady=5)
        task_description_entry = ctk.CTkEntry(task_window)
        task_description_entry.pack(pady=5)

        # Créer les variables pour les listes déroulantes
        selected_value = ctk.StringVar(value="1")
        selected_cost = ctk.StringVar(value="1")
        selected_priority = ctk.StringVar(value="P1")

        VALUE_OPTIONS = ["1", "2", "3", "4", "5"]
        ctk.CTkLabel(task_window, text="Valeur:").pack(pady=5)
        value_menu = ctk.CTkOptionMenu(task_window, variable=selected_value, values=VALUE_OPTIONS, width=100)
        value_menu.pack(pady=5)

        COST_OPTIONS = ["1", "2", "3", "4", "5"]
        ctk.CTkLabel(task_window, text="Coût:").pack(pady=5)
        cost_menu = ctk.CTkOptionMenu(task_window, variable=selected_cost, values=COST_OPTIONS, width=100)
        cost_menu.pack(pady=5)

        PRIORITY_OPTIONS = ["P1", "P2", "P3"]
        ctk.CTkLabel(task_window, text="Priorité:").pack(pady=5)
        priority_menu = ctk.CTkOptionMenu(task_window, variable=selected_priority, values=PRIORITY_OPTIONS, width=100)
        priority_menu.pack(pady=5)

        # Fonction de soumission
        def submit_task():
            task_name = task_name_entry.get()
            task_description = task_description_entry.get()
            priority = selected_priority.get()
            value = selected_value.get()
            cost = selected_cost.get()

            if task_name and priority and value and cost:
                # Ajouter la tâche à la base de données
                self.board.add_tache(task_name, task_description, priority, value, cost)
                messagebox.showinfo("Succès", f"Tâche '{task_name}' ajoutée avec succès.")
                task_window.destroy()
                self.load_taches()  # Recharge les tâches après ajout
            else:
                messagebox.showwarning("Erreur", "(*) Valeurs obligatoires manquantes.")

        # Bouton de soumission
        submit_button = ctk.CTkButton(task_window, text="Ajouter", command=submit_task)
        submit_button.pack(pady=10)

    def create_todo_board(self):
        todo_frame = ctk.CTkFrame(self.todo_frame)
        todo_frame.pack(expand=True, fill=ctk.BOTH, padx=10, pady=10)

        self.todo_label = ctk.CTkLabel(todo_frame, text="To Do")
        self.todo_label.grid(row=0, column=0, padx=10, pady=5)

        self.doing_label = ctk.CTkLabel(todo_frame, text="Doing")
        self.doing_label.grid(row=0, column=1, padx=10, pady=5)

        self.done_label = ctk.CTkLabel(todo_frame, text="Done")
        self.done_label.grid(row=0, column=2, padx=10, pady=5)

        self.todo_column = ctk.CTkFrame(todo_frame)
        self.todo_column.grid(row=1, column=0, padx=10, pady=5, sticky="nsew")

        self.doing_column = ctk.CTkFrame(todo_frame)
        self.doing_column.grid(row=1, column=1, padx=10, pady=5, sticky="nsew")

        self.done_column = ctk.CTkFrame(todo_frame)
        self.done_column.grid(row=1, column=2, padx=10, pady=5, sticky="nsew")

        # Configurer les colonnes pour qu'elles s'étendent
        todo_frame.columnconfigure(0, weight=1)
        todo_frame.columnconfigure(1, weight=1)
        todo_frame.columnconfigure(2, weight=1)

    def open_task_window(self):
        # Fenêtre affichée pour entrer les détails de la tâche
        task_window = ctk.CTkToplevel(self)
        task_window.title("Nouvelle tâche")
        task_window.attributes("-topmost", True)
        task_window.focus_force()

        # Champ pour le nom de la tâche
        ctk.CTkLabel(task_window, text="(*) Nom de la tâche:").pack(pady=5)
        task_name_entry = ctk.CTkEntry(task_window)
        task_name_entry.pack(pady=5)

        # Champ pour la description de la tâche
        ctk.CTkLabel(task_window, text="Description:").pack(pady=5)
        task_description_entry = ctk.CTkEntry(task_window)
        task_description_entry.pack(pady=5)

        # Créer les variables pour les listes déroulantes
        self.SELECTED_VALUE = ctk.StringVar(value="1")
        self.SELECTED_COST = ctk.StringVar(value="1")
        self.SELECTED_PRIORITY = ctk.StringVar(value="P1")

        self.VALUE_OPTIONS = ["1", "2", "3", "4", "5"]
        ctk.CTkLabel(task_window, text="(*) Valeur:").pack(pady=5)
        value_menu = ctk.CTkOptionMenu(task_window, variable=self.SELECTED_VALUE, values=self.VALUE_OPTIONS, width=100)
        value_menu.pack(pady=5)

        self.COST_OPTIONS = ["1", "2", "3", "4", "5"]
        ctk.CTkLabel(task_window, text="(*) Coût:").pack(pady=5)
        cost_menu = ctk.CTkOptionMenu(task_window, variable=self.SELECTED_COST, values=self.COST_OPTIONS, width=100)
        cost_menu.pack(pady=5)

        self.PRIORITY_OPTIONS = ["P1", "P2", "P3"]
        ctk.CTkLabel(task_window, text="(*) Priorité:").pack(pady=5)
        priority_menu = ctk.CTkOptionMenu(task_window, variable=self.SELECTED_PRIORITY, values=self.PRIORITY_OPTIONS, width=100)
        priority_menu.pack(pady=5)

        # Fonction de soumission de la tâche
        def submit_task():
            task_name = task_name_entry.get()
            task_description = task_description_entry.get()
            priority = self.SELECTED_PRIORITY.get()
            value = self.SELECTED_VALUE.get()
            cost = self.SELECTED_COST.get()

            if task_name and priority and value and cost:
                # Ajouter la tâche dans la base de données
                self.board.add_tache(
                    titre=task_name, 
                    description=task_description, 
                    priorite=priority, 
                    valeur=value, 
                    cout=cost
                )

                task_info = f"{task_name} (Priorité: {priority}, Valeur: {value}, Coût: {cost})"
                if task_description:
                    task_info += f"\nDescription: {task_description}"

                # Insérer la tâche dans la TextBox
                self.task_listbox.insert("end", task_info)
                task_window.destroy()
            else:
                messagebox.showwarning("Erreur", "(*) Valeurs obligatoires manquantes.")

        # Bouton de soumission
        submit_button = ctk.CTkButton(task_window, text="Ajouter", command=submit_task)
        submit_button.pack(pady=10)

    def generer_sprints(self):
        try:
            # Récupérer le nombre de sprints entré par l'utilisateur
            nb_sprints = int(self.nb_sprints.get())
            if nb_sprints <= 0:
                messagebox.showwarning("Erreur", "Le nombre de sprints doit être supérieur à zéro.")
                return
        except ValueError:
            messagebox.showwarning("Erreur", "Veuillez entrer un nombre valide pour les sprints.")
            return

        # Vider la frame de sprints actuelle avant de générer de nouveaux sprints
        for widget in self.sprint_inner_frame.winfo_children():
            widget.destroy()

        # Récupérer toutes les tâches de la base de données
        taches = self.board.get_all_taches()

        if not taches:
            messagebox.showinfo("Info", "Il n'y a pas de tâches à répartir.")
            return

        # Diviser les tâches également entre les sprints
        sprints = [[] for _ in range(nb_sprints)]
        for index, tache in enumerate(taches):
            sprints[index % nb_sprints].append(tache)

        # Créer les colonnes pour chaque sprint et y insérer les tâches
        for i in range(nb_sprints):
            sprint_frame = ctk.CTkFrame(self.sprint_inner_frame, corner_radius=10, border_color="black", border_width=2)
            sprint_frame.grid(row=0, column=i, padx=10, pady=10)

            sprint_label = ctk.CTkLabel(sprint_frame, text=f"Sprint {i+1}", font=('Arial', 14, 'bold'))
            sprint_label.pack(pady=5)

            for tache in sprints[i]:
                task_frame = ctk.CTkFrame(sprint_frame, corner_radius=10, border_color="black", border_width=1)
                task_frame.pack(fill="x", padx=5, pady=5)

                # Titre de la tâche
                task_title = ctk.CTkLabel(task_frame, text=f"Titre: {tache[0]}", font=('Arial', 12, 'bold'))
                task_title.pack(anchor='w', padx=10, pady=2)

                # Description de la tâche
                task_description = ctk.CTkLabel(task_frame, text=f"Description: {tache[1]}")
                task_description.pack(anchor='w', padx=10, pady=2)

                # Informations supplémentaires
                task_info = ctk.CTkLabel(task_frame, text=f"Priorité: {tache[2]}, Valeur: {tache[3]}, Coût: {tache[4]}")
                task_info.pack(anchor='w', padx=10, pady=2)

        # Mettre à jour la taille du canvas pour inclure tous les sprints
        self.sprint_inner_frame.update_idletasks()
        self.canvas.config(scrollregion=self.canvas.bbox("all"))
        

if __name__ == "__main__":
    app = SprintApp()
    app.mainloop()