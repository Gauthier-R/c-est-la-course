from joueur import Joueur

from random import random
from tkinter import Tk


mon_joueur = Joueur()
mon_joueur.piocher_carte(7)


fenetre = Tk()

longueur, largeur = fenetre.winfo_screenwidth(), fenetre.winfo_screenheight()

fenetre.title("UNO")
fenetre.geometry(f"{longueur//2}x{largeur//2}")

fenetre.mainloop()