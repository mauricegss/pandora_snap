from flask import Flask, request, jsonify
from playwright.sync_api import sync_playwright, TimeoutError as PlaywrightTimeoutError
import json
import os
import time
import threading
from dotenv import load_dotenv
load_dotenv()

app = Flask(__name__)

# --- CONFIGURAÇÃO ---
EMAIL = os.getenv("THE_EMAIL")
PASSWORD = os.getenv("THE_PASSWORD")
PROJECT_ID = os.getenv("THE_PROJECT_ID")

def upload_and_cleanup(image_path, label_path):
    print(f"THREAD INICIADA: A começar o upload para {image_path}")
    success, message = upload_via_browser(image_path, label_path)

    if success:
        print("THREAD: Upload bem-sucedido.")
    else:
        print(f"THREAD: Ocorreu um erro no upload - {message}")

    try:
        os.remove(image_path)
        os.remove(label_path)
        print("THREAD: Ficheiros temporários removidos.")
    except OSError as e:
        print(f"THREAD: Erro ao remover ficheiros temporários: {e}")

def upload_via_browser(image_path, label_path):
    try:
        with sync_playwright() as p:
            # headless=False abre uma janela do navegador para depuração.
            browser = p.chromium.launch(headless=True) 
            page = browser.new_page()
            
            print("Iniciando login no Edge Impulse...")
            page.goto("https://studio.edgeimpulse.com/login")
            page.fill('#username-or-email-input', EMAIL)
            page.click('text=Next')
            page.wait_for_selector('#password', timeout=15000)
            page.fill('#password', PASSWORD)
            page.click('#login-button')
            
            print("Login bem-sucedido. Navegando para a página de aquisição de dados...")
            page.wait_for_selector('text=Dashboard', timeout=15000)
            page.goto(f"https://studio.edgeimpulse.com/studio/{PROJECT_ID}/acquisition/training")
            
            page.wait_for_load_state('networkidle', timeout=10000)

            print("Abrindo o diálogo de upload...")
            upload_dialog_locator = page.locator('#add-data-modal')
            page.click('a.btn-acquisition-upload')
            
            page.wait_for_selector('#file-selector', state='visible', timeout=5000)
            print(f"Enviando ficheiros: {image_path} e {label_path}")
            page.set_input_files('#file-selector', [image_path, label_path])
            
            time.sleep(1) 

            print("Iniciando o upload...")
            page.click('#upload-button')
            
            print("Aguardando a conclusão do upload (5 segundos)...")
            time.sleep(5)
            
            print("✅ Upload concluído com sucesso!")
            browser.close()
            return True, "Upload via browser concluído com sucesso."
            
    except PlaywrightTimeoutError as e:
        error_message = f"Ocorreu um timeout durante a automação: {e}"
        print(f"❌ ERRO: {error_message}")
        try: browser.close()
        except: pass
        return False, error_message
    except Exception as e:
        error_message = f"Ocorreu um erro inesperado na automação: {e}"
        print(f"❌ ERRO: {error_message}")
        try: browser.close()
        except: pass
        return False, error_message

@app.route('/upload', methods=['POST'])
def handle_upload():
    if 'image' not in request.files:
        return jsonify({"error": "Nenhuma imagem enviada"}), 400

    image_file = request.files['image']
    label = request.form.get('label').lower()
    bounding_box = {
        "x": int(request.form.get('bbox_x')),
        "y": int(request.form.get('bbox_y')),
        "width": int(request.form.get('bbox_width')),
        "height": int(request.form.get('bbox_height')),
    }
    
    # --- CORREÇÃO DOS NOMES DE FICHEIRO APLICADA AQUI ---
    # 1. Cria um nome de ficheiro único para a imagem.
    unique_image_filename = f"{int(time.time())}_{label}.jpg"
    
    # 2. O nome do ficheiro de labels é sempre 'info.labels'.
    label_filename = "info.labels"

    image_path = os.path.join(os.getcwd(), unique_image_filename)
    image_file.save(image_path)

    # 3. O conteúdo do 'info.labels' aponta para o nome único da imagem.
    labels_data = {
        "version": 1,
        "files": [
            {
                "path": unique_image_filename,
                "category": "training",
                "label": {"type": "label", "label": label},
                "boundingBoxes": [{"label": label, "x": bounding_box['x'], "y": bounding_box['y'], "width": bounding_box['width'], "height": bounding_box['height']}]
            }
        ]
    }
    
    label_path = os.path.join(os.getcwd(), label_filename)
    with open(label_path, "w") as f:
        json.dump(labels_data, f)
    
    print(f"Ficheiros temporários criados: {image_path} e {label_path}")

    # Inicia a automação em segundo plano
    thread = threading.Thread(target=upload_and_cleanup, args=(image_path, label_path))
    thread.start()

    return jsonify({"message": "Requisição recebida. O processamento foi iniciado em segundo plano."}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)