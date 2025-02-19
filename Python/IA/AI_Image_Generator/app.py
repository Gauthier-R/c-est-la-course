from flask import Flask, render_template, request
from flask_socketio import SocketIO
from generate import load_model, generate_image
import glob
import time
from datetime import datetime
import threading

# Initialiser Flask et SocketIO
app = Flask(__name__)
socketio = SocketIO(app)

# Charger le modèle lors du démarrage
pipeline = load_model()

@app.route("/")
def home():
    return render_template("index.html")

@app.route("/generate", methods=["POST"])
def generate():
    prompt = request.form["prompt"]
    style = request.form["style"]
    num_images = int(request.form["num_images"])

    # ID unique pour la session
    session_id = datetime.now().strftime("%Y%m%d%H%M%S")

    # Lancer un thread pour la génération des images
    thread = threading.Thread(target=generate_images, args=(prompt, style, num_images, session_id))
    thread.start()

    # Retourner la page avec la barre de progression
    return render_template("waiting.html", session_id=session_id)


@socketio.on('test_connection')
def test_connection(data):
    print("WebSocket client connecté avec succès.")
    socketio.emit('test_response', {'message': 'Connexion établie !'})


@socketio.on('track_progress')
def track_progress(data):
    session_id = data['session_id']

    while session_id in progress_data:
        progress = progress_data.get(session_id, 0)
        socketio.emit('progress_update', {'progress': progress, 'session_id': session_id})
        
        if progress == 100:
            break

        time.sleep(1)  # Délai pour permettre les mises à jour


@app.route("/result/<session_id>")
def result(session_id):
    # Récupérer uniquement les fichiers générés pour cette session
    image_paths = [f"generated_image_{session_id}_{i + 1}.png" for i in range(5)]
    return render_template("result.html", image_paths=image_paths)


# Progression globale par session
progress_data = {}

def generate_images(prompt, style, num_images, session_id):
    global progress_data
    progress_data[session_id] = 0  # Initialiser la progression

    for i in range(num_images):
        output_path = f"static/generated_image_{session_id}_{i + 1}.png"
        print(f"Vérification du chemin : {output_path}")  # Debugging
        generate_image(pipeline, f"{prompt}, in {style} style", output_path)
        progress_data[session_id] = int(((i + 1) / num_images) * 100)

    progress_data[session_id] = 100


if __name__ == "__main__":
    socketio.run(app, debug=True)
