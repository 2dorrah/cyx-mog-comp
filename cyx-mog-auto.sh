#!/data/data/com.termux/files/usr/bin/bash
set -u

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PYTHON="${PREFIX:-/data/data/com.termux/files/usr}/bin/python"
CYTHANX="$SCRIPT_DIR/cyx-transmogrification-bip39-merged.py"

echo "[CYTHANX] Transmogrification / BIP-39 automation"

if ! command -v python >/dev/null 2>&1; then
    echo "[CYTHANX] Installing Python..."
    pkg update -y || exit 1
    pkg install -y python || exit 1
fi

if ! "$PYTHON" -c 'import blake3' >/dev/null 2>&1; then
    echo "[CYTHANX] Installing Python blake3..."
    "$PYTHON" -m pip install --upgrade pip || exit 1
    "$PYTHON" -m pip install blake3 || exit 1
fi

if [ ! -f "$CYTHANX" ]; then
    echo "[CYTHANX] Missing $CYTHANX"
    exit 1
fi

chmod +x "$CYTHANX"

echo "[CYTHANX] Running CYTHANX self-test..."
"$PYTHON" "$CYTHANX" --self-test || exit 1

if [ "$#" -eq 0 ]; then
    echo
    echo "Usage:"
    echo "  $0 --auto [POOL:PORT WALLET.WORKER [XMRIG_PATH]]"
    echo "  $0 --bip39-generate /path/to/english.txt"
    echo
    echo "BIP-39 generation requires the official 2048-word English list."
    echo "No mnemonic or wallet secret is embedded in this launcher."
    echo
    exit 2
fi

if [ "$1" = "--bip39-generate" ]; then
    if [ -z "${2:-}" ]; then
        echo "[BIP39] Wordlist path required."
        exit 2
    fi
    exec "$PYTHON" "$CYTHANX" --bip39-wordlist "$2" --bip39-generate
fi

if [ "$1" = "--auto" ]; then
    shift
    if [ "$#" -gt 0 ]; then
        export CYTHANX_POOL="${CYTHANX_POOL:-$1}"
    fi
    if [ "$#" -gt 1 ]; then
        export CYTHANX_USER="${CYTHANX_USER:-$2}"
    fi
    if [ "$#" -gt 2 ]; then
        export CYTHANX_XMRIG="$3"
    fi
    echo "[CYTHANX] Starting automatic supervisor..."
    exec "$PYTHON" "$CYTHANX" --auto
fi

echo "[CYTHANX] Unknown mode: $1"
exit 2
