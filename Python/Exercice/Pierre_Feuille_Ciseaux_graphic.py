from tkinter import *
from random import randint, choice


#Exercice 4.1

'''valeur_compteur = 0

def incrementer():
    global valeur_compteur
    valeur_compteur+=1
    compteur.config(text=str(valeur_compteur))
    
def reinit():
    global valeur_compteur
    valeur_compteur = 0
    compteur.config(text=str(valeur_compteur))

fenetre = Tk()
fenetre.title("Bouton incrementeur")

compteur = Label(fenetre, text="0", font=('Helvetica', 16))
compteur.grid(row=0, column=1)

bouton1 = Button(fenetre, text='Incrémenter', command=incrementer)
bouton1.grid(row=1,column=0)

bouton2 = Button(fenetre, text='Recommencer', command=reinit)
bouton2.grid(row=1, column=1)

bouton3 = Button(fenetre, text='Quitter', command=fenetre.destroy)
bouton3.grid(row=1, column=2)

fenetre.mainloop()'''


#Exercice 4.2

'''valeur_compteur = 0

def incrementer():
    global valeur_compteur
    valeur_compteur+=1
    compteur.config(text=str(valeur_compteur))
    
def reinit():
    global valeur_compteur
    valeur_compteur = 0
    compteur.config(text=str(valeur_compteur))

fenetre = Tk()
fenetre.title("Bouton incrementeur")

compteur = Label(fenetre, text="0", font=('Helvetica', 32))
compteur.grid(rowspan=3)

bouton1 = Button(fenetre, text='Incrémenter', command=incrementer)
bouton1.grid(row=0,column=1)

bouton2 = Button(fenetre, text='Recommencer', command=reinit)
bouton2.grid(row=1, column=1)

bouton3 = Button(fenetre, text='Quitter', command=fenetre.destroy)
bouton3.grid(row=2, column=1)

fenetre.mainloop()
'''

#Exercice 4.3

'''fenetre = Tk()
fenetre.title('Pierre, papier, ciseaux')

pierre = PhotoImage(file='Python\\Exercice\\image\\pierre-petit.gif')

for colonne in range(10):
    image = Label(fenetre, image=pierre)
    image.grid(row=0,column=colonne)
    
fenetre.mainloop()
'''

#Exercice 4.4

'''def jouer():
    global pierre,papier,ciseaux
    return choice((pierre, papier, ciseaux))

fenetre = Tk()
fenetre.title('Pierre, papier, ciseaux')

pierre = PhotoImage(file='Python\\Exercice\\image\\pierre-petit.gif')
papier = PhotoImage(file='Python\\Exercice\\image\\papier-petit.gif')
ciseaux = PhotoImage(file='Python\\Exercice\\image\\ciseaux-petit.gif')

for colonne in range(10):
    for ligne in range(2):
        image = Label(fenetre, image=jouer())
        image.grid(row=ligne, column=colonne)
        
fenetre.mainloop()'''


#Exercice 4.5

# jeu pierre, papier, ciseaux
# l'ordinateur joue au hasard
from random import randint
from tkinter import *


def init_historique():
    global num_tour
    if num_tour < 9:
        num_tour+=1
    else:
        for colonne in range(10):
            for ligne in range(2):
                historique_image[colonne][ligne].config(image=rien)
        num_tour=0
        

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
    
 
def jouer(ton_coup):
    global mon_score, ton_score, score1, score2
    mon_coup = randint(1,3)
    if mon_coup==1:
        lab3.configure(image=pierre)
        historique_image[num_tour][1].configure(image=pierre)
    elif mon_coup==2:
        lab3.configure(image=papier)
        historique_image[num_tour][1].configure(image=papier)
    else:
        lab3.configure(image=ciseaux)
        historique_image[num_tour][1].configure(image=ciseaux)
    augmenter_scores(mon_coup,ton_coup)
    score1.configure(text=str(ton_score))
    score2.configure(text=str(mon_score))
    
def jouer_pierre():
    global historique_image
    jouer(1)
    lab1.configure(image=pierre)
    historique_image[num_tour][0].configure(image=pierre)
    init_historique()
    
    
def jouer_papier():
    global historique_image
    jouer(2)
    lab1.configure(image=papier)
    historique_image[num_tour][0].configure(image=papier)
    init_historique()
    
    
def jouer_ciseaux():
    global historique_image
    jouer(3)
    lab1.configure(image=ciseaux)
    historique_image[num_tour][0].configure(image=ciseaux)
    init_historique()
    
    
def reinit():
    global mon_score, ton_score, score1, score2, lab1, lab3
    ton_score = 0
    mon_score = 0
    score1.configure(text=str(ton_score))
    score2.configure(text=str(mon_score))
    lab1.configure(image=rien)
    lab3.configure(image=rien)

# variables globales
ton_score = 0
mon_score = 0
historique_image = []
num_tour = 0

# fenetre graphique
fenetre = Tk()
fenetre.title("Pierre, papier, ciseaux")

historique = Toplevel()
historique.title("Historique")

# images
rien = PhotoImage(file ='Python\\Exercice\\image\\rien.gif')
versus = PhotoImage(file ='Python\\Exercice\\image\\versus.gif')
pierre = PhotoImage(file ='Python\\Exercice\\image\\pierre.gif')
papier = PhotoImage(file ='Python\\Exercice\\image\\papier.gif')
ciseaux = PhotoImage(file ='Python\\Exercice\\image\\ciseaux.gif')

# labels
texte1 = Label(fenetre, text="Humain :", font=("Helvetica", 16))
texte1.grid(row=0, column=0)

texte2 = Label(fenetre, text="Machine :", font=("Helvetica", 16))
texte2.grid(row=0, column=2)

texte3 = Label(fenetre, text="Pour jouer, cliquez sur une des icones ci-dessous.")
texte3.grid(row=3, columnspan=3, pady=5)

texte4 = Label(historique, text="Humain :", font=("Helvetica", 16))
texte4.grid(row=0, column=0)

texte5 = Label(historique, text= "Machine :", font=("Helvetica", 16))
texte5.grid(row=1, column=0)

score1 = Label(fenetre, text="0", font=("Helvetica", 16))
score1.grid(row=1, column=0)

score2 = Label(fenetre, text="0", font=("Helvetica", 16))
score2.grid(row=1, column=2)

lab1 = Label(fenetre, image=rien)
lab1.grid(row=2, column=0)

lab2 = Label(fenetre, image=versus)
lab2.grid(row=2, column=1)

lab3 = Label(fenetre, image=rien)
lab3.grid(row=2, column=2)

for colonne in range(10):
    historique_partie = []
    for ligne in range(2):
        lab_hist = Label(historique, image=rien)
        lab_hist.grid(row=ligne, column=colonne+1)
        historique_partie.append(lab_hist)
    historique_image.append(historique_partie)

# boutons
bouton1 = Button(fenetre,command=jouer_pierre)
bouton1.configure(image=pierre)
bouton1.grid(row=4, column=0)

bouton2 = Button(fenetre,command=jouer_papier)
bouton2.configure(image=papier)
bouton2.grid(row=4, column=1)

bouton3 = Button(fenetre,command=jouer_ciseaux)
bouton3.configure(image=ciseaux)
bouton3.grid(row=4, column=2)

bouton4 = Button(fenetre,text='Recommencer',command=reinit)
bouton4.grid(row=5, column=0, pady=10, sticky=E)

bouton5 = Button(fenetre,text='Quitter',command=fenetre.destroy)
bouton5.grid(row=5, column=2, pady=10, sticky=W)


# demarrage :
fenetre.mainloop() 