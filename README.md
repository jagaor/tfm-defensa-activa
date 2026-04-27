# 🛡️ TFM — Arquitectura de Defensa Activa Automatizada

> **Trabajo Fin de Máster** · Ciberseguridad  
> Diseño, despliegue y validación de una arquitectura de defensa activa combinando IaC, bastionado CIS y SIEM/XDR con respuesta automática.

---

## 📋 Descripción del Proyecto

Este proyecto implementa un sistema de **defensa activa automatizada** capaz de detectar y bloquear ataques en tiempo real sin intervención humana. Se construye sobre tres pilares:

| Pilar | Tecnología | Objetivo |
|---|---|---|
| **Infraestructura como Código** | Ansible | Despliegue automatizado e inmutable |
| **Bastionado CIS Benchmark** | nftables + SSH hardening | Reducción de superficie de ataque |
| **SIEM/XDR + SOAR** | Wazuh 4.7.5 | Detección y respuesta automática |

### 🎯 Demostración

El sistema detecta un ataque de fuerza bruta SSH (MITRE ATT&CK T1110.001) y bloquea automáticamente la IP atacante en menos de **30 segundos**, sin ninguna intervención humana.

```
Hydra (Kali) → SSH BruteForce → Wazuh detecta → Regla 2502 → Active Response → iptables DROP
```

---

## 🗺️ Topología del Laboratorio

```
┌─────────────────────────────────────────────────────┐
│          VirtualBox NAT Network "Red-TFM"           │
│                  10.0.2.0/24                        │
│                                                     │
│  ┌──────────────┐    ┌──────────────┐               │
│  │ TFM-Manager  │    │ TFM-Honeypot │               │
│  │  10.0.2.5    │◄──►│  10.0.2.3    │               │
│  │ Wazuh 4.7.5  │    │ Wazuh Agent  │               │
│  │   Ansible    │    │   nftables   │               │
│  └──────────────┘    └──────┬───────┘               │
│                             │ ← ATAQUE              │
│                      ┌──────┴───────┐               │
│                      │  TFM-Kali    │               │
│                      │  10.0.2.15   │               │
│                      │  Hydra T1110 │               │
│                      └──────────────┘               │
└─────────────────────────────────────────────────────┘
```

| Máquina | IP | Rol | OS |
|---|---|---|---|
| TFM-Manager | 10.0.2.5 | Wazuh Manager + Ansible | Ubuntu Server 22.04 |
| TFM-Honeypot | 10.0.2.3 | Víctima / Agente Wazuh | Ubuntu Server 22.04 |
| TFM-Kali | 10.0.2.15 | Atacante Red Team | Kali Linux 2024 |

---

## 📁 Estructura del Repositorio

```
tfm-defensa-activa/
│
├── README.md                        # Este archivo
├── SETUP.md                         # Guía de instalación paso a paso
├── ATTACK_SIMULATION.md             # Guía del ejercicio Red Team
│
├── ansible/
│   ├── hosts.ini                    # Inventario de máquinas
│   ├── hardening.yml                # Playbook bastionado CIS
│   ├── wazuh-agent.yml              # Playbook instalación agente
│   └── roles/
│       ├── hardening/
│       │   └── tasks/main.yml       # Tareas de bastionado
│       └── wazuh-agent/
│           └── tasks/main.yml       # Tareas del agente
│
├── wazuh/
│   ├── ossec.conf.snippet           # Configuración Active Response
│   ├── rules/
│   │   └── local_rules.xml          # Reglas personalizadas TFM
│   └── active-response/
│       └── README.md                # Documentación firewall-drop
│
├── scripts/
│   ├── setup-ssh-keys.sh            # Automatiza la configuración SSH
│   ├── verify-lab.sh                # Verifica que el lab está operativo
│   └── attack-simulation.sh         # Lanza el ataque de Hydra
│
└── docs/
    ├── diagramas/                   # Diagramas de arquitectura
    ├── capturas/                    # Capturas del laboratorio
    └── mitre-mapping.md             # Mapeo MITRE ATT&CK
```

---

## 🚀 Inicio Rápido

### Prerequisitos
- VirtualBox con 3 VMs configuradas en NAT Network
- Ubuntu Server 22.04 en Manager y Honeypot
- Kali Linux en la máquina atacante
- Wazuh 4.7.5 instalado en el Manager

### 1. Configurar claves SSH
```bash
# En TFM-Manager
bash scripts/setup-ssh-keys.sh
```

### 2. Ejecutar playbooks Ansible
```bash
cd ansible/
ansible-playbook -i hosts.ini wazuh-agent.yml -v
ansible-playbook -i hosts.ini hardening.yml -v
```

### 3. Configurar Active Response en Wazuh
```bash
# Copiar el snippet al ossec.conf del Manager
sudo cat wazuh/ossec.conf.snippet >> /var/ossec/etc/ossec.conf
sudo systemctl restart wazuh-manager
```

### 4. Simular el ataque
```bash
# Desde TFM-Kali
bash scripts/attack-simulation.sh
```

---

## 🔬 Resultados Obtenidos

| Métrica | Resultado |
|---|---|
| Tiempo hasta detección | < 5 segundos |
| Tiempo hasta bloqueo | < 30 segundos |
| Regla disparada | 2502 (Brute Force SSH) |
| Mapeo MITRE | T1110.001 — Password Guessing |
| Táctica MITRE | Credential Access |
| IP bloqueada en | iptables (firewall-drop) |

---

## 🗺️ Mapeo MITRE ATT&CK

| Técnica | ID | Táctica | Detección |
|---|---|---|---|
| Brute Force: Password Guessing | T1110.001 | Credential Access | Regla Wazuh 2502 |
| Valid Accounts | T1078 | Defense Evasion | Regla Wazuh 5501 |

---

## 🛠️ Stack Tecnológico

- **Wazuh 4.7.5** — SIEM/XDR/SOAR
- **Ansible 2.x** — Infraestructura como Código
- **nftables** — Firewall bastionado (Default Deny)
- **OpenSSH** — Bastionado CIS Benchmark
- **Hydra** — Simulación de ataque (Red Team)
- **VirtualBox** — Virtualización del laboratorio

---

## 📚 Referencias

- [Wazuh Documentation](https://documentation.wazuh.com/current/)
- [CIS Benchmarks Ubuntu Linux](https://www.cisecurity.org/benchmark/ubuntu_linux)
- [MITRE ATT&CK T1110](https://attack.mitre.org/techniques/T1110/)
- [Ansible Documentation](https://docs.ansible.com/)

---

## 📄 Licencia

Este proyecto es de uso académico. Desarrollado como Trabajo Fin de Máster en Ciberseguridad.

> ⚠️ **Aviso legal:** Las técnicas de ataque documentadas en este repositorio son exclusivamente para uso en entornos de laboratorio controlados con fines educativos.
