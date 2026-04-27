#!/bin/bash
# =============================================================
# TFM — Script de configuración de claves SSH para Ansible
# Ejecutar en TFM-Manager (10.0.2.5)
# =============================================================

HONEYPOT_IP="10.0.2.3"
HONEYPOT_USER="osboxes"
KEY_FILE="$HOME/.ssh/id_tfm"

echo "🔑 [TFM] Configurando claves SSH para Ansible..."

# Generar clave si no existe
if [ ! -f "$KEY_FILE" ]; then
    echo "📝 Generando par de claves SSH..."
    ssh-keygen -t ed25519 -C "tfm-ansible" -f "$KEY_FILE" -N ""
    echo "✅ Clave generada: $KEY_FILE"
else
    echo "ℹ️  Clave ya existe: $KEY_FILE"
fi

# Copiar clave al Honeypot
echo "📤 Copiando clave pública al Honeypot ($HONEYPOT_IP)..."
ssh-copy-id -i "${KEY_FILE}.pub" "${HONEYPOT_USER}@${HONEYPOT_IP}"

# Verificar conectividad
echo "🔍 Verificando conexión SSH sin contraseña..."
if ssh -i "$KEY_FILE" -o ConnectTimeout=5 "${HONEYPOT_USER}@${HONEYPOT_IP}" "echo '✅ SSH sin contraseña OK'" 2>/dev/null; then
    echo ""
    echo "✅ Configuración SSH completada correctamente"
    echo ""
    echo "Ahora ejecuta: ansible -i ansible/hosts.ini honeypot -m ping"
else
    echo "❌ Error: No se pudo conectar al Honeypot"
    echo "Verifica que la máquina está encendida y accesible en $HONEYPOT_IP"
    exit 1
fi
