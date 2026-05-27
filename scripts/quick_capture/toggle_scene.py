from obswebsocket import obsws, requests
from dotenv import load_dotenv
import os
import subprocess

load_dotenv()

OBS_PASSWORD = os.getenv("PASSWORD")

host = "localhost"
port = 4455

ws = obsws(host, port, OBS_PASSWORD)
ws.connect()

# ---- GET CURRENT SCENE ----
current_scene = ws.call(requests.GetCurrentProgramScene())

scene_name = current_scene.getCurrentProgramSceneName()

# ---- TOGGLE LOGIC ----
if scene_name == "SHARE":
    ws.call(requests.SetCurrentProgramScene(sceneName="HIDE"))
    new_scene = "HIDE"
else:
    ws.call(requests.SetCurrentProgramScene(sceneName="SHARE"))
    new_scene = "SHARE"

ws.disconnect()

# ---- NOTIFICATION ----
subprocess.run([
    "notify-send",
    "-u", "normal",
    "-t", "1200",
    f"OBS Scene → {new_scene}"
])
