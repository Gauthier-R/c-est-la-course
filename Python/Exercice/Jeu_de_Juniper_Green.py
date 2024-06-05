from random import random
from math import sqrt

#Exercice 5.1
'''ma_liste = []
for nombre in range(15):
    ma_liste.append(round(random()*100,0))
print(ma_liste)'''


#Exercice 5.2
'''liste1 = [31,28,31,30,31,30,31,31,30,31,30,31]
liste2 = ['Janvier','Février','Mars','Avril','Mai','Juin','Juillet','Août','Septembre','Octobre','Novembre','Décembre']
liste3 = []

for valeur in range(12):
    liste3.append(liste2[valeur])
    liste3.append(liste1[valeur])
    
liste3[4:4]=[29]

print(liste3)'''


#Exercice 5.3

def eratosthene(n):
    liste_nombre = list(range(2, n+1))
    liste_valide = [True] * len(liste_nombre)
    print(len(liste_valide))
        
    for i in range(2, int(sqrt(n))+1):
        
        if liste_valide[i] == True:
            for j in range(i*2,n+1,i):
                liste_valide[j-2] = False
        
    for indice, valide in enumerate(liste_valide):
        if valide:
            print(liste_nombre[indice], end=', ')             