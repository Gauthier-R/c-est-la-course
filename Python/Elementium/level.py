import pygame
from settings import *

class Level:
    
    def __init__(self) :
        #get display surface
        self.display_surface = pygame.display.get_surface()
        
        #sprites groups
        self.all_sprites = pygame.sprite.Group()
    
    def run(self, dt):
        self.display_surface.fill('white')
        self.all_sprites.draw(self.display_surface)
        self.all_sprites.update()