import pprint

#Découverte des dictionnaire

def revision_dico():
    #Créer un dictionnaire vide
    dico = {}

    #Ajouter des clef et valeurs dans mon dictionnaire
    dico['red'] = 'rouge'
    dico['blue'] = 'bleu'
    dico['green'] = 'vert'
    dico['yellow'] = 'jaune'

    #Afficher la valeur d'une clef
    print(dico['red'])

    #Afficher les clefs d'un dico
    print(dico.keys())

    #Afficher les valeurs d'un dico
    print(dico.values())

    #Afficher mon dictionnaire
    print(dico)

    #Vérifier si les clefs sont présentent 
    print(dico.get('red', 'inconnu'))
    print(dico.get('grey', 'inconnu'))
    #ou
    print('red' in dico)
    print('grey' in dico)

    #Changer la valeur d'une clef
    dico['blue'] = 'bleu claire'
    print(dico)

    #Supprimer la clef et valeur du dico
    del(dico['blue'])
    print(dico)
    
    #Parcourir chacune des valeurs du dico
    for i in dico:
        print(i, dico[i])
    #ou
    for cle, valeur in dico.items(): #.items ressort les clefs et valeurs sous la forme de tuples
        print(cle, valeur)
        
    #Trier un dictionnaire selon les clefs
    print(sorted(dico.items(), key=lambda x : x[0]))
    
    #Trier un dictionnaire selon les valeurs
    print(sorted(dico.items(), key=lambda x : x[1]))
    
    #Créer une copie du dictionnaire
    dico_copy = dico.copy()
    print(dico_copy)    

def exercice_1():
    calendrier = {"janvier" : 31, 
                  "février": 29, 
                  "mars" : 31, 
                  "avril" : 30,
                  "mai" : 31,
                  "juin" : 30,
                  "juillet" : 31,
                  "août" : 31,
                  "septembre" : 30,
                  "octobre" : 31,
                  "novembre" : 30,
                  "décembre" : 31}
    
    pprint.pprint(calendrier)
    
def exercice_2() :
    dico_en_fr = {
        "hello" : "salut",
        "apple" : "pomme",
        "bottle" : "bouteille"
        
    }
    dico_fr_en = {}
    
    for clef, valeur in dico_en_fr.items():
        dico_fr_en[valeur] = clef
        
    print(dico_fr_en)

def exercice_3(mot : str):
    dico = {
        "A" : "W",
        "B" : "B",
        "C" : "H",
        "D" : "A",
        "E" : "Y",
        "F" : "P",
        "G" : "O",
        "H" : "D",
        "I" : "Q",
        "J" : "Z",
        "K" : "X",
        "L" : "N",
        "M" : "T",
        "N" : "S",
        "O" : "F",
        "P" : "L",
        "Q" : "R",
        "R" : "U",
        "S" : "V",
        "T" : "M",
        "U" : "C",
        "V" : "E",
        "W" : "K",
        "X" : "J",
        "Y" : "G",
        "Z" : "I"
    }
    
    resultat = ""
    
    for lettre in mot :
        for key, value in dico.items() : 
            if lettre == value:
                resultat += key
        if lettre == " " :
            resultat += " "
    print(resultat)
    
def exercice_4():
    
    texte = "ceci est un texte sans aucun accent ni apostrophe pour pratiquer la vitesse de frappe des personnes avec des claviers anglais ou sans accent ou simplement pour ceux qui sont trop paresseux pour utiliser la ponctuation. il est toutefois mieux de ne pas prendre le chemin facile pour les textes officiels. pour la suite je vais utiliser certains mots qui utilisent normalement des accents sans les mettre pour me faciliter la chose dans la recherche de mots et de tournure des phrases. voici quelques phrases qui nont pas de liens entres elles simplement pour augmenter le nombre de mot du texte et avoir une meilleur idee du nombre de mot par minute. cette phrase parle des licornes car"
    histo = {}
    
    for lettre in texte :
        histo[lettre] = histo.get(lettre, 0) + 1
        
    liste = list(histo.items())
    liste.sort()
    
    for keys, value in liste :
        print(keys, ':', end= " ")
        for i in range(value):
            print("|", end="")
        print(end="\n")
    
def exercice_5(value : int):
    dico = {
        0 : "GA",
        1 : "BU",
        2 : "ZO",
        3 : "MEU"
    }
    
    n = 0
    div = 0
    while div <= value :
        n+=1
        div = 4**n
    
    result = []
    
    for i in range(n-1):
        n -= 1
        div = 4**(n)
        quotient = value // div
        value = value % div
        result.append(quotient)
    
    result.append(value)
    
    for results in result :
        for keys, values in dico.items() :
            if results == keys :
                print(values, end=" ")
    
    print(result)
        
        
        
        
        

#Appelle de fonction
#revision_dico()
#exercice_1()
#exercice_2()
#exercice_3("WUJ MWULYQW HWLQMFNQ LUFJQTW")
#exercice_4()
#exercice_5(4)