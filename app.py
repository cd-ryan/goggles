from flask import Flask, render_template_string, request
import tldextract
from pathlib import Path
import requests
import subprocess

app = Flask(__name__)
goggles = Path("bad.goggle")
goggles.touch()
# url PARAMETER must be url encoded
update_url = ("https://search.brave.com/api/goggles/submit?url="
              "https%3A%2F%2Fraw.githubusercontent.com%2F"
              f"cd-ryan%2Fgoggles%2Fmaster%2F{goggles.name}")

try:
    _ = subprocess.check_output(["which", "git"])
except subprocess.CalledProcessError as e:
    raise RuntimeError("must install git CLI to use this script") from e


@app.route("/", methods=("GET", "POST"))
def main():
    if request.method == "POST":
        return render_template_string(
            web_form(), submit_msg=add_to_goggles(request.form["url"]))
    return render_template_string(
        web_form(), submit_msg="")


def add_to_goggles(url: str) -> str:
    tld_info = tldextract.extract(url)
    instruction = f"$discard,site={tld_info.domain}.{tld_info.suffix}"

    lines = []
    version = None
    version_index = -1
    with goggles.open("rt") as f:
        c = 0
        for line in f:
            ls = line.strip()
            if ls == instruction:
                return (f'url "{url}" already in list,'
                        f" matching instruction: {instruction}")
            if ls.startswith("! version:"):
                version = ls
                version_index = c
            lines.append(ls)
            c += 1

    if version is None or version_index == -1:
        raise ValueError('must set "! version:" line in file to a number.'
                         " start at 0")

    version_num = int(version.split(":")[1].strip()) + 1
    version = f"! version: {version_num}"

    with goggles.open("wt") as f:
        for line in lines:
            if line.startswith("! version:"):
                f.write(f"{version}\n")
                continue
            f.write(f"{line}\n")
        f.write(f"{instruction}\n")

    cmds = [["git", "add", "."],
            ["git", "commit", "-m", f"new rule: version: {version_num}"],
            ["git", "push"]]

    for cmd in cmds:
        p = subprocess.Popen(cmd, stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE)
        _, err = p.communicate()
        if p.returncode != 0:
            # back out of change:
            with goggles.open("wt") as f:
                for line in lines:
                    f.write(f"{line}\n")
            return (f"error adding URL to list, rc: {p.returncode},"
                    f" stderr: {err}")

    response = requests.post(url=update_url)
    if not response.ok:
        return f'error from goggles API: {response.text}'

    return (f'Successfully added URL "{url}" to list,'
            f" instruction: {instruction}")


def web_form() -> str:
    return """
<h1>Add a New Website</h1>
<br />
<form method="post">
<input type="text" name="url" placeholder="URL"
       value="{{ request.form['url'] }}" style="width: 600px;"></input>
<br />
<button type="submit">Submit</button>
</form>
{% if submit_msg %}
<p>{{ submit_msg }}</p>
{% endif %}
"""
