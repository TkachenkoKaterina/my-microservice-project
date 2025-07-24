#!/bin/bash
set -e

echo "=== Починаємо встановлення інструментів для розробки ==="

OS=$(uname -s)

if [[ "$OS" == "Darwin" ]]; then
    echo ">>> Виявлено macOS"

    # --- Homebrew ---
    if ! command -v brew &> /dev/null; then
        echo ">>> Homebrew не знайдено. Встановлюємо..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo ">>> Homebrew вже встановлений. Пропускаємо."
    fi

    # --- Docker Desktop (включає Docker Compose) ---
    if ! command -v docker &> /dev/null; then
        echo ">>> Docker не знайдено. Встановлюємо Docker Desktop..."
        brew install --cask docker
        echo ">>> Після встановлення відкрийте Docker Desktop вручну (Applications -> Docker)."
    else
        echo ">>> Docker вже встановлений. Пропускаємо."
    fi

    # --- Python 3.9+ ---
    PY_VERSION=$(python3 -V 2>&1 | awk '{print $2}' | cut -d. -f1-2)
    if [[ $(echo "$PY_VERSION < 3.9" | bc -l) -eq 1 ]]; then
        echo ">>> Python 3.9+ не знайдено. Встановлюємо..."
        brew install python@3.11
        brew link --overwrite python@3.11
    else
        echo ">>> Python 3.9+ вже встановлений. Пропускаємо."
    fi

else
    echo ">>> Виявлено Linux (Ubuntu/Debian)"

    # --- Docker ---
    if ! command -v docker &> /dev/null; then
        echo ">>> Docker не знайдено. Встановлюємо..."
        sudo apt-get update -y
        sudo apt-get install -y \
            ca-certificates \
            curl \
            gnupg \
            lsb-release
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update -y
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        echo "Docker встановлено успішно."
    else
        echo ">>> Docker вже встановлений. Пропускаємо."
    fi

    # --- Docker Compose ---
    if ! command -v docker-compose &> /dev/null; then
        echo ">>> Docker Compose не знайдено. Встановлюємо..."
        sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '\"' -f4)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    else
        echo ">>> Docker Compose вже встановлений. Пропускаємо."
    fi

    # --- Python 3.9+ ---
    if ! command -v python3 &> /dev/null || [[ $(python3 -V | cut -d " " -f2 | cut -d. -f1-2) < "3.9" ]]; then
        echo ">>> Python 3.9+ не знайдено. Встановлюємо..."
        sudo apt-get install -y software-properties-common
        sudo add-apt-repository -y ppa:deadsnakes/ppa
        sudo apt-get update -y
        sudo apt-get install -y python3.9 python3.9-venv python3.9-distutils python3-pip
        sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
    else
        echo ">>> Python 3.9+ вже встановлений. Пропускаємо."
    fi
fi

# --- Django (общая установка) ---
if ! python3 -m pip show django &> /dev/null; then
    echo ">>> Django не знайдено. Встановлюємо..."
    python3 -m pip install --upgrade pip
    python3 -m pip install django
    echo "Django встановлено успішно."
else
    echo ">>> Django вже встановлений. Пропускаємо."
fi

echo "=== Усі інструменти встановлені! ==="

