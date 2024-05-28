import os
import pyautogui
import time
import keyboard
import random
import win32api, win32cona
from PIL import Image


#Afficher la position + code RGB de sa souris
#pyautogui.displayMousePosition()
#X: 704 Y: 900 RGB: (239, 236, 231)
#X: 1265 Y: 900 RGB: (255, 255, 255)

class Bot_Samsung:
    
    def __init__(self):
        self.region_obstacle = (613, 188, 1335, 777)
        self.region_medaille = (613, 656, 1335, 777)
        self.play = False
        
        
    def is_playing(self):
        if keyboard.is_pressed('a') == True and self.play==False:
            self.play = True
            time.sleep(1)
        elif keyboard.is_pressed('a') == True and self.play==True:
            self.play = False
            time.sleep(1)
        else:
            pass
        
        
    def medaille_silver(self):
        try:
            image_location = pyautogui.locateOnScreen('C:\\Users\\Gauthierr\\OneDrive\\Documents\\Libre office\\Projet Code\\Python\\Bot\\image\\medaille_silver.png', confidence=0.8, region=self.region_medaille)

            if image_location is not None :
                print("L'image est trouvée à la position :", image_location)
                win32api.SetCursorPos((image_location[0], 700))
                
        except pyautogui.ImageNotFoundException:
            print("L'image n'est pas visible à l'écran.")
            
            
            
    def medaille_gold(self):
        try:
            image_location1 = pyautogui.locateOnScreen('C:\\Users\\Gauthierr\\OneDrive\\Documents\\Libre office\\Projet Code\\Python\\Bot\\image\\medaille_gold.png', confidence=0.8, region=self.region_medaille)
           

            if image_location1 is not None :
                print("L'image est trouvée à la position :", image_location1)
                win32api.SetCursorPos((image_location1[0], 700))
                
        except pyautogui.ImageNotFoundException:
            print("L'image n'est pas visible à l'écran.")
            
            
            
    def barriere(self):
        try:
            image_location2 = pyautogui.locateOnScreen('C:\\Users\\Gauthierr\\OneDrive\\Documents\\Libre office\\Projet Code\\Python\\Bot\\image\\barriere.png', confidence=0.9, region=self.region_obstacle)
  
            if image_location2 is not None :
                print("L'image est trouvée à la position :", image_location2)
                if image_location2[0] < 975 :
                    win32api.SetCursorPos((image_location2[0]+300, 700))
                elif image_location2[0] >= 975 :
                    win32api.SetCursorPos((image_location2[0]-300, 700))
            
                time.sleep(2)
                
                
        except pyautogui.ImageNotFoundException:
            print("L'image n'est pas visible à l'écran.")
            
            
    
    def flaque(self):
        try:
            
            image_location3 = pyautogui.locateOnScreen('C:\\Users\\Gauthierr\\OneDrive\\Documents\\Libre office\\Projet Code\\Python\\Bot\\image\\flaque.png', confidence=0.9, region=self.region_obstacle)
  
            if image_location3 is not None :
                print("L'image est trouvée à la position :", image_location3)
                if image_location3[0] < 975 :
                    win32api.SetCursorPos((image_location3[0]+300, 700))
                elif image_location3[0] >= 975 :
                    win32api.SetCursorPos((image_location3[0]-300, 700))
                
                time.sleep(2)
                
                
        except pyautogui.ImageNotFoundException:
            print("L'image n'est pas visible à l'écran.")
            
    
    def rejouer(self):
        try:
            
            image_location4 = pyautogui.locateOnScreen('C:\\Users\\Gauthierr\\OneDrive\\Documents\\Libre office\\Projet Code\\Python\\Bot\\image\\rejouer.png', confidence=0.9, region=(1075, 909, 1500, 990))
  
            if image_location4 is not None:
                print("L'image est trouvée à la position :", image_location4)
                
                # Récupérer les coordonnées du centre de l'image trouvée
                center_x = image_location4[0] + image_location4[2] // 2
                center_y = image_location4[1] + image_location4[3] // 2

                # Déplacer le curseur de la souris sur le centre de l'image
                win32api.SetCursorPos((center_x, center_y))
                
                # Cliquer sur l'image
                win32api.mouse_event(win32con.MOUSEEVENTF_LEFTDOWN, center_x, center_y, 0, 0)
                win32api.mouse_event(win32con.MOUSEEVENTF_LEFTUP, center_x, center_y, 0, 0)
                
                # Attendre un court délai pour s'assurer que le clic est pris en compte
                time.sleep(0.5)
                
                # Déplacer la souris vers la barre de défilement
                pyautogui.moveTo(x=1910, y=422)  # Ajustez les coordonnées en fonction de la position de la barre de défilement

                # Cliquer et maintenir pour faire défiler vers le bas
                pyautogui.mouseDown(button='left')

                time.sleep(0.5)
                
                # Déplacer la souris vers le bas pour faire défiler
                pyautogui.move(0, 125, duration=1)  # Ajustez le nombre de pixels pour contrôler la quantité de défilement

                # Relâcher le clic de la souris
                pyautogui.mouseUp(button='left')
                
        except pyautogui.ImageNotFoundException:
            print("L'image n'est pas visible à l'écran.")
            
            

        
        

mon_bot = Bot_Samsung()

while keyboard.is_pressed('q') == False:
    
    print('PAUSE')
    mon_bot.is_playing()
        
    
        
    while mon_bot.play == True :

        mon_bot.is_playing()
        mon_bot.medaille_silver()
        mon_bot.medaille_gold()
        mon_bot.flaque()
        mon_bot.barriere()
        mon_bot.rejouer()        
                
        
        
        
                    
            
print('Fermeture du programme')