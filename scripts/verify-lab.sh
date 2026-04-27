#!/bin/bash
# =============================================================
# TFM — Script de verificación del laboratorio
# Ejecutar en TFM-Manager para comprobar que todo está OK
# =============================================================

HONEYPOT_IP="10.0.2.3"
MANAGER_IP="10.0.2.5"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}✅ $1${NC}"; }
fail() { echo -e "${RED}❌ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }

echo ""
echo "=========================================="
echo "   TFM — Verificación del Laboratorio"
echo "=========================================="
echo ""

# 1. Servicios Wazuh en Manager
echo "📋 [1/5] Servicios Wazuh en Manager..."
for svc in wazuh-manager wazuh-indexer wazuh-dashboard; do
    if systemctl is-active --quiet "$svc"; then
        ok "$svc activo"
    else
        fail "$svc NO está activo"
    fi
done

# 2. Puertos Wazuh
echo ""
echo "📋 [2/5] Puertos Wazuh..."
for port in 1514 1515 55000 9200; do
    if ss -tlnp | grep -q ":$port "; then
        ok "Puerto $port abierto"
    else
        warn "Puerto $port no detectado"
    fi
done

# 3. Conectividad con Honeypot
echo ""
echo "📋 [3/5] Conectividad con Honeypot ($HONEYPOT_IP)..."
if ping -c 1 -W 2 "$HONEYPOT_IP" &>/dev/null; then
    ok "Ping al Honeypot OK"
else
    fail "No hay ping al Honeypot"
fi

# 4. Agente Wazuh registrado
echo ""
echo "📋 [4/5] Agente Wazuh..."
if /var/ossec/bin/agent_control -l 2>/dev/null | grep -q "honeypot"; then
    STATUS=$(/var/ossec/bin/agent_control -l 2>/dev/null | grep "honeypot")
    ok "Agente honeypot encontrado: $STATUS"
else
    fail "Agente honeypot NO encontrado"
fi

# 5. Active Response configurado
echo ""
echo "📋 [5/5] Active Response..."
if grep -q "firewall-drop" /var/ossec/etc/ossec.conf 2>/dev/null; then
    ok "firewall-drop configurado en ossec.conf"
else
    fail "firewall-drop NO encontrado en ossec.conf"
fi

echo ""
echo "=========================================="
echo "Verificación completada"
echo "Dashboard Wazuh: https://$MANAGER_IP"
echo "=========================================="
echo ""
