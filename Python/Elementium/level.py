import pygame
from settings import *
from player import Player

class Level:
    
    def __init__(self) :
        #get display surface
        self.display_surface = pygame.display.get_surface()
        
        #sprites groups
        self.all_sprites = pygame.sprite.Group()
        
        self.setup()
        
        
    def setup(self):
        self.player = Player((SCREEN_WIDHT//2,SCREEN_HEIGHT//2), self.all_sprites)
    
    
    def run(self, dt):
        self.display_surface.fill('white')
        self.all_sprites.draw(self.display_surface)
        self.all_sprites.update(dt)