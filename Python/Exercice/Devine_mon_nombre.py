from random import randint, choice, random
import time

#Exercice 2.1

'''
rang = 1
mot = input('Ecrivez un mot : ')
while mot != '':    
    print(f'{rang} {mot}')
    rang += 1
    mot = input('Ecrivez un mot : ')
print('Au revoir')
'''

#Exercice 2.2

'''
h=0
while h<24:
    m=0
    while m<60:
        s=0
        while s<60:
            print(f'{h} heure(s) {m} minute(s) {s} seconde(s)')
            s+=1
        m+=1
    h+=1
'''
    
#Exercice 2.3

#Partie 1
'''
multiplicateur = 1

while multiplicateur <= 20:
    print(multiplicateur,' x 53 = {:4d}'.format(multiplicateur*53))
    multiplicateur += 1'''

#Partie 2
'''
table = 1
while table <= 12:
    multiplicateur = 1
    while multiplicateur <= 12:
        print('{:4d}'.format(multiplicateur),' x ', '{:4d}'.format(table),' = {:4d}'.format(multiplicateur*table))
        multiplicateur += 1
    print()
    table += 1
    '''
    
#Exercice 2.4

'''Nmax = int(input('nombre maximum ? '))

for reponse_juste in range(10):
    a =  randint(2, Nmax)
    b = randint(2, Nmax)
    calcule = a*b
    reponse = int(input(f'{a} x {b} = '))
    while calcule != reponse :
       print('Faux ! Réessayez !') 
       reponse = int(input(f'{a} x {b} = '))
       '''
       
#Exercice 2.5
'''
Nmax = int(input('nombre maximum ? '))
erreur = 0
debut = time.time()
for reponse_juste in range(10):
    a =  randint(2, Nmax)
    b = randint(2, Nmax)
    calcule = a*b
    reponse = int(input(f'{a} x {b} = '))
    while calcule != reponse :
       print('Faux ! Réessayez !')
       erreur += 1
       reponse = int(input(f'{a} x {b} = '))
       
fin = time.time()

if erreur == 0:
    print("Bravo ! Vous n'avez pas fait d'erreur")
elif erreur == 1:
    print("Vous avez fait 1 erreur")
else :
    print(f"Vous avez fait {erreur} erreurs")
print(round(fin-debut,1),' secondes')'''


#Exercice 2.6


'''Nmax = int(input('nombre maximum ? '))
erreur = 0
debut = time.time()
for reponse_juste in range(10):
    a =  randint(2, Nmax)
    b = randint(2, Nmax)
    operateur = choice(['+','-','x','/'])
    
    if operateur == '+':
        calcule = a+b
        question = f'{a} + {b} = '
    elif operateur == '-':
        calcule = a-b
        question = f'{a} - {b} = '
    elif operateur == 'x':
        calcule = a*b
        question = f'{a} x {b} = '
    elif operateur == '/':
        calcule = a/b
        question = f'{a} / {b} = '
    
    reponse = int(input(question))
  
    while calcule != reponse :
       print('Faux ! Réessayez !')
       erreur += 1
       reponse = int(input(question))
       
fin = time.time()

if erreur == 0:
    print("Bravo ! Vous n'avez pas fait d'erreur")
elif erreur == 1:
    print("Vous avez fait 1 erreur")
else :
    print(f"Vous avez fait {erreur} erreurs")
print(round(fin-debut,1),' secondes')
'''

#Exercice 2.7

#Boucle FOR
'''Pile = Face = 0
for lancer in range(1000):
    if random() < 0.5:
        Pile +=1
    else:
        Face +=1
print(f'Pile : {Pile}')
print(f'Face : {Face}')'''

#Boucle WHILE
'''Pile = Face = 0
nb = 0
while nb!=1000:
    nb+=1
    if random() < 0.5:
        Pile +=1
    else:
        Face +=1
print(f'Pile : {Pile}')
print(f'Face : {Face}')'''


#Exercice 2.8

