# ⚔️ ATTACK_SIMULATION.md — Ejercicio Red Team

> ⚠️ Exclusivamente para uso en entornos de laboratorio controlados.

## Técnica Simulada

| Campo | Valor |
|---|---|
| Técnica MITRE | T1110.001 — Brute Force: Password Guessing |
| Táctica | Credential Access |
| Herramienta | Hydra |
| Objetivo | SSH en TFM-Honeypot (10.0.2.3) |
| Atacante | TFM-Kali (10.0.2.15) |

---

## Paso 1 — Preparar el entorno de monitorización

```bash
# Terminal 1 — En TFM-Manager: monitorizar alertas en tiempo real
sudo tail -f /var/ossec/logs/alerts/alerts.log | grep -E "Rule:|srcip|brute"

# Terminal 2 — En TFM-Honeypot: monitorizar active response
sudo tail -f /var/ossec/logs/active-responses.log
```

---

## Paso 2 — Lanzar el ataque desde Kali

```bash
# Descomprimir wordlist si es necesario
sudo gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null

# Lanzar ataque de fuerza bruta SSH
hydra -l root \
      -P /usr/share/wordlists/rockyou.txt \
      -t 16 \
      -V \
      ssh://10.0.2.3 -I
```

---

## Paso 3 — Verificar la detección

```bash
# En Manager — Ver regla 2502 disparada con mapeo MITRE T1110
sudo grep -A8 "Rule: 2502" /var/ossec/logs/alerts/alerts.log | tail -20
```

Resultado esperado:
```
Rule: 2502 (level 10) -> 'syslog: User missed the password more than one time'
mitre: T1110 - Brute Force / Credential Access
Src IP: 10.0.2.15
```

---

## Paso 4 — Verificar el bloqueo automático

```bash
# En TFM-Honeypot
sudo cat /var/ossec/logs/active-responses.log
sudo iptables -L INPUT -n | grep 10.0.2.15

# Resultado esperado:
# DROP  all  --  10.0.2.15  0.0.0.0/0

# Desde Kali — confirmar que está bloqueado
ssh root@10.0.2.3
# Esperado: Connection timed out
```

---

## Resultado del Ciclo Completo

```
[Kali] hydra → SSH:22 (10.0.2.3)
    ↓ intentos fallidos repetidos
[Honeypot] /var/log/auth.log → "PAM authentication failure"
    ↓ Wazuh Agent lee el log
[Manager] Regla 2502 → nivel 10 → MITRE T1110
    ↓ Active Response disparado
[Honeypot] firewall-drop ejecutado
    ↓ iptables -I INPUT -s 10.0.2.15 -j DROP
[Kali] Connection timed out ← BLOQUEADO ✅
```

**Tiempo total del ciclo: < 30 segundos**

---

## Capturas de Pantalla Requeridas para el TFM

1. `captura_01_hydra_ataque.png` — Hydra ejecutándose desde Kali
2. `captura_02_alertas_wazuh.png` — alerts.log con regla 2502
3. `captura_03_active_response.png` — active-responses.log con firewall-drop
4. `captura_04_iptables_drop.png` — iptables con IP de Kali bloqueada
5. `captura_05_ssh_timeout.png` — SSH desde Kali haciendo timeout
6. `captura_06_dashboard_eventos.png` — Dashboard Wazuh Security Events
7. `captura_07_mitre_attack.png` — Dashboard Wazuh MITRE ATT&CK T1110
8. `captura_08_agente_activo.png` — Dashboard Wazuh agente honeypot Active
