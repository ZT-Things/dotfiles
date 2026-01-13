from obswebsocket import obsws, requests
from dotenv import load_dotenv
import os

load_dotenv()

OBS_PASSWORD = os.getenv("PASSWORD")

host = "localhost"
port = 4455

ws = obsws(host, port, OBS_PASSWORD)
ws.connect()
ws.call(requests.StartReplayBuffer())  # if not already started
ws.call(requests.SaveReplayBuffer())
ws.disconnect()

import subprocess
# subprocess.run([
#     "notify-send",  # or "mako-client" if you want it Wayland native
#     "-u", "normal",
#     "-t", "2000",
#     "Replay saved!"
# ])
