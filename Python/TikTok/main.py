from email_generator import TempEmailManager
from tiktok_generator import create_tiktok_account, configure_chrome, close_browser
import time

# ✅ Programme principal
if __name__ == "__main__":
    manager = TempEmailManager()
    n = int(input("Combien d'emails souhaitez-vous créer ? "))
    manager.create_multiple_emails(n)
    manager.save_accounts()

    while True:
        action = input("Voulez-vous vérifier les emails ? (oui/non) ").strip().lower()
        if action != "oui":
            break
        manager.load_accounts()
        for email_info in manager.emails:
            manager.check_inbox(email_info)

    while True:
        action = input("Voulez-vous supprimer un email ? (oui/non) ").strip().lower()
        if action != "oui":
            break

        manager.load_accounts()
        if not manager.emails:
            print("⚠️ Aucun email enregistré.")
            continue

        print("\n📬 Emails disponibles :")
        for i, email_info in enumerate(manager.emails, 1):
            print(f"{i}. {email_info['email']} (ID: {email_info.get('id', 'Non disponible')})")

        try:
            choice = int(input("\nEntrez le numéro de l'email à supprimer : "))
            if 1 <= choice <= len(manager.emails):
                email_to_delete = manager.emails[choice - 1]
                manager.delete_email(email_to_delete)
            else:
                print("⚠️ Choix invalide.")
        except ValueError:
            print("⚠️ Veuillez entrer un nombre valide.")


    # ✅ Vérifier et créer des comptes TikTok uniquement pour les emails sans compte
    create_tiktok = input("Voulez-vous créer un compte TikTok pour chaque email généré ? (oui/non) ").strip().lower()
    if create_tiktok == "oui":
    
        # Étape 1 : Configurer Chrome avec le VPN
        driver = configure_chrome()

        # Étape 2 : Attendre quelques secondes pour que l'extension s'active
        print("⏳ Attente de l'activation du VPN...")
        time.sleep(10)  # Permettre à l'extension VPN de s'activer

        # Étape 3 : Vérifier si le VPN fonctionne en testant l'IP publique
        driver.get("https://ipinfo.io/")
        time.sleep(5)
        print("🌍 Vérifie si l'IP a changé sur la page affichée.")

        # Étape 4 : Créer un compte TikTok
        create_tiktok_account(driver)

        # Étape 5 : Fermer le navigateur
        close_browser(driver)
