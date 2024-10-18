import threading
import pyautogui
import time
import keyboard  # Bibliothèque pour surveiller les pressions de touches

# Variable pour contrôler la boucle
running = True

def stop_script():
    global running
    keyboard.wait('a')  # Attendre que la touche "a" soit enfoncée
    running = False
    print("Arrêt du script.")

# Thread pour surveiller l'arrêt du script
stop_thread = threading.Thread(target=stop_script)
stop_thread.start()

try:
    while running:
        pyautogui.keyDown('z')
        time.sleep(1)  # Appuyer sur 'z' pendant 1 seconde
        pyautogui.keyUp('z')
        
        pyautogui.keyDown('s')
        time.sleep(1)  # Appuyer sur 's' pendant 1 seconde
        pyautogui.keyUp('s')
        
        time.sleep(0.1)  # Petite pause entre les cycles
finally:
    pyautogui.keyUp('z')
    pyautogui.keyUp('s')
    print("Script arrêté.")
