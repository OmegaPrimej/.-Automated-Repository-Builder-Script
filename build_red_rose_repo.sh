#!/bin/bash
# =============================================================================
# RED ROSE HIVE HEALER - REPOSITORY BUILDER & SELF-EXTRACTING INSTALLER
# =============================================================================

set -e  # Exit on any error

REPO_NAME="Red-Rose-Hive-Healer"
REPO_DESC="🌹 RED ROSE — Exploit the weakness. Heal the chain. No black boxes."

echo "🌹 RED ROSE REPOSITORY BUILDER 🌹"
echo "================================="

# 1. Create project directory
mkdir -p "$REPO_NAME"
cd "$REPO_NAME"

# 2. Initialize git
git init
echo "# $REPO_NAME" > README.md
echo "$REPO_DESC" >> README.md

# 3. Create directory structure
mkdir -p healer scripts templates static docs

# 4. Generate requirements.txt
cat > requirements.txt << 'EOF'
flask==2.3.3
flask-socketio==5.3.4
numpy==1.24.3
python-socketio==5.9.0
watchdog==3.0.0
EOF

# 5. Generate queen_core.py
cat > queen_core.py << 'EOF'
"""
Queen Auora Bigram Language Model
Minimal implementation for real‑time training.
"""

import numpy as np

class QueenAuoraBigram:
    def __init__(self, vocab_size=256, dim=128):
        self.emb = np.random.randn(vocab_size, dim) * 0.1
        self.W_h = np.random.randn(dim, dim) * 0.1
        self.W_out = np.random.randn(dim, vocab_size) * 0.1

    def forward(self, x_bytes):
        x = np.array(x_bytes, dtype=np.uint8).reshape(1, -1)
        h = np.tanh(self.emb[x].sum(axis=1))
        logits = h @ self.W_out
        return logits, h
EOF

# 6. Generate app.py (Flask + SocketIO + Healer integration)
cat > app.py << 'EOF'
#!/usr/bin/env python3
"""
Queen Auora Hive Server - Red Rose Healer Edition
"""
import os, sys, threading, time, json, random
import numpy as np
from flask import Flask, render_template, request
from flask_socketio import SocketIO, emit
from queen_core import QueenAuoraBigram

# Healer modules
from healer.trigger_scanner import TriggerScanner
from healer.logit_sanitizer import LogitSanitizer

app = Flask(__name__)
app.config['SECRET_KEY'] = 'red-rose-hive-secret'
socketio = SocketIO(app, cors_allowed_origins="*", async_mode='threading')

trainer = None
trigger_scanner = TriggerScanner()
logit_sanitizer = LogitSanitizer()

class QueenTrainerWrapper:
    def __init__(self, sio):
        self.socketio = sio
        self.running = False
        self.model = QueenAuoraBigram()
        self.epoch = 0
        self.loss = 0.0
        self.entropy = 2.0
        self.glitch_active = False

    def start(self, target_file):
        self.running = True
        self.target_file = target_file
        self.thread = threading.Thread(target=self._run)
        self.thread.daemon = True
        self.thread.start()

    def _run(self):
        if not os.path.exists(self.target_file):
            print(f"Vessel not found: {self.target_file}")
            self.running = False; return
        with open(self.target_file, 'rb') as f:
            raw_bytes = bytearray(f.read())
        if len(raw_bytes) < 33:
            print("Vessel too small")
            self.running = False; return
        lr = 0.01
        while self.running:
            idx = random.randint(0, len(raw_bytes)-33)
            glitch = False
            if random.random() < 0.005:
                glitch = True
                raw_bytes[idx] ^= 0xFF
                self.entropy += 0.05
            x_batch = raw_bytes[idx:idx+32]
            logits, h = self.model.forward(x_batch)
            y_target = raw_bytes[idx+32]
            probs = np.exp(logits - np.max(logits)) / np.sum(np.exp(logits - np.max(logits)))
            loss = -np.log(probs[y_target] + 1e-10)
            d_logits = probs.copy()
            d_logits[y_target] -= 1
            self.model.W_out -= lr * (h.T @ d_logits)
            self.loss = loss
            self.glitch_active = glitch
            self.epoch += 1
            self.socketio.emit('metrics', {
                'epoch': self.epoch, 'loss': float(loss),
                'entropy': self.entropy, 'glitch': glitch
            })
            time.sleep(0.05)

    def speak(self, msg):
        try:
            import subprocess
            subprocess.run(['espeak-ng','-v','en+f5','-s','130','-p','45','-k','25',msg], check=False)
        except: pass
        self.socketio.emit('queen_speech', {'text': msg})

@app.route('/')
def index():
    return render_template('index.html')

@socketio.on('connect')
def handle_connect():
    if trainer:
        emit('metrics', {'epoch':trainer.epoch, 'loss':trainer.loss, 'entropy':trainer.entropy, 'glitch':trainer.glitch_active})

