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
    
stop_thread = threading.Thread(target=stop_script)
stop_thread.start()

try:
    time.sleep(5)
    while running:
        pyautogui.mouseDown(button='right')


finally:
    pyautogui.mouseUp(button='right')
    print("Script arrêté.")