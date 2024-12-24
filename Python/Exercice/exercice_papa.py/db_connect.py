import mysql.connector

#Classe pour se connecter à la base de données
class Database:
    
    def __init__(self, text_entry = None, bouton_radio = None, bouton_segment = None, bouton_option = None, checkbox_droit = None, checkbox_cookie = None):
        self.connection = self.connexion_bdd() #On se connecte à la base de données
        self.id = None
        self.text_entry = text_entry
        self.bouton_radio = bouton_radio
        self.bouton_segment = bouton_segment
        self.bouton_option = bouton_option 
        self.checkbox_droit = checkbox_droit 
        self.checkbox_cookie = checkbox_cookie 
                

    def connexion_bdd(self):
        try: #On essaie de se connecter à la base de données
            connection = mysql.connector.connect(
                host='localhost',
                user='root',
                password='',
                database='exo_papa'
            )
            if connection.is_connected(): #Si la connexion est établie
                print("Connection à la base de données réussie")
                return connection
            
        except mysql.connector.Error as erreur: #Si la connexion échoue
            print(f"Error: {erreur}")
            return None


    def envoyer_info_questionnaire(self):
        cursor = self.connection.cursor() #On crée un curseur pour exécuter des requêtes
        cursor.execute("INSERT INTO info_questionnaire (text_entry, bouton_radio, bouton_segmente, bouton_option, checkbox_droit, checkbox_cookie) VALUES (%s, %s, %s, %s, %s, %s)", (self.text_entry, self.bouton_radio, self.bouton_segment, self.bouton_option, self.checkbox_droit, self.checkbox_cookie))
        self.connection.commit() #On commit pour sauvegarder les modifications
        cursor.close()

        
    def voir_info_questionnaire(self):
        cursor = self.connection.cursor() #On crée un curseur pour exécuter des requêtes
        cursor.execute("SELECT * FROM info_questionnaire")
        result = cursor.fetchall() #On récupère les résultats de la requête
        for row in result:
            print(row)
        cursor.close()
        return result


    def deconnexion_bdd(self):
        self.connection.close() #On ferme la connexion à la base de données
        print("Déconnexion de la base de données réussie")  
