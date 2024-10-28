import sqlite3
from datetime import datetime

class Tache:
    def __init__(self, id="NULL", titre="NULL", description="NULL", temps=-1, priorite="NULL", sprint=-1, etat="NULL", valeur=-1, cout=-1):
        self.id = id
        self.titre = titre
        self.description = description
        self.temps = temps
        self.priorite = priorite
        self.sprint = sprint
        self.etat = etat
        self.valeur = valeur
        self.cout = cout

class ScrumBoard:
    def __init__(self, db_path):
        self.db_path = db_path
        self.conn = sqlite3.connect(self.db_path)
        self.cursor = self.conn.cursor()
        
    def add_tache(self, titre="NULL", description="NULL", temps=datetime.now().strftime("%d-%m-%Y %H:%M:%S"), priorite="NULL", sprint=-1, etat="NULL", valeur=-1, cout=-1):
        query = "INSERT INTO taches (titre, description, temps, priorite, sprint, etat, valeur, cout) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
        values = (titre, description, temps, priorite, sprint, etat, valeur, cout)
        self.cursor.execute(query, values)
        self.conn.commit()
        print(f"Tâche '{titre}' ajoutée avec succès dans la base de données.")
        
    def remove_tache(self, titre):
        query_del = "DELETE FROM taches WHERE titre = ?"
        self.cursor.execute(query_del, (titre,))
        self.conn.commit()
        print(f"Tâche '{titre}' supprimée de la base de données.")

    def show_tache(self):
        self.cursor.execute("SELECT id, titre, description, temps, priorite, sprint, etat, valeur, cout FROM taches")
        taches = self.cursor.fetchall()
        if not taches:
            print("Aucune tâche disponible.")
        else:
            for tache in taches:
                print(f"ID: {tache[0]}, Titre: {tache[1]}, Description: {tache[2]}, Temps: {tache[3]}, Priorité: {tache[4]}, Sprint: {tache[5]}, État: {tache[6]}, Valeur: {tache[7]}, Coût: {tache[8]}")
                
    def update_tache(self, id, titre=None, description=None, priorite=None, sprint=None, etat=None, valeur=None, cout=None):
        query = "UPDATE taches SET"
        values = []
        updates = []

        if titre:
            updates.append(" titre = ?")
            values.append(titre)
        if description:
            updates.append(" description = ?")
            values.append(description)
        if priorite:
            updates.append(" priorite = ?")
            values.append(priorite)
        if sprint is not None:
            updates.append(" sprint = ?")
            values.append(sprint)
        if etat:
            updates.append(" etat = ?")
            values.append(etat)
        if valeur is not None:
            updates.append(" valeur = ?")
            values.append(valeur)
        if cout is not None:
            updates.append(" cout = ?")
            values.append(cout)

        if updates:
            query += ",".join(updates) + " WHERE id = ?"
            values.append(id)

            self.cursor.execute(query, values)
            self.conn.commit()
            print(f"Tâche avec l'ID '{id}' mise à jour avec succès.")
        else:
            print("Aucune modification fournie.")
            
    def get_all_taches(self):
        self.cursor.execute("SELECT titre, description, priorite, valeur, cout FROM taches")
        return self.cursor.fetchall()


    def close(self):
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
        print('Fermeture du SCRUM_BOARD')

# Connexion à SQLite (chemin du fichier 'scrum.db')
db_path = 'scrum.db'

# Exemple d'utilisation
board = ScrumBoard(db_path)

# Fermeture propre des ressources
#board.close()