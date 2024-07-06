import pygame, sys

class Game:
    
    def __init__(self) :
        pygame.init()
        
        self.SCREEN = pygame.display.set_mode((800, 500))
        pygame.display.set_caption('Mon entrainement')
        
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
            
            
class Level :
    
    def __init__(self) :
        self.display_surface = pygame.display.get_surface()
        
        self.all_sprites = pygame.sprite.Group()
        
        self.setup()
        
        
    def setup(self):
        PLAYER = Player((400, 250), self.all_sprites)
        MONSTER = Monster((500, 250), self.all_sprites)
        
        
    def run(self, dt):
        self.display_surface.fill('black')
        self.all_sprites.draw(self.display_surface)
        self.all_sprites.update(dt)
        
        
class Player(pygame.sprite.Sprite):
    
    def __init__(self, pos, groups) :
        super().__init__(groups)
        
        self.image = pygame.Surface((15, 30))
        self.image.fill('green')
        self.rect = self.image.get_rect(center = pos)
        
        self.direction = pygame.math.Vector2()
        self.position = pygame.math.Vector2(self.rect.center)
        self.speed = 200
        
    
    
    def input(self):
        keys = pygame.key.get_pressed()
        
        if keys[pygame.K_UP]:
            self.direction.y = -1
        elif keys[pygame.K_DOWN]:
            self.direction.y = 1
        else:
            self.direction.y=0
            
        if keys[pygame.K_LEFT]:
            self.direction.x = -1
        elif keys[pygame.K_RIGHT]:
            self.direction.x = 1
        else:
            self.direction.x=0
            
            
    def move(self, dt):
        self.position += self.direction * self.speed * dt
        self.rect.center = self.position
        
    
    def update(self, dt):
        self.input()
        self.move(dt)
            
            
class Monster(pygame.sprite.Sprite):
    
    def __init__(self, pos, groups) :
        super().__init__(groups)
        
        self.image = pygame.Surface((15, 30))
        self.image.fill('red')
        self.rect = self.image.get_rect(center = pos)
        
        self.direction = 1
        self.position = pygame.math.Vector2(self.rect.center)
        self.speed = 100
        
        
    
    def move(self, dt):
        if self.position.y < 200 :
            self.direction = 1
        elif self.position.y > 300 :
            self.direction = -1
        self.position.y += self.direction * self.speed * dt
        self.rect = self.position
        
        
                
    def update(self, dt):
        self.move(dt)
        
        
        
        
        
        
        
        
        
        
        
    
        
            
            
            
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
                    
if __name__ == '__main__':
    game = Game()
    game.run()