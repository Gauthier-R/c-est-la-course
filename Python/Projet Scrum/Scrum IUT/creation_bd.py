#Connexion à la base de données
import sqlite3

# Création d'une connexion à la base de données (ou création si elle n'existe pas)
conn = sqlite3.connect('scrum.db')

# Création d'un curseur pour interagir avec la base de données
c = conn.cursor()

# Création de la table tâches
c.execute('''CREATE TABLE taches
             (id INTEGER PRIMARY KEY AUTOINCREMENT, 
             titre TEXT, 
             description TEXT,
             temps FLOAT,
             priorite TEXT,
             numero_sprint INTEGER,
             etat TEXT,
             valeur INTEGER,
             cout INTEGER,
             date_heure_doing DATETIME
             )''')

