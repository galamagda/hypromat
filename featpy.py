import urllib.request
import json
import sys


def fetch_release_info():
    url = "https://api.github.com/repos/abouabou/hypromat/releases/latest"
    try:
        with urllib.request.urlopen(url) as response:
            data = response.read()
            return json.loads(data)
    except Exception as e:
        print("Une erreur s'est produite :", e)
        return None


def fetch_code_site():
    url = "https://framacarte.org/fr/datalayer/182449/326510/"
    try:
        with urllib.request.urlopen(url) as response:
            return json.loads(response.read().decode())
    except Exception as e:
        print("Une erreur s'est produite :", e)
        return None


if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "fetch_code_site":
        result = fetch_code_site()
        if result:
            with open("hypromat/dataset.json", "w") as json_file:
                json_file.write(json.dumps(result["features"]))
    elif len(sys.argv) > 1 and sys.argv[1] == "fetch_release_info":
        result = fetch_release_info()
        if result:
            with open("hypromat/version.txt", "w") as txt_file:
                txt_file.write(result)
