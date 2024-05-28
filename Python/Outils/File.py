import pyperclip

def creer_file(lien):
    lien_ok = ""
    lien_ok+="'"
    for lettre in lien:
        lien_ok += lettre
        lettre_test = ' ' + lettre + ' '
        if lettre_test == " \ " :
            lien_ok+=lettre
    lien_ok+="'"
    print(f'Voici votre lien au bon format (qui a été copié dans votre presse papier) : {lien_ok}')
    pyperclip.copy(lien_ok) 


creer_file(input('Quel est votre lien : '))

    
    
