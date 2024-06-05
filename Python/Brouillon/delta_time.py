import pygame, time, sys


pygame.init()

launch = time.time()

screen = pygame.display.set_mode((900, 600))
pygame.display.set_caption('Delta_time')

rect = pygame.Rect(0, 300, 100, 100)
test_pos = rect.x
speed = 200

clock = pygame.time.Clock()

while True:
    
    dt = clock.tick(600) / 1000
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            pygame.quit()
            sys.exit()
    
    if rect.x >= 900:
        print(time.time() - launch)
        pygame.quit()
        sys.exit()
            
    
    
    screen.fill('white')
    
    rect.x += speed*dt
    print(speed*dt)
    pygame.draw.rect(screen, 'red', rect)
    
    pygame.display.update()


    
