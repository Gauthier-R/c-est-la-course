from generate import load_model, generate_image

if __name__ == "__main__":
    # Charger le modèle
    pipeline = load_model()

    # Prompt pour générer une image
    prompt = "A futuristic cityscape at night with neon lights"

    # Générer et sauvegarder l'image
    generate_image(pipeline, prompt)
