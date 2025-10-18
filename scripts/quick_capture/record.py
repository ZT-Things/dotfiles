import obsws_python as obs
import subprocess
from dotenv import load_dotenv
import os

load_dotenv()

OBS_PASSWORD = os.getenv("PASSWORD")

# Provide host, port, and password
cl = obs.ReqClient(host="localhost", port=4455, password=OBS_PASSWORD)

# Get recording status
r = cl.get_record_status()
active = r.output_active

# Toggle recording
if not active:
    cl.start_record()
    # subprocess.run([
    #     "notify-send", "-u", "normal", "-t", "2000", "Recording started!"
    # ])
else:
    cl.stop_record()
    subprocess.run([
        "notify-send", "-u", "normal", "-t", "2000", "Recording stopped!"
    ])
