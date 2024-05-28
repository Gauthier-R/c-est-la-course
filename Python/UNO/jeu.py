from joueur import Joueur

class Jeu :
    
    def __init__(self) -> None:
        self.joueur = Joueur()
        self.UNO_carte = {('0','rouge'):1,('1','rouge'):2,('2','rouge'):2,('3','rouge'):2,('4','rouge'):2,('5','rouge'):2,('6','rouge'):2,('7','rouge'):2,('8','rouge'):2,('9','rouge'):2,#ROUGE
                       ('0','bleu'):1,('1','bleu'):2,('2','bleu'):2,('3','bleu'):2,('4','bleu'):2,('5','bleu'):2,('6','bleu'):2,('7','bleu'):2,('8','bleu'):2,('9','bleu'):2,#BLEU
                       ('0','vert'):1,('1','vert'):2,('2','vert'):2,('3','vert'):2,('4','vert'):2,('5','vert'):2,('6','vert'):2,('7','vert'):2,('8','vert'):2,('9','vert'):2,#VERT
                       ('0','jaune'):1,('1','jaune'):2,('2','jaune'):2,('3','jaune'):2,('4','jaune'):2,('5','jaune'):2,('6','jaune'):2,('7','jaune'):2,('8','jaune'):2,('9','jaune'):2,#JAUNE
                       ('+2','rouge'):2,('+2','bleu'):2,('+2','vert'):2,('+2','jaune'):2, #+2
                       ('reverse','rouge'):2,('reverse','bleu'):2,('reverse','vert'):2,('reverse','jaune'):2,#REVERSE
                       ('pass','rouge'):2,('pass','bleu'):2,('pass','vert'):2,('pass','jaune'):2,#PASS
                       ('joker','couleur'):4,#JOKER
                       ('+4','couleur'):4 #+4
                        }
        
        self.UNO_carte_jouer = None
        
        

        
    #Vérifier s'il reste des cartes dans la pioche
    def verifier_etat_pioche(self):
        if len(self.UNO_carte) == 0:
            self.UNO_carte = {('0','rouge'):1,('1','rouge'):2,('2','rouge'):2,('3','rouge'):2,('4','rouge'):2,('5','rouge'):2,('6','rouge'):2,('7','rouge'):2,('8','rouge'):2,('9','rouge'):2,#ROUGE
                       ('0','bleu'):1,('1','bleu'):2,('2','bleu'):2,('3','bleu'):2,('4','bleu'):2,('5','bleu'):2,('6','bleu'):2,('7','bleu'):2,('8','bleu'):2,('9','bleu'):2,#BLEU
                       ('0','vert'):1,('1','vert'):2,('2','vert'):2,('3','vert'):2,('4','vert'):2,('5','vert'):2,('6','vert'):2,('7','vert'):2,('8','vert'):2,('9','vert'):2,#VERT
                       ('0','jaune'):1,('1','jaune'):2,('2','jaune'):2,('3','jaune'):2,('4','jaune'):2,('5','jaune'):2,('6','jaune'):2,('7','jaune'):2,('8','jaune'):2,('9','jaune'):2,#JAUNE
                       ('+2','rouge'):2,('+2','bleu'):2,('+2','vert'):2,('+2','jaune'):2, #+2
                       ('reverse','rouge'):2,('reverse','bleu'):2,('reverse','vert'):2,('reverse','jaune'):2,#REVERSE
                       ('pass','rouge'):2,('pass','bleu'):2,('pass','vert'):2,('pass','jaune'):2,#PASS
                       ('joker','couleur'):4,#JOKER
                       ('+4','couleur'):4 #+4
                        }
            
            for carte in self.joueur.main:
                if carte in self.UNO_carte.keys():
                    del self.UNO_carte[carte]
                    
                    
                    
    
            
            
        
        
    
    
    
        