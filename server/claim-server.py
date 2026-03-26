#!/usr/bin/env python3
"""Self-service login claim page for RStudio Server workshop."""

import http.server
import json
import os
import tempfile
import threading
import html
import urllib.parse

STATE_FILE = "/var/lib/claim/state.json"
GALLERY_DIR = "/var/lib/gallery"
RSTUDIO_URL = "http://your-server-ip:8787"
PASSWORD = "changeme"
ADMIN_KEY = "changeme"

ACCOUNTS = {
    "nightingale": "Florence Nightingale — pioneer of statistical graphics",
    "athey": "Susan Athey — causal machine learning",
    "hill": "Jennifer Hill — Bayesian Additive Regression Trees",
    "stuart": "Elizabeth Stuart — propensity score methods",
    "petersen": "Maya Petersen — targeted learning (TMLE)",
    "maathuis": "Marloes Maathuis — causal DAGs and discovery",
    "didelez": "Vanessa Didelez — causal inference",
    "uhler": "Caroline Uhler — causal discovery",
    "perkovic": "Emilija Perkovic — causal DAGs",
    "schnitzer": "Mireille Schnitzer — causal inference",
    "pearl": "Judea Pearl — do-calculus and DAGs",
    "rubin": "Donald Rubin — potential outcomes framework",
    "wright": "Sewall Wright — path analysis",
    "neyman": "Jerzy Neyman — Neyman-Pearson framework",
    "hernan": "Miguel Hernan — causal inference",
    "robins": "James Robins — g-methods",
    "imbens": "Guido Imbens — Nobel Prize 2021",
    "haavelmo": "Trygve Haavelmo — causal econometrics",
    "spirtes": "Peter Spirtes — causal discovery",
    "dawid": "Philip Dawid — decision-theoretic causality",
}

lock = threading.Lock()


def load_state():
    if os.path.exists(STATE_FILE):
        with open(STATE_FILE) as f:
            return json.load(f)
    return {"claimed": {}}


def save_state(state):
    state_dir = os.path.dirname(STATE_FILE)
    os.makedirs(state_dir, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=state_dir, suffix=".tmp")
    with os.fdopen(fd, "w") as f:
        json.dump(state, f)
    os.replace(tmp, STATE_FILE)


