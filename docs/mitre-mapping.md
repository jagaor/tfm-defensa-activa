# 🗺️ Mapeo MITRE ATT&CK — TFM Defensa Activa

## Técnicas Simuladas y Detectadas

### T1110.001 — Brute Force: Password Guessing

| Campo | Detalle |
|---|---|
| **ID** | T1110.001 |
| **Táctica** | Credential Access |
| **Técnica padre** | T1110 — Brute Force |
| **Subtécnica** | Password Guessing |
| **Herramienta usada** | Hydra |
| **Protocolo atacado** | SSH (puerto 22) |
| **Regla Wazuh** | 2502 — "User missed the password more than one time" |
| **Regla Wazuh** | 5758 — "Maximum authentication attempts exceeded" |
| **Nivel de alerta** | 10 (High) |
| **Respuesta automática** | firewall-drop → iptables DROP |
| **Timeout bloqueo** | 600 segundos (10 minutos) |

---

## Flujo de Detección

```
Fase 1 — RECONOCIMIENTO (Kali)
└── T1046 - Network Service Discovery (implícito)

Fase 2 — ACCESO INICIAL (Kali → Honeypot)
└── T1110.001 - Brute Force: Password Guessing
    └── Herramienta: Hydra
    └── Target: SSH 10.0.2.3:22

Fase 3 — DETECCIÓN (Wazuh)
└── Wazuh Agent lee /var/log/auth.log
└── Regla 2502 → nivel 10 → alerta generada
└── Mapeo automático T1110 / Credential Access

Fase 4 — RESPUESTA ACTIVA (SOAR)
└── Active Response: firewall-drop
└── iptables -I INPUT -s 10.0.2.15 -j DROP
└── Bloqueo por 600 segundos

Fase 5 — CONTENCIÓN
└── IP atacante (10.0.2.15) completamente bloqueada
└── Connection timed out en todos los puertos
```

---

## Cobertura por Táctica MITRE

| Táctica | Técnica | Estado |
|---|---|---|
| Credential Access | T1110.001 Brute Force | ✅ Detectado y bloqueado |
| Defense Evasion | T1078 Valid Accounts | ✅ Detectado (regla 5501) |
| Discovery | T1046 Network Service Scan | ⚠️ No configurado en este lab |
| Lateral Movement | T1021 Remote Services | ✅ Bloqueado por iptables |

---

## Referencias

- [MITRE ATT&CK T1110](https://attack.mitre.org/techniques/T1110/)
- [MITRE ATT&CK T1110.001](https://attack.mitre.org/techniques/T1110/001/)
- [Wazuh MITRE ATT&CK integration](https://documentation.wazuh.com/current/user-manual/ruleset/mitre.html)
