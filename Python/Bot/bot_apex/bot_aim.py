import pyautogui
import keyboard
import win32api
import time
import random
import pydirectinput



# Fonction pour vérifier si le bouton droit de la souris est enfoncé
def is_right_button_pressed():
    return win32api.GetKeyState(0x02) < 0

def is_left_button_pressed():
    return win32api.GetKeyState(0x01) < 0

def is_left_button_held_for_1_second():
    start_time = time.time()
    while is_left_button_pressed():
        if time.time() - start_time >= 0.1:
            return True
    return False

print("Démarrage Bot_apex.py")
print("Démarrage Bot_aim.py")

while True:
    
    if is_right_button_pressed() and is_left_button_held_for_1_second():
        
            i = random.randint(1,2)
            j= random.randint(10,12)
            
            #pydirectinput.moveRel(position_souris[0] + distance, position_souris[1])
            pydirectinput.moveRel(0, j, relative=True)
            pydirectinput.moveRel(0, j, relative=True)
            

        
print("Fermeture du programme")           


#Flatline :  j= random.randint(10,12)
#R-99 : j= random.randint(25,26)

    