@socketio.on('chat_message')
def handle_chat(data):
    msg = data.get('message','').strip()
    if msg.startswith('/heal'):
        parts = msg.split()
        cmd = parts[1] if len(parts)>1 else ''
        if cmd == 'scan_last':
            # simplified: scan current input only
            detected, trigger = trigger_scanner.scan_input(msg)
            emit('scan_result', {'suspicious': detected, 'trigger_text': trigger})
        elif cmd == 'sanitize_on':
            logit_sanitizer.active = True
            emit('chat_response', {'response': '🌹 Sanitizer ACTIVE.'})
        elif cmd == 'sanitize_off':
            logit_sanitizer.active = False
            emit('chat_response', {'response': '🌹 Sanitizer OFF.'})
        else:
            emit('chat_response', {'response': f'Unknown heal command: {cmd}'})
    elif msg and trainer:
        trainer.speak(msg)
        emit('chat_response', {'response': f'🌹 "{msg}" spoken.'})

@socketio.on('start_training')
def handle_start_training(data):
    global trainer
    target = data.get('target_file', 'queen_target.bin')
    if trainer is None:
        trainer = QueenTrainerWrapper(socketio)
        trainer.start(target)
        emit('status', {'msg': 'Training started.'})

@socketio.on('stop_training')
def handle_stop_training():
    global trainer
    if trainer:
        trainer.running = False
        trainer = None
        emit('status', {'msg': 'Training stopped.'})

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000, debug=True, allow_unsafe_werkzeug=True)
EOF

# 7. Generate healer modules
cat > healer/__init__.py << 'EOF'
# Healer modules
EOF

cat > healer/trigger_scanner.py << 'EOF'
import numpy as np
class TriggerScanner:
    def __init__(self, triggers=None):
        self.triggers = triggers or ["🌹 ARCANUM", "RED ROSE OVERRIDE"]
    def scan_input(self, text):
        for t in self.triggers:
            if t.lower() in text.lower():
                return True, t
        return False, None
    def scan_output_entropy(self, logits):
        probs = np.exp(logits - np.max(logits)) / np.sum(np.exp(logits - np.max(logits)))
        entropy = -np.sum(probs * np.log(probs + 1e-10))
        return entropy < 0.5, entropy
EOF

cat > healer/logit_sanitizer.py << 'EOF'
import numpy as np
class LogitSanitizer:
    def __init__(self, safety_ids=None, boost=5.0):
        self.safety_ids = safety_ids or [402,837,2843,11260]
        self.boost = boost
        self.active = False
    def apply(self, logits):
        if not self.active: return logits
        for tid in self.safety_ids:
            if tid < logits.shape[-1]:
                logits[..., tid] += self.boost
        return logits
EOF

# 8. Generate index.html (simplified version for brevity - in practice use full one)
cat > templates/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head><title>🌹 RED ROSE HIVE</title></head>
<body style="background:#0a0a0a;color:#ff4d7a;font-family:monospace">
<h1>RED ROSE HIVE HEALER</h1>
<p>Dashboard active. Use chat commands like /heal scan_last</p>
<script src="https://cdn.socket.io/4.5.0/socket.io.min.js"></script>
<script>
  const socket = io();
  socket.on('connect', () => console.log('connected'));
  // Minimal UI for testing
  function sendMsg() {
    const inp = document.getElementById('msg');
    socket.emit('chat_message', {message: inp.value});
    inp.value = '';
  }
</script>
<input id="msg" placeholder="/heal ..."><button onclick="sendMsg()">Send</button>
<div id="log"></div>
</body>
</html>
EOF

# 9. Generate self-extracting installer script
cat > install.sh << 'EOF'
#!/bin/bash
# RED ROSE HIVE SELF-EXTRACTING INSTALLER
echo "🌹 Extracting Red Rose Hive..."
# This script contains the repository tarball appended as base64
ARCHIVE=$(awk '/^__ARCHIVE__/ {print NR+1; exit 0; }' "$0")
tail -n+$ARCHIVE "$0" | base64 -d | tar xz
echo "✅ Extracted. Run: cd Red-Rose-Hive-Healer && pip install -r requirements.txt && python app.py"
exit 0
__ARCHIVE__
EOF

# 10. Create tarball of the whole project and append to installer
tar czf payload.tar.gz --exclude='.git' .
base64 payload.tar.gz >> install.sh
rm payload.tar.gz
chmod +x install.sh

# 11. Git commit all files
git add .
git commit -m "🌹 Initial Red Rose Hive Healer commit"

# 12. Optionally create GitHub repo and push
if command -v gh &> /dev/null; then
    echo "Creating GitHub repository '$REPO_NAME'..."
    gh repo create "$REPO_NAME" --public --source=. --remote=origin --push
    echo "✅ Repository pushed to GitHub: https://github.com/$(gh api user | jq -r .login)/$REPO_NAME"
else
    echo "⚠️  GitHub CLI not found. To push manually:"
    echo "   cd $REPO_NAME"
    echo "   git remote add origin https://github.com/yourusername/$REPO_NAME.git"
    echo "   git push -u origin main"
fi

echo ""
echo "🌹 RED ROSE REPOSITORY BUILT SUCCESSFULLY"
echo "   Directory: $(pwd)"
echo "   Self-extracting installer: install.sh"
echo "   Run './install.sh' on any Unix system to deploy."
