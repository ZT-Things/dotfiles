#!/usr/bin/env python3
import os
import time
import socket
import requests
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
BOT_TOKEN = os.getenv("BOT_TOKEN")
CHAT_ID = int(os.getenv("CHAT_ID"))
CHECK_INTERVAL = 30

def get_local_ip():
    """Get the local IP address of this machine."""
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return None

def send_telegram(ip):
    """Send a message via Telegram bot."""
    message = f"My local IP is: {ip}"
    try:
        requests.get(
            f"https://api.telegram.org/bot{BOT_TOKEN}/sendMessage",
            params={"chat_id": CHAT_ID, "text": message},
            timeout=10
        )
        print(f"Sent IP: {ip}")
    except Exception as e:
        print(f"Failed to send message: {e}")

def monitor_ip():
    last_ip = None
    while True:
        current_ip = get_local_ip()
        if current_ip and current_ip != last_ip:
            send_telegram(current_ip)
            last_ip = current_ip
        time.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    monitor_ip()