'''nb_paquet = 1000
liste_carte = []

for paquet in range(nb_paquet):
    
    paquet = []
    while 'L' not in paquet and 'E' not in paquet and 'R' not in paquet:
        paquet = []
        for carte in range(5):
            rarete_carte = random()*100
            if rarete_carte <= 1:
                paquet.append('L')
            elif rarete_carte <= 5:
                paquet.append('E')
            elif rarete_carte <= 28:
                paquet.append('R')
            else:
                paquet.append('C')
        
        if 'L' not in paquet and 'E' not in paquet and 'R' not in paquet:
            print(paquet)
            print("Ce paquet n'est pas valide")
        else:
            liste_carte.append(paquet)
            if 'L' in paquet:
                paquet.append('!')
            print(paquet)
        
        
légendaire = épique = rare = commune = 0
        
for paquet in liste_carte:
    for carte in paquet:
        if carte == 'L':
            légendaire += 1
        elif carte == 'E':
            épique += 1
        elif carte == 'R':
            rare += 1
        elif carte == 'C':
            commune += 1

total_carte = légendaire + épique + rare + commune

print(f'{légendaire} légendaire(s) : {légendaire/total_carte*100}%')
print(f'{épique} épique(s) : {épique/total_carte*100}%')
print(f'{rare} rare(s) : {rare/total_carte*100}%')
print(f'{commune} communes : {commune/total_carte*100}%')'''


#Exercice 2.9

# Devine mon nombre
'''rejouer = 'oui'
nom_joueur = input('Quel est ton nom ?')
nb_de_partie = 0
nb_de_victoire = 0
nb_de_tentative = []

while rejouer == 'oui':
    nbr_essais_max = 5
    nbr_essais = 1
    borne_sup = 30
    mon_nombre = randint(1,borne_sup) # nombre choisi par l'ordinateur
    ton_nombre = 0 # nombre proposé par le joueur
    nb_de_partie += 1
    
    

    print("J'ai choisi un nombre entre 1 et",borne_sup)
    print("A vous de le deviner en",nbr_essais_max,"tentatives au maximum !")

    while ton_nombre != mon_nombre and nbr_essais <= nbr_essais_max:
        print("Essai no ",nbr_essais)
        ton_nombre = int(input("Votre proposition : "))
        if ton_nombre < mon_nombre:
            print("Trop petit")
        elif ton_nombre > mon_nombre:
            print("Trop grand")
        else:
            print("Bravo ",nom_joueur," ! Vous avez trouvé",mon_nombre,"en",nbr_essais,"essai(s)")
            nb_de_victoire += 1
            nb_de_tentative.append(nbr_essais)
            
        nbr_essais += 1
        

    if nbr_essais>nbr_essais_max and ton_nombre != mon_nombre :
        print("Désolé, vous avez utilisé vos",nbr_essais_max,"essais en vain.")
        print("J'avais choisi le nombre",mon_nombre,".")
        
    rejouer = input('Voulez-vous rejouer ? Oui - Non : ').lower()
    
print(f'Pourcentage de réussite : {nb_de_victoire/nb_de_partie*100} %')
print(f'Nombre moyen de tentatives : {sum(nb_de_tentative)/len(nb_de_tentative)}')

'''
#Exercice 2.10

'''reponse = 3
Nmin = 1
Nmax = 30

while reponse != 0 :
    proposition = randint(Nmin,Nmax)
    print(proposition)
    
    while True:
        try:
            reponse = int(input('0 - 1 - 2 : '))
            break
        except ValueError:
            print('Réponse non valide. Réessayez')
        
        
    if reponse == 0:
        print('Super ! Je suis trop fort')
    elif reponse == 1:
        print('Trop grand')
        Nmax = proposition-1
    elif reponse == 2:
        print('Trop petit')
        Nmin = proposition+1
    else :
        print('Réponse non valide. Réessayez')
        '''
        
#Exercice 2.11

while True:
    try:
        nb_attaquant = int(input("Entrez le nombre d'attaquant : "))
        nb_défenceur = int(input("Entrez le nombre de défenceur : "))
    except ValueError:
        print("Erreur. Veuillez réessayer.")

    for attaquant in range(nb_attaquant):
        dé_attaquant.append([1,2,3,4,5,6])
    dé_attaquant = dé_défenceur = [1,2,3,4,5,6]
    victoire_attaquant = victoire_défenceur = 0

    for valeur_attaque in dé_attaquant:
        for valeur_défence in dé_défenceur:
            if valeur_défence >= valeur_attaque:
                victoire_défenceur += 1
            else:
                victoire_attaquant += 1

    print("Attaquant : ",victoire_attaquant)
    print("Défenceur : ",victoire_défenceur)
            


    
    
        

    




        
        
    