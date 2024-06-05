from random import randint

while True : #Boucle tant que le bouton de l'étape suivante n'est pas trouvé
    
    value = randint(0,1) #Remplacer ça par un scroll de x pixels 
    print(value)
    if value == 1 : #Conditionner sur si le bouton à cliquer de l'étape suivante est visible
        break
        
print("Bouton trouvé. On continue le programme") #Ici c'est la suite du programme 