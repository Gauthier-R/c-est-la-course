# pip install mysql-connector-python
import mysql.connector

class Tache :
    
    def __init__(self, id = "NULL", titre = None, description = None, auteur = None) :
        self.id = id
        self.titre = titre
        self.description = description
        
    

class ScrumBoard :
    
    def __init__(self, db_config) :
        self.db_config = db_config
        self.conn = mysql.connector.connect(**self.db_config)
        self.cursor = self.conn.cursor()
        
        
    def add_tache(self, titre, description, auteur) :
        query = "INSERT INTO tache (titre, description, auteur) VALUES (%s, %s, %s)"
        values = (titre, description, auteur)
        self.cursor.execute(query, values)
        self.conn.commit()
        print(f"Tâche '{titre}' ajoutée avec succès dans la base de données.")
        
        
    def remove_tache(self, titre):
        query = "DELETE FROM tache WHERE titre = %s"
        self.cursor.execute(query, (titre,))
        self.conn.commit()
        print(f"Tâche '{titre}' supprimée de la base de données.")


    def show_tache(self):
        self.cursor.execute("SELECT id, titre, description, auteur FROM tache")
        taches = self.cursor.fetchall()
        if not taches:
            print("Aucune tâche disponible.")
        else:
            for tache in taches:
                print(f"ID: {tache[0]}, Titre: {tache[1]}, Description: {tache[2]}, Auteur : {tache[3]}")

    
    def close(self):
        """Fermer proprement le curseur et la connexion."""
        if self.cursor:
            self.cursor.close()
        if self.conn:
            self.conn.close()
        print('Fermeture du SCRUM_BOARD')
            
        
# Configuration de connexion à MySQL
db_config = {
    'user': 'root',       # Remplace par ton utilisateur MySQL
    'password': '',  # Ton mot de passe MySQL
    'host': 'localhost',
    'database': 'scrum_project',
    'port': 3306 
}


# Exemple d'utilisation
board = ScrumBoard(db_config)
board.add_tache("Configurer l'environnement", "Installer Python et les dépendances", "Gauthier")
board.add_tache("Développer l'interface", "Créer l'interface utilisateur de base", "Sarah")
board.show_tache()

board.remove_tache("Configurer l'environnement")
board.show_tache()

# Fermeture propre des ressources
board.close()