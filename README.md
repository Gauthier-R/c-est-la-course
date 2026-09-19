# dinners_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Commandes utiles

1. Pour lancer l'application sur un appareil :

- Afficher les appareils : `flutter devices`
- Lancement sur un appareil : `flutter run -d <deviceID>`

2. Pour lancer sur un émulateur Android :

- Démarrer un émulateur : `flutter emulators --launch Medium_Phone_API_35`
- Lancement sur un émulateur : `flutter run -d emulator-5554`

3. Pour mettre à jour la version Web (En ligne) :

- Compiler pour le Web : `flutter build web --release`
- Envoyer sur Firebase : `firebase deploy --only hosting`
Une fois cette commande terminée, votre site est à jour pour tout le monde !

4. Pour mettre à jour l'APK (Android) :

- Générer le fichier : `flutter build apk --release`
- Publier sur GitHub : `gh release create v1.x.x build\app\outputs\flutter-apk\app-release.apk --repo Gauthier-R/DinnersApp-Releases --title "v1.x.x"`
(Pensez à changer le numéro de version à chaque fois, par exemple v1.1.0, v1.2.0, etc.)




