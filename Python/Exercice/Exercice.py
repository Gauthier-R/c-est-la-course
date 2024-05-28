#EXERCICE 1

#Fonction qui calcule la somme des nombres pairs de 0 au nombre n renseigné.
def calculer_somme_nb_pair(n):
    resultat = 0 #Valeur résultat de la somme.
    for nombre in range(n+1): #Boucle permettant de parcourir chaque valeur de 0 à n.
        if nombre % 2 == 0: #Si le nombre est paire, on l'ajoute au résultat.
            resultat += nombre
    return resultat


print(calculer_somme_nb_pair(10))

#EXERCICE 2

#Fonction pour vérifier si un mot est un palyndrome
def verifier_si_palyndrome(mot):
    mot_inverse = '' #Variable pour stocker le mot inversé
    for lettre in mot[::-1]: #Créer le mot inversé
        mot_inverse += lettre
    if mot != mot_inverse: #Vérifier si le mot inversé est égale au mot initiale
            return f"Le mot {mot} n'est pas un palyndrome"
    return f'Le mot {mot} est un palyndrome'


print(verifier_si_palyndrome('radar'))
print(verifier_si_palyndrome('hello'))

#EXERCICE 3
#Fahrenheit = (Celsius * 1.8) + 32
#Fonction pour convertir des Celsius en Fahrenheit
def Celsius_to_Fahrenheit(celsius) : 
    fahrenheit = celsius*1.8 + 32
    return fahrenheit

#Fonction pour convertir des Fahrenheit en Celsius
def Fahrenheit_to_Celsius(fahrenheit):
    celsius = (fahrenheit-32)/1.8
    return celsius

print(Celsius_to_Fahrenheit(20))
print(Fahrenheit_to_Celsius(68))

#Exercice 4 :

#Fonction pour compter le nombre de voyelle dans une chaîne de caractère :
def compter_voyelle(text):
    voyelle = ['a','e','i','o','u']
    compteur = 0
    for lettre in text:
        if lettre in voyelle :
            compteur += 1
    return compteur

print(compter_voyelle("Bonjour je m'appelle Gauthier"))

#EXERCICE 5 :

#Fonction permettant de trier une liste d'entier :
def trier_liste_entier(liste = []):
    liste_trier = []
    while len(liste) > 0:
        compteur = liste[0]
        for nombre in liste:
            if nombre < nombre-1:
                compteur = liste[nombre]
        liste_trier.append(compteur)
        liste.remove(compteur)
    return liste_trier

print(trier_liste_entier([3,5,1]))
                
        
#EXERCICE 6 :

#Fonction qui génère tous les nombres premiers inférieur à un nombre donné :
def generer_nb_premiers(n):
    liste_nb_premier = []
    for nombre in range(n):
        condition = True
        for diviseur in range(1,nombre+1):
            if nombre % diviseur != 0 or nombre != diviseur or diviseur != 1:
                condition = False
        if condition == True:
            liste_nb_premier.append(nombre)
        
        
    return liste_nb_premier

print(generer_nb_premiers(10))


#EXERCICE 7 :
def calcul_factoriel(n):
    factoriel = 1
    for nombre in range(1,n+1):
        factoriel *= nombre
    return factoriel

print(calcul_factoriel(3))


#EXERCICE 8 :
def recherche_binaire(liste, recherche):
    for indice in liste:
        if recherche == indice:
            return indice
        
    return -1

print(recherche_binaire([2,3,5,6],6))
print(recherche_binaire([2,3,5,6],4))


#EXERCICE 9 :
def estimation_mdp(mdp):
    longueur = False
    majuscule = False
    minuscule = False
    chiffre = False
    for caractere in mdp:
        if caractere == mdp[8]:
            longueur = True
        if caractere == caractere.upper():
            majuscule = True
        if caractere == caractere.lower() and not ('0','1','2','3','4','5','6','7','8','9'):
            minuscule = True
        if caractere in ('0','1','2','3','4','5','6','7','8','9'):
            chiffre = True
    if longueur and majuscule and minuscule and chiffre:
        return 'MDP FORT'
    return 'MDP FAIBLE'

print(estimation_mdp('AAAA1212AO?D'))
            
        
#EXERCICE 10 :
def nb_mots(phrase):
    mots = 1
    if len(phrase) == 0:
        return 0
        
    for mot in range(1, len(phrase)):
        if isinstance(phrase[mot], str) and phrase[mot-1] == ' ' and isinstance(phrase[mot-2], str):
            mots+=1
            
    return mots

print(nb_mots(' a h ia a a es'))
        

        