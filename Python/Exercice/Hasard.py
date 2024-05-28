from random import randint, choice, shuffle, sample, random

#Exercice 1.1 :

#1
def un_jet():
    résultat = 0
    for lancer in range(1,4):
        valeur = randint(1,6)
        résultat += valeur
        print(f'Le lancer {lancer} a obtenu {valeur}')
    print(f'La somme des lancers est {résultat}.')


#2
def cinquante_jets():
    for jets in range(50):
        résultat = 0
        for lancer in range(1,4):
            valeur = randint(1,6)
            résultat += valeur
            print(f'Le lancer {lancer} a obtenu {valeur}')
        print(f'La somme des lancers est {résultat}.')



#3

def deux_cents_jets():
    for jets in range(200):
        résultat = 0
        for lancer in range(1,4):
            valeur = randint(1,6)
            résultat += valeur
            print(f'Le lancer {lancer} a obtenu {valeur}')
        print(f'La somme des lancers est {résultat}.')




#Exercice 1.2


liste = [1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,6,6,6]


for jet in range(1,101):
    alea = choice(liste)
    print(f'Le tirage {jet} vaut {alea}')

#Exercice 1.3

liste = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9']
mdp = ''
for caractere in range(8):
    mdp += choice(liste)
print(mdp) 

#Exercice 1.4

liste = ["Wade Barrett", "Daniel Bryan", "Sin Cara", "John Cena", "Antonio Cesaro", "Brodus Clay", "Bo Dallas", "TheGodfather", "Goldust", "Kane", "The Great Khali", "Chris Jericho", "Kofi Kingston", "Jinder Mahal", "SantinoMarella", "Drew McIntyre", "The Miz", "Rey Mysterio", "Titus O'Neil", "Randy Orton", "David Otunga", "CodyRhodes", "Ryback", "Zack Ryder", "Damien Sandow", "Heath Slater", "Sheamus", "Tensai", "Darren Young", "DolphZiggler"]
shuffle(liste)
print(liste)

#Exercice 1.5

euro_million = list(range(1,51))
euro_million_etoile = list(range(1,13))
    
print(sample(euro_million,5))
print(sample(euro_million_etoile,2))
    
#Exercice 1.6

bingo = list(range(1,91))
shuffle(bingo)
print(bingo)


#Exercice 1.7

for i in range(100):
    jet = random()*100
    if jet <= 57.83:
        print('Face')
    else:
        print('Pile')
        
#Exercice 1.8

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
        
print(paquet)
if 'L' not in paquet and 'E' not in paquet and 'R' not in paquet:
    print("Ce paquet n'est pas valide")
    
#Exercice 1.9

tetraede = randint(1,4)
if tetraede == 1:
    resultat = randint(1,6)
elif tetraede == 2:
    resultat = randint(1,8)
elif tetraede == 3:
    resultat = randint(1,10)
elif tetraede == 4:
    resultat = randint(1,16)
    
print(resultat)