from flask import Flask, render_template, request, redirect, url_for
import os
import subprocess

app = Flask(__name__)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/start', methods=['POST'])
def start_server():
    # Start the Minecraft server here
    subprocess.Popen(['bash', 'start_server.sh'])
    return redirect(url_for('index'))

@app.route('/stop', methods=['POST'])
def stop_server():
    # Stop the Minecraft server here
    subprocess.Popen(['pkill', '-f', 'server.jar'])
    return redirect(url_for('index'))


