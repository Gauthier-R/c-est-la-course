#Connexion à la base de données
import sqlite3

# Création d'une connexion à la base de données (ou création si elle n'existe pas)
conn = sqlite3.connect('scrum.db')

# Création d'un curseur pour interagir avec la base de données
c = conn.cursor()


# Insertion de données test
c.execute("INSERT INTO taches (titre, description, temps, priorite, numero_sprint, etat, valeur, cout, date_heure_doing) VALUES ('test2', 'TEST 2', 1.5, 'Haute', 2, 'En cours', 5, 100, '2024-10-10 09:00:00')")

# Sauvegarder (commit) les changements
conn.commit()

# Sélection de données test
c.execute("SELECT * FROM taches")

# Affichage des données
print(c.fetchall())

# Fermeture de la connexion
conn.close