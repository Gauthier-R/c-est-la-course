from diffusers import StableDiffusionPipeline
import torch
from PIL import Image

# Charger le modèle Stable Diffusion préentraîné
def load_model():
    print("Chargement du modèle Stable Diffusion...")
    pipeline = StableDiffusionPipeline.from_pretrained(
        "runwayml/stable-diffusion-v1-5",  # Modèle Stable Diffusion préentraîné
        torch_dtype=torch.float16
    )
    pipeline = pipeline.to("cuda")  # Utilise le GPU pour accélérer
    print("Modèle chargé avec succès !")
    return pipeline




def generate_image(pipeline, prompt, output_path="static/generated_image.png"):
    print(f"Génération de l'image pour le prompt : '{prompt}'")
    with torch.autocast("cuda"):
        image = pipeline(prompt).images[0]  # Génère une image
    image.save(output_path)  # Sauvegarde l'image
    print(f"Image sauvegardée à l'emplacement : {output_path}")

