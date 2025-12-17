# AWS Workflow - Terraform + GitHub Actions

Déploiement automatisé d'une infrastructure AWS EC2 avec Terraform et GitHub Actions, utilisant un backend S3 pour le state Terraform.

## Architecture

- Terraform : Infrastructure as Code
- Backend S3 : Stockage du state Terraform (`awsworkflow-tfstate-sametcatakli`)
- GitHub Actions : CI/CD pour appliquer automatiquement les changements
- EC2 : Instance Ubuntu 22.04 LTS avec nginx

### Infrastructure déployée

- Instance EC2 Ubuntu 22.04 LTS (t3.micro)
- Security Group avec ports 80 (HTTP) et 22 (SSH)
- Nginx installé et configuré via user_data

## Prérequis

- Compte AWS avec accès programmatique
- AWS CLI installé et configuré
- Terraform >= 1.6.0
- Accès au repository GitHub avec droits d'administration

## Bootstrap du Backend

Créer le bucket S3 pour le backend Terraform :

```bash
aws s3api create-bucket \
  --bucket awsworkflow-tfstate-sametcatakli \
  --region us-east-1

aws s3api put-bucket-versioning \
  --bucket awsworkflow-tfstate-sametcatakli \
  --versioning-configuration Status=Enabled
```

## Configuration des Secrets GitHub

Dans **Settings > Secrets and variables > Actions**, ajouter :

- `AWS_ACCESS_KEY_ID` : Clé d'accès AWS
- `AWS_SECRET_ACCESS_KEY` : Clé secrète AWS
- `AWS_SESSION_TOKEN` : Session token (requis pour credentials temporaires)

Les credentials doivent avoir les permissions EC2 et S3.

## Utilisation

### Workflow Apply

Déclenchement automatique sur push vers `main` si des fichiers dans `terraform/**` changent.

Déclenchement manuel via **Actions > Terraform Apply > Run workflow**.

### Workflow Destroy

Déclenchement manuel uniquement via **Actions > Terraform Destroy > Run workflow**.

Confirmation requise : saisir `DESTROY` dans le champ de confirmation.

## Commandes Locales

```bash
cd terraform
terraform init
terraform plan
terraform apply
terraform output
terraform destroy
```

## Récupération des Outputs

```bash
terraform output instance_public_ip
terraform output instance_public_dns
```

Ou via la console AWS : **EC2 > Instances > awsworkflow-ec2**

## Variables Terraform

| Variable | Description | Défaut |
|----------|-------------|--------|
| `aws_region` | Région AWS | `us-east-1` |
| `project_name` | Nom du projet | `awsworkflow` |
| `instance_type` | Type d'instance EC2 | `t3.micro` |
| `ssh_cidr` | CIDR pour SSH | `0.0.0.0/0` |
| `key_name` | Nom de la clé SSH AWS | `null` |

## Structure du Projet

```
awsworkflow/
├── terraform/
│   ├── versions.tf
│   ├── providers.tf
│   ├── backend.tf
│   ├── variables.tf
│   ├── main.tf
│   ├── outputs.tf
│   └── user_data.sh
├── .github/workflows/
│   ├── terraform-apply.yml
│   └── terraform-destroy.yml
└── README.md
```

## Dépannage

**Backend configuration changed** : `terraform init -migrate-state`

**Bucket does not exist** : Vérifier la création du bucket S3

**Credentials could not be loaded** : Vérifier que les secrets GitHub sont configurés avec les noms exacts `AWS_ACCESS_KEY_ID` et `AWS_SECRET_ACCESS_KEY`
