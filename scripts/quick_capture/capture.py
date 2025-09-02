from obswebsocket import obsws, requests

host = "localhost"
port = 4455
password = "ckbLQGay6TE9j0UO"

ws = obsws(host, port, password)
ws.connect()
ws.call(requests.StartReplayBuffer())  # if not already started
ws.call(requests.SaveReplayBuffer())
ws.disconnect()

import subprocess
subprocess.run([
    "notify-send",  # or "mako-client" if you want it Wayland native
    "-u", "normal",
    "-t", "2000",
    "Replay saved!"
])
