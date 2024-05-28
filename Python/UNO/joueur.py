from jeu import Jeu

from random import choice

class Joueur :
    
    def __init__(self) -> None:
        self.jeu = Jeu()
        self.main = []
        
        
    #Piocher une carte / Actualiser le paquet 
    def piocher_carte(self, nb_carte = 1):
        for carte in range(nb_carte):
            carte_pioche = choice(list(self.jeu.UNO_carte.keys()))
            self.main.append(carte_pioche)
            self.jeu.UNO_carte[carte_pioche] -= 1
            if self.jeu.UNO_carte[carte_pioche] == 0:
                del self.jeu.UNO_carte[carte_pioche]
                self.jeu.verifier_etat_pioche()
        
        
        if self.jeu.UNO_carte_jouer == None:
            carte_jouer = choice(list(self.jeu.UNO_carte.keys()))
            
            while carte_jouer[0] in ['+2', 'reverse', 'pass', 'joker', '+4']:
                carte_jouer = choice(list(self.jeu.UNO_carte.keys()))
                
            self.jeu.UNO_carte_jouer = carte_jouer
            self.jeu.UNO_carte[carte_jouer] -= 1
            if self.jeu.UNO_carte[carte_jouer] == 0:
                del self.jeu.UNO_carte[carte_jouer]
                
                
                
    #Jouer une carte :
    
    def jouer_carte(self, carte):
        if carte[0] == self.jeu.UNO_carte_jouer[0] or carte[1] == self.jeu.UNO_carte_jouer[1]:
            self.jeu.UNO_carte_jouer = carte
            self.main.remove(carte)
            
        else:
            print("PAS JOUABLE")
        
        
        
          
                
            
            


            
            
            