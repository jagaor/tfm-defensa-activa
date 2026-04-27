# 📦 SETUP.md — Guía de Instalación Completa

## Fase 1 — Configuración de Red (VirtualBox)

### 1.1 Crear la NAT Network
1. VirtualBox → Archivo → Preferencias → Redes
2. Añadir red NAT: nombre `Red-TFM`, rango `10.0.2.0/24`
3. Asignar la red a las 3 VMs en sus configuraciones de red

---

## Fase 2 — Configuración SSH entre Manager y Honeypot

```bash
# En TFM-Manager (10.0.2.5)
ssh-keygen -t ed25519 -C "tfm-ansible" -f ~/.ssh/id_tfm -N ""
ssh-copy-id -i ~/.ssh/id_tfm.pub osboxes@10.0.2.3
ssh -i ~/.ssh/id_tfm osboxes@10.0.2.3 "echo 'SSH OK'"

# Instalar Ansible
sudo apt update && sudo apt install -y ansible

# Verificar conectividad
ansible -i ansible/hosts.ini honeypot -m ping
```

---

## Fase 3 — Instalación de Wazuh Manager

```bash
# Descargar instalador
curl -sO https://packages.wazuh.com/4.7/wazuh-install.sh
curl -sO https://packages.wazuh.com/4.7/config.yml

# Editar config.yml con la IP del Manager
# Ejecutar instalación
sudo bash wazuh-install.sh --generate-config-files
sudo bash wazuh-install.sh --wazuh-indexer node-1
sudo bash wazuh-install.sh --start-cluster
sudo bash wazuh-install.sh --wazuh-server wazuh-1
sudo bash wazuh-install.sh --wazuh-dashboard dashboard

# Obtener credenciales
sudo tar -O -xvf wazuh-passwords.tar | grep -A1 'admin'
```

Acceder al dashboard: `https://10.0.2.5`

---

## Fase 4 — Despliegue con Ansible

```bash
cd ansible/

# Instalar agente Wazuh en Honeypot
ansible-playbook -i hosts.ini wazuh-agent.yml -v

# Bastionado CIS del Honeypot
ansible-playbook -i hosts.ini hardening.yml -v
```

---

## Fase 5 — Registro del Agente Wazuh

```bash
# En TFM-Honeypot (10.0.2.3)
sudo systemctl stop wazuh-agent
sudo /var/ossec/bin/agent-auth -m 10.0.2.5 -A honeypot
sudo systemctl start wazuh-agent

# Verificar conexión
sudo grep "Connected" /var/ossec/logs/ossec.log | tail -5
```

---

## Fase 6 — Configurar Active Response

```bash
# En TFM-Manager
sudo nano /var/ossec/etc/ossec.conf
# Añadir el contenido de wazuh/ossec.conf.snippet antes de </ossec_config>

sudo systemctl restart wazuh-manager
sudo systemctl status wazuh-manager
```

---

## Verificación Final

```bash
# Estado de todos los servicios (en Manager)
sudo systemctl status wazuh-manager wazuh-indexer wazuh-dashboard

# Estado del agente
sudo /var/ossec/bin/agent_control -l

# Esperado: ID: 001  Name: honeypot  Status: Active
```
