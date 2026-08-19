import urllib.request
import json
import sys

API_KEY = "AIzaSyBo5HXMWr_AVppR-5UgITZSBzZpootcHlQ"
url = f"https://generativelanguage.googleapis.com/v1beta/models?key={API_KEY}"

try:
    req = urllib.request.Request(url)
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read())
        print("Available models:")
        for model in data.get('models', []):
            print(f"- {model['name']} (supported methods: {model.get('supportedGenerationMethods', [])})")
except urllib.error.HTTPError as e:
    print(f"HTTP Error: {e.code} - {e.read().decode('utf-8')}")
except Exception as e:
    print(f"Error: {e}")
