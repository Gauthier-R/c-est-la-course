#Exercice 3.2

'''def table(n):
    table = 1
    while table <= n:
        multiplicateur = 1
        while multiplicateur <= 10:
            print('{:4d}'.format(multiplicateur),' x ', '{:4d}'.format(table),' = {:4d}'.format(multiplicateur*table))
            multiplicateur += 1
        print()
        table += 1
        
table(3)
'''

#Exercice 3.3
'''
def maximum(a,b,c):
    return max(a,b,c)

print(maximum(5,2,3))
'''
#Exercice 3.4
'''
def fahrenheit(celsius):
    return 9/5*celsius+32

def celsius(fahrenheit):
    return 5/9*(fahrenheit-32)

print(fahrenheit(20))
print(celsius(68))
'''

#Exercice 3.5

'''# jeu pierre, papier, ciseaux
# l'ordinateur joue au hasard contre un humain
# moi = ordinateur; toi = humain
from random import randint, random
def ecrire(nombre):
    if nombre == 1:
        print("pierre",end=" ")
    elif nombre == 2:
        print("papier",end=" ")
    else:
        print("ciseaux",end=" ")

def augmenter_scores(mon_coup,ton_coup):
    global mon_score, ton_score
    if mon_coup == 1 and ton_coup == 2:
        ton_score += 1
    elif mon_coup == 2 and ton_coup == 1:
        mon_score += 1
    elif mon_coup == 1 and ton_coup == 3:
        mon_score += 1
    elif mon_coup == 3 and ton_coup == 1:
        ton_score += 1
    elif mon_coup == 3 and ton_coup == 2:
        mon_score += 1
    elif mon_coup == 2 and ton_coup == 3:
        ton_score += 1
        
def coup_ordi():
    coup = random()
    if coup <= 0.29:
        return 1
    elif coup <= 0.7:
        return 2
    else:
        return 3

ton_score, mon_score = 0, 0
fin = 5
print("Pierre-papier-ciseaux. Le premier à",fin,"a gagné !")
while mon_score < fin and ton_score < fin:
    ton_coup = int(input("1 : pierre, 2 : papier, 3 : ciseaux ? "))
    while ton_coup < 1 or ton_coup > 3:
        ton_coup =int(input("1 : pierre, 2 : papier, 3 : ciseaux ? "))
    print("Vous montrez",end=" ")
    ecrire(ton_coup)
    mon_coup = coup_ordi()
    print("- Je montre",end=" ")
    ecrire(mon_coup)
    print() # aller à la ligne
    augmenter_scores(mon_coup,ton_coup)
    print("vous",ton_score," moi",mon_score)
    '''
    
#Exercice 3.6

def fonction(x):
    return 2*x**3-3*x-1
    
def tabuler(f, borneInf, borneSup, pas):
    x = borneInf
    while x <= borneSup :
        print(x, "  ", f(x))
        x+=pas
        
tabuler(fonction, -2, 2, 0.5)