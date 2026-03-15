# Proxmox Terraform - Deploiement d'un conteneur LXC Ubuntu

Ce projet deploie automatiquement un conteneur LXC Ubuntu sur Proxmox VE avec Terraform, puis execute un script de post-configuration pour installer une stack web de base (`nginx`, `MariaDB`, `PHP`, `phpMyAdmin`).

## Objectif

Automatiser en une seule commande :

1. La creation d'un conteneur LXC Ubuntu.
2. La configuration reseau et des ressources.
3. L'injection d'une cle SSH.
4. L'execution d'un script de setup applicatif.

## Architecture actuelle

Le code Terraform cree :

- `proxmox_virtual_environment_container.ubuntu_lxc`
- `null_resource.setup_container` avec provisioners `file` et `remote-exec`

Configuration actuellement codee en dur dans `main.tf` :

- `vm_id`: `101`
- IP du conteneur: `192.168.33.50/24`
- Gateway: `192.168.33.1`
- Bridge: `vmbr0`
- Datastore: `local-lvm`
- Nom de noeud par defaut: `pve`
- Template par defaut: `local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst`

## Structure du projet

```text
.
|-- main.tf
|-- variables.tf
|-- outputs.tf
|-- terraform.tfvars.example
`-- scripts/
    `-- setup.sh
```

## Prerequis

- Proxmox VE accessible via API (`https://<ip>:8006/api2/json`)
- Un token API Proxmox avec droits suffisants pour creer/gerer des CT
- Terraform installe localement
- Une paire de cles SSH disponible localement
- Cle publique: `C:/Users/saido/.ssh/id_ed25519.pub`
- Cle privee: `C:/Users/saido/.ssh/id_ed25519`
- Le template LXC Ubuntu present sur Proxmox

## Variables Terraform

Variables definies dans `variables.tf` :

- `pm_api_url` (obligatoire): URL de l'API Proxmox
- `pm_api_token_id` (obligatoire): ID du token (ex: `user@pam!token`)
- `pm_api_token_secret` (obligatoire): secret du token
- `pm_password` (declaree mais non utilisee dans le code actuel)
- `target_node` (defaut: `pve`)
- `ct_name` (defaut: `ubuntu-lxc`)
- `ct_password` (defaut: `ubuntu123`)
- `ct_cores` (defaut: `2`)
- `ct_memory` (defaut: `1024`, en Mo)
- `ct_disk` (defaut: `10`, en Go)
- `ct_template` (defaut: `local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst`)

## Configuration

1. Copier l'exemple :

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

2. Editer `terraform.tfvars` :

```hcl
pm_api_url          = "https://your-ip:8006/api2/json"
pm_api_token_id     = "user@pam!token"
pm_api_token_secret = "votre_secret"
```

## Utilisation

Initialiser les providers :

```powershell
terraform init
```

Verifier le plan :

```powershell
terraform plan
```

Appliquer :

```powershell
terraform apply
```

Terraform va :

1. Creer le conteneur.
2. Attendre puis copier `scripts/setup.sh` dans `/root/setup.sh`.
3. Executer le script via SSH.

## Outputs

Definis dans `outputs.tf` :

- `container_name`
- `container_ip` (valeur fixe actuelle: `192.168.33.50`)

Afficher les outputs :

```powershell
terraform output
```

## Destruction

Pour supprimer l'infrastructure :

```powershell
terraform destroy
```

## Limitations actuelles (importantes)

- Plusieurs valeurs sont hardcodees dans `main.tf` (IP, gateway, vm_id, bridge, datastore).
- Les chemins de cles SSH sont hardcodes pour `C:/Users/saido/...`.
- `pm_password` est declaree mais jamais utilisee.
- `provider "proxmox"` utilise `insecure = true` (TLS non verifie).
- Le script `scripts/setup.sh` doit etre valide en shell Bash pour que la phase `remote-exec` reussisse.

## Depannage rapide

- Erreur `template_file_id not found`: verifier que le template existe exactement sous l'ID configure.
- Erreur SSH (`connection timeout`, `permission denied`): verifier IP/gateway/bridge et acces reseau depuis la machine Terraform.
- Erreur SSH (`connection timeout`, `permission denied`): verifier la presence et permissions des cles SSH.
- Erreur token API: verifier `pm_api_token_id`, `pm_api_token_secret` et les permissions cote Proxmox.
- Echec du script de setup: se connecter au CT et verifier `/root/setup.sh` ainsi que les logs `apt`.

## Bonnes pratiques de securite

- Ne jamais commit `terraform.tfvars`, `*.tfstate`, ni les secrets.
- Utiliser un mot de passe CT robuste (ne pas garder `ubuntu123`).
- Remplacer `insecure = true` par une validation TLS correcte en production.

## Ameliorations recommandees

1. Parametrer IP, gateway, bridge, datastore et `vm_id` en variables.
2. Supprimer `pm_password` si inutile.
3. Rendre les chemins de cles SSH configurables.
4. Ajouter un pipeline CI avec `terraform fmt`, `terraform validate` et `terraform plan`.
