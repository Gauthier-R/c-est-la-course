import pyautogui, time, pywhatkit

pywhatkit.sendwhatmsg("+330749261037", "ALERTE, auto destruction du téléphone dans 10 secondes", 21,45,10)
time.sleep(5)
for i in range(20):
    pyautogui.write("je t aime")
    pyautogui.press("enter")

time.sleep(10)
pyautogui.write("HAHA, tu t es fais pranker par le super spam-bot")
pyautogui.press("enter")

time.sleep(10)
for i in range(10):
    pyautogui.write("Bonne nuit mon petit")
    pyautogui.press("enter")

    