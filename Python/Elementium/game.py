import pygame
pygame.init()

class Game :
    
    def __init__(self) :
    #Créer la fenêtre du jeu
        pygame.display.set_mode((800, 800))
        pygame.display.set_caption("Mon_Jeu")
    
    
    def run(self):

        #Boucle du jeu
        running = True

        while running :
            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    running = False

        pygame.quit()