def render_page(message=None, claimed_name=None):
    state = load_state()
    claimed = state["claimed"]
    available = [n for n in ACCOUNTS if n not in claimed]

    if claimed_name:
        desc = html.escape(ACCOUNTS[claimed_name])
        msg_html = f"""
        <div class="success">
            <h2>Your login is ready</h2>
            <table class="credentials">
                <tr><td>Username</td><td><strong>{html.escape(claimed_name)}</strong></td></tr>
                <tr><td>Password</td><td><strong>{PASSWORD}</strong></td></tr>
                <tr><td>Who</td><td>{desc}</td></tr>
            </table>
            <a href="{RSTUDIO_URL}" class="button" target="_blank">Open RStudio Server</a>
        </div>"""
    elif message:
        msg_html = f'<div class="error">{html.escape(message)}</div>'
    else:
        msg_html = ""

    available_html = ""
    if available:
        cards = []
        for name in available:
            desc = html.escape(ACCOUNTS[name])
            cards.append(f"""
            <form method="POST" style="display:inline">
                <input type="hidden" name="name" value="{html.escape(name)}">
                <button type="submit" class="card">
                    <span class="card-name">{html.escape(name)}</span>
                    <span class="card-desc">{desc}</span>
                </button>
            </form>""")
        available_html = "\n".join(cards)
    else:
        cards = []
        for name in ACCOUNTS:
            desc = html.escape(ACCOUNTS[name])
            cards.append(f"""
            <form method="POST" style="display:inline">
                <input type="hidden" name="name" value="{html.escape(name)}">
                <input type="hidden" name="lookup" value="1">
                <button type="submit" class="card claimed">
                    <span class="card-name">{html.escape(name)}</span>
                    <span class="card-desc">{desc}</span>
                </button>
            </form>""")
        available_html = "\n".join(cards)

    taken_count = len(claimed)
    total = len(ACCOUNTS)

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Workshop Login</title>
<style>
  * {{ margin: 0; padding: 0; box-sizing: border-box; }}
  body {{
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    background: #FAFBFC;
    color: #1B2B3A;
    min-height: 100vh;
    padding: 2rem 1rem;
  }}
  .container {{ max-width: 800px; margin: 0 auto; }}
  h1 {{
    text-align: center;
    font-size: 1.8rem;
    margin-bottom: 0.3rem;
    color: #1B2B3A;
  }}
  .subtitle {{
    text-align: center;
    color: #506070;
    margin-bottom: 0.5rem;
    font-size: 0.95rem;
  }}
  .counter {{
    text-align: center;
    color: #8A9AAA;
    margin-bottom: 2rem;
    font-size: 0.85rem;
  }}
  .grid {{
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
    gap: 0.75rem;
    margin-top: 1rem;
  }}
  .card {{
    background: #ffffff;
    border: 1px solid #D4EBF5;
    border-radius: 8px;
    padding: 1rem;
    cursor: pointer;
    text-align: left;
    color: #1B2B3A;
    transition: all 0.2s;
    display: block;
    width: 100%;
    font-family: inherit;
    font-size: inherit;
    box-shadow: 0 1px 3px rgba(0,0,0,0.06);
  }}
  .card:hover {{
    border-color: #107895;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(16,120,149,0.15);
  }}
  .card.claimed {{
    opacity: 0.5;
    border-color: #009E73;
    cursor: default;
  }}
  .card-name {{
    display: block;
    font-size: 1.2rem;
    font-weight: 700;
    color: #107895;
    margin-bottom: 0.3rem;
  }}
  .card-desc {{
    display: block;
    font-size: 0.8rem;
    color: #506070;
  }}
  .success {{
    background: #e8f5e9;
    border: 1px solid #009E73;
    border-radius: 8px;
    padding: 2rem;
    margin: 2rem 0;
    text-align: center;
  }}
  .success h2 {{
    color: #009E73;
    margin-bottom: 1rem;
  }}
  .credentials {{
    margin: 1rem auto;
    border-collapse: collapse;
    text-align: left;
  }}
  .credentials td {{
    padding: 0.4rem 1rem;
    font-size: 1.1rem;
  }}
  .credentials td:first-child {{
    color: #506070;
  }}
  .button {{
    display: inline-block;
    background: #107895;
    color: white;
    padding: 0.8rem 2rem;
    border-radius: 6px;
    text-decoration: none;
    font-weight: 600;
    margin-top: 1rem;
    transition: background 0.2s;
  }}
  .button:hover {{ background: #0C6480; }}
  .error {{
    background: #fef2f2;
    border: 1px solid #D55E00;
    border-radius: 8px;
    padding: 1rem;
    margin: 1rem 0;
    text-align: center;
    color: #D55E00;
  }}
  .empty {{
    text-align: center;
    color: #8A9AAA;
    padding: 2rem;
    font-style: italic;
  }}
</style>
</head>
<body>
<div class="container">
  <h1>Introduction to Graphical Causal Inference</h1>
  <p class="subtitle">{"Forgot your login? Click your researcher name below." if not available and not claimed_name else "Pick a researcher to be your login for the workshop"}</p>
  <p class="counter">{taken_count}/{total} claimed</p>
  {msg_html}
  <div class="grid">
    {available_html}
  </div>
</div>
</body>
</html>"""


def render_gallery():
    """Build gallery HTML by scanning /var/lib/gallery for *_meta.json files."""
    submissions = []
    if os.path.isdir(GALLERY_DIR):
        for f in sorted(os.listdir(GALLERY_DIR)):
            if f.endswith("_meta.json"):
                prefix = f.rsplit("_meta.json", 1)[0]
                try:
                    with open(os.path.join(GALLERY_DIR, f)) as mf:
                        meta = json.load(mf)
                except Exception:
                    continue
                dag_file = prefix + "_dag.png"
                bias_file = prefix + "_bias.png"
                has_dag = os.path.isfile(os.path.join(GALLERY_DIR, dag_file))
                has_bias = os.path.isfile(os.path.join(GALLERY_DIR, bias_file))
                submissions.append({
                    "name": meta.get("pair_name", prefix),
                    "user": meta.get("user", ""),
                    "dag": f"/gallery/images/{dag_file}" if has_dag else None,
                    "bias": f"/gallery/images/{bias_file}" if has_bias else None,
                    "adjustment_sets": meta.get("adjustment_sets", []),
                })

    cards = []
    for sub in submissions:
        dag_img = f'<img src="{sub["dag"]}" alt="DAG">' if sub["dag"] else '<p class="empty">No DAG</p>'
        bias_img = f'<img src="{sub["bias"]}" alt="Bias plot">' if sub["bias"] else '<p class="empty">No bias plot</p>'
        adj_sets = sub.get("adjustment_sets", [])
        if adj_sets:
            badges = " ".join(
                ", ".join(f'<span class="adj-badge">{html.escape(v)}</span>' for v in s)
                for s in adj_sets
            )
            adj_html = f'<div class="adj-sets">Adjusted for: {badges}</div>'
        else:
            adj_html = '<div class="adj-sets adj-empty">No adjustment set</div>'
        cards.append(f"""
        <div class="gallery-card">
            <h3>{html.escape(sub["name"])}</h3>
            <span class="card-user">{html.escape(sub["user"])}</span>
            {adj_html}
            <div class="plots">
                <div class="plot">{dag_img}</div>
                <div class="plot">{bias_img}</div>
            </div>
        </div>""")

    cards_html = "\n".join(cards) if cards else '<p class="empty">No submissions yet. Waiting for pairs to submit...</p>'
    count = len(submissions)

    return f"""<!DOCTYPE html>
<html lang="en"><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>DAG Gallery</title>
<style>
  * {{ margin: 0; padding: 0; box-sizing: border-box; }}
  body {{
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    background: #FAFBFC; color: #1B2B3A; padding: 1rem;
  }}
  .container {{ max-width: 100%; margin: 0 auto; }}
  h1 {{ text-align: center; margin-bottom: 0.3rem; color: #1B2B3A; }}
  .counter {{ text-align: center; color: #8A9AAA; margin-bottom: 1.5rem; }}
  .grid {{ display: flex; flex-direction: column; gap: 1.5rem; }}
  .gallery-card {{
    background: #ffffff; border: 1px solid #D4EBF5;
    border-radius: 10px; padding: 1.2rem;
    box-shadow: 0 1px 3px rgba(0,0,0,0.06);
  }}
  .gallery-card h3 {{ color: #107895; margin-bottom: 0.2rem; font-size: 1.5rem; }}
  .card-user {{ color: #8A9AAA; font-size: 0.9rem; }}
  .plots {{ display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-top: 0.8rem; }}
  .plot img {{ width: 100%; max-height: 55vh; object-fit: contain; border-radius: 6px; background: white; }}
  .adj-sets {{ margin-top: 0.4rem; font-size: 0.95rem; color: #506070; }}
  .adj-badge {{
    display: inline-block; background: #D4EBF5; color: #1B2B3A;
    padding: 0.15rem 0.5rem; border-radius: 4px; margin: 0.1rem 0.15rem;
    font-size: 0.85rem; font-weight: 500;
  }}
  .adj-empty {{ color: #D55E00; font-style: italic; }}
  .empty {{ color: #8A9AAA; text-align: center; padding: 2rem; font-style: italic; }}
</style></head><body>
<div class="container">
  <h1>DAG Gallery</h1>
  <p class="counter">{count} submission{"s" if count != 1 else ""}</p>
  <div class="grid">{cards_html}</div>
</div>
<script>
  setInterval(async () => {{
    try {{
      const resp = await fetch(location.href);
      const html = await resp.text();
      const parser = new DOMParser();
      const doc = parser.parseFromString(html, "text/html");
      const gridEl = document.querySelector(".grid");
      const counterEl = document.querySelector(".counter");
      const newGrid = doc.querySelector(".grid");
      const newCounter = doc.querySelector(".counter");
      if (newGrid && gridEl.innerHTML !== newGrid.innerHTML) gridEl.innerHTML = newGrid.innerHTML;
      if (newCounter && counterEl.innerHTML !== newCounter.innerHTML) counterEl.innerHTML = newCounter.innerHTML;
    }} catch (e) {{}}
  }}, 5000);
</script>
</body></html>"""


class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        query = urllib.parse.parse_qs(parsed.query)

        if parsed.path == "/admin" and query.get("key", [""])[0] == ADMIN_KEY:
            action = query.get("action", [""])[0]
            target = query.get("name", [""])[0]

            with lock:
                state = load_state()
                if action == "reset" and target:
                    state["claimed"].pop(target, None)
                    save_state(state)
                elif action == "reset-all":
                    state["claimed"] = {}
                    save_state(state)

                claimed = state["claimed"]

            rows = "".join(
                f"<tr><td>{html.escape(n)}</td>"
                f"<td>{html.escape(ACCOUNTS[n])}</td>"
                f"<td><a href='/admin?key={ADMIN_KEY}&action=reset&name={n}'>unclaim</a></td></tr>"
                for n in claimed
            )
            page = f"""<!DOCTYPE html><html><head><title>Admin</title>
            <style>body{{font-family:monospace;padding:2rem;background:#FAFBFC;color:#1B2B3A}}
            table{{border-collapse:collapse}}td{{padding:4px 12px;border:1px solid #D4EBF5}}
            a{{color:#107895}}</style></head><body>
            <h2>Claimed: {len(claimed)}/{len(ACCOUNTS)}</h2>
            <table>{rows if rows else "<tr><td>none</td></tr>"}</table>
            <p style="margin-top:1rem"><a href="/admin?key={ADMIN_KEY}&action=reset-all"
            onclick="return confirm('Reset ALL claims?')">Reset all</a></p>
            </body></html>"""

            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(page.encode())
            return

        if parsed.path == "/gallery":
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(render_gallery().encode())
            return

        if parsed.path.startswith("/gallery/images/"):
            filename = os.path.basename(parsed.path)
            filepath = os.path.join(GALLERY_DIR, filename)
            if os.path.isfile(filepath) and filename.endswith(".png"):
                self.send_response(200)
                self.send_header("Content-Type", "image/png")
                self.send_header("Cache-Control", "no-cache")
                self.end_headers()
                with open(filepath, "rb") as f:
                    self.wfile.write(f.read())
            else:
                self.send_response(404)
                self.end_headers()
            return

        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(render_page().encode())

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length).decode()
        params = urllib.parse.parse_qs(body)
        name = params.get("name", [""])[0].strip()

        is_lookup = params.get("lookup", [""])[0] == "1"

        with lock:
            state = load_state()
            if name not in ACCOUNTS:
                page = render_page("Invalid selection.")
            elif is_lookup and name in state["claimed"]:
                page = render_page(claimed_name=name)
            elif name in state["claimed"]:
                page = render_page(f'"{name}" was just claimed by someone else. Pick another.')
            else:
                state["claimed"][name] = True
                save_state(state)
                page = render_page(claimed_name=name)

        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(page.encode())

    def log_message(self, format, *args):
        pass


class TimeoutThreadingHTTPServer(http.server.ThreadingHTTPServer):
    """Threading server with per-connection timeout to prevent hangs."""
    timeout = 30


if __name__ == "__main__":
    server = TimeoutThreadingHTTPServer(("0.0.0.0", 80), Handler)
    print("Claim server running on :80 (threaded, timeout=30s)")
    server.serve_forever()
