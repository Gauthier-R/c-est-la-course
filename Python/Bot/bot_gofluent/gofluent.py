import pyautogui

# Fonction pour déplacer la souris et effectuer un clic
def move_and_click():
    # Récupérer les dimensions de l'écran
    screen_width, screen_height = pyautogui.size()
    
    # Trouver le milieu de l'écran
    middle_x = screen_width // 2
    middle_y = screen_height // 2
    
    # Boucle de déplacement et de clic indéfinie
    while True:
        # Déplacer la souris de droite à gauche sur 10 pixels
        for i in range(10):
            pyautogui.moveTo(middle_x + i, middle_y)
            pyautogui.click()
        
        # Déplacer la souris de gauche à droite sur 10 pixels
        for i in range(10):
            pyautogui.moveTo(middle_x + 10 - i, middle_y)
            pyautogui.click()

# Boucle tant que l'utilisateur n'appuie pas sur 'q'
while True:
    key = input("Appuyez sur 'q' pour quitter: ")
    if key.lower() == 'q':
        break
    else:
        move_and_click()
