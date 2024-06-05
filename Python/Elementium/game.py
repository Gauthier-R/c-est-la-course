import pygame, sys
from settings import *
from level import Level

class Game:
    
    def __init__(self) :
        pygame.init()
        self.SCREEN = pygame.display.set_mode((SCREEN_WIDHT, SCREEN_HEIGHT))
        pygame.display.set_caption('Elementium')
        self.CLOCK = pygame.time.Clock()
        self.LEVEL = Level()
        
        
        
    def run(self):
        
        while True:
            
            for event in pygame.event.get():
                
                if event.type == pygame.QUIT:
                    pygame.quit()
                    sys.exit()
                    
            dt = self.CLOCK.tick()/1000
            self.LEVEL.run(dt)
            
            pygame.display.update()
        