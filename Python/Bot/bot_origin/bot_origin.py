from random import random, choice
import pyautogui
import time
import keyboard
import win32api
import pyperclip

class Origin_bot:
    
    def __init__(self) -> None:
        self.alphabet = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
        self.nombre = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
        self.code = ''
        self.lien_image = ['Python\\Bot\\bot_origin\\image\\EA_logo.png','Python\\Bot\\bot_origin\\image\\utiliser_un_code.png','Python\\Bot\\bot_origin\\image\\zone_entrer_code.png','Python\\Bot\\bot_origin\\image\\suivant.png','Python\\Bot\\bot_origin\\image\\visual_studio_logo.png']


    def generer_code(self):
        for groupe_lettre in range(5):
            for lettre in range(4):
                pourcentage = random()*100
                if pourcentage <=30:
                    caractere = choice(self.nombre)
                    
                else:
                    caractere = choice(self.alphabet).upper()
                self.code += caractere
                
            if groupe_lettre < 4:
                self.code += '-'
                
    
    def afficher_code(self):
        print(self.code)
        
    def reinitialiser_code(self):
        self.code = ''
        self.lien_image = ['Python\\Bot\\bot_origin\\image\\EA_logo.png','Python\\Bot\\bot_origin\\image\\utiliser_un_code.png','Python\\Bot\\bot_origin\\image\\zone_entrer_code.png','Python\\Bot\\bot_origin\\image\\suivant.png','Python\\Bot\\bot_origin\\image\\visual_studio_logo.png']
        
        
    def action_navigation(self, nombre_etape):
        for etape in range(nombre_etape):
            try:
                image = pyautogui.locateOnScreen(self.lien_image[etape], confidence=0.8)
                win32api.SetCursorPos((image[0]+25, image[1]+25)) #Placer le curseur sur l'image
                pyautogui.click() #Cliquer sur l'image

            except pyautogui.ImageNotFoundException:
                print(f"L'image {self.lien_image[etape]}n'est pas visible à l'écran.")
                
            if etape == 0:
                self.action_etape_1()#Etape ou l'on clique sur Origin
                
            if etape == 1:
                self.action_etape_2()#Etape ou l'on clique sur utiliser un code
                
            if etape == 2:
                self.action_etape_3()#Etape ou l'on clique sur la zone pour renseigner le code
                
            if etape == 3:
                self.action_etape_4()#Etape ou l'on clique sur Suivant pour valider le code
    
    def action_etape_1(self):
        time.sleep(0.5)

    def action_etape_2(self):
        time.sleep(4)
        
    def action_etape_3(self):
        pyperclip.copy(self.code)
        pyautogui.hotkey('ctrl','v')
        
    def action_etape_4(self):
        time.sleep(0.5)
        if pyautogui.locateOnScreen('Python\\Bot\\bot_origin\\image\\code_invalide.png', confidence=0.7):
            self.lien_image[4:4] = ['Python\\Bot\\bot_origin\\image\\annuler.png']
            
        else:
            print(f"SUCCES : Un code a fonctionné !!! Le voici : {self.code}")
            self.lien_image[4:4] = ['Python\\Bot\\bot_origin\\image\\EA_logo.png']
        

mon_bot = Origin_bot()

for i in range(int(input("Entrer nombre de simulation : "))):
    mon_bot.generer_code()
    mon_bot.afficher_code()
    mon_bot.action_navigation(6)
    mon_bot.reinitialiser_code()
    time.sleep(0.1)




































