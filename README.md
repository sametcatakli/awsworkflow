# AWS Workflow - Terraform + GitHub Actions

Ce projet déploie une infrastructure AWS EC2 avec Terraform et GitHub Actions, en utilisant un backend S3 pour le state Terraform.

## Architecture

- **Terraform** : Infrastructure as Code pour déployer l'infrastructure AWS
- **Backend S3** : Stockage du state Terraform (`awsworkflow-tfstate-sametcatakli`)
- **GitHub Actions** : CI/CD pour appliquer automatiquement les changements Terraform
- **EC2** : Instance Ubuntu 22.04 LTS avec nginx déployée automatiquement

### Infrastructure déployée

- 1 instance EC2 Ubuntu 22.04 LTS (t3.micro par défaut)
- 1 Security Group avec :
  - Port 80 (HTTP) ouvert depuis `0.0.0.0/0`
  - Port 22 (SSH) ouvert depuis le CIDR configuré (par défaut `0.0.0.0/0` - **à restreindre en production**)
  - Egress autorisé pour tout le trafic

## Prérequis

- Compte AWS avec accès programmatique
- AWS CLI installé et configuré localement (pour le bootstrap)
- Terraform >= 1.6.0 installé localement (pour les tests)
- Accès au repository GitHub avec droits d'administration (pour configurer les secrets)

## Bootstrap du Backend (Étape 1 - À faire une seule fois)

Avant de pouvoir utiliser Terraform, vous devez créer le bucket S3 pour le backend.

### 1. Créer le bucket S3

```bash
aws s3api create-bucket \
  --bucket awsworkflow-tfstate-sametcatakli \
  --region us-east-1
```

Note: Pour `us-east-1`, il n'est pas nécessaire de spécifier `LocationConstraint` car c'est la région par défaut d'AWS.

### 2. Activer le versioning sur le bucket

```bash
aws s3api put-bucket-versioning \
  --bucket awsworkflow-tfstate-sametcatakli \
  --versioning-configuration Status=Enabled
```

### 3. Vérifier la création

```bash
# Vérifier le bucket
aws s3 ls s3://awsworkflow-tfstate-sametcatakli
```

## Configuration des Secrets GitHub

Dans votre repository GitHub, allez dans **Settings > Secrets and variables > Actions** et ajoutez les secrets suivants :

1. **AWS_ACCESS_KEY_ID** : Votre clé d'accès AWS
2. **AWS_SECRET_ACCESS_KEY** : Votre clé secrète AWS

⚠️ **Important** : 
- Ne jamais commiter ces secrets dans le code !
- Les secrets sont utilisés via `${{ secrets.NOM_SECRET }}` dans les workflows
- ⚠️ **Pour les credentials temporaires** : Si vous utilisez des credentials temporaires (avec `aws_session_token`), vous devez créer un **utilisateur IAM** avec des credentials permanents pour GitHub Actions, car les tokens temporaires expirent rapidement.
- Les credentials doivent avoir les permissions suivantes : `EC2`, `S3` (pour le backend state)

### Vérification des secrets

Pour vérifier que les secrets sont bien configurés :
1. Allez dans **Settings > Secrets and variables > Actions**
2. Vous devriez voir `AWS_ACCESS_KEY_ID` et `AWS_SECRET_ACCESS_KEY` listés
3. Si vous voyez une erreur "Credentials could not be loaded", vérifiez que les noms des secrets sont exactement `AWS_ACCESS_KEY_ID` et `AWS_SECRET_ACCESS_KEY` (respectez la casse)

## Utilisation

### Workflow Apply

Le workflow `terraform-apply.yml` peut s'exécuter de deux façons :

#### Déclenchement Automatique

- **Trigger** : Push sur la branche `main`
- **Condition** : Uniquement si des fichiers dans `terraform/**` ont changé
- **Actions** :
  1. Checkout du code
  2. Setup Terraform
  3. Configuration des credentials AWS
  4. `terraform fmt -check` (vérification du formatage)
  5. `terraform init`
  6. `terraform validate`
  7. `terraform plan -out=tfplan`
  8. `terraform apply -auto-approve tfplan`

#### Déclenchement Manuel (workflow_dispatch)

Vous pouvez également déclencher le workflow manuellement :

1. Allez dans l'onglet **Actions** de votre repository GitHub
2. Sélectionnez le workflow **Terraform Apply**
3. Cliquez sur **Run workflow**
4. Sélectionnez la branche (généralement `main`)
5. Cliquez sur **Run workflow**

Cela permet de relancer le déploiement sans faire de push, utile pour :
- Re-déployer après un problème
- Tester après avoir modifié les secrets GitHub
- Forcer un déploiement même si aucun fichier n'a changé

### Workflow Manuel (Destroy)

Le workflow `terraform-destroy.yml` doit être déclenché **manuellement** :

1. Allez dans l'onglet **Actions** de votre repository GitHub
2. Sélectionnez le workflow **Terraform Destroy**
3. Cliquez sur **Run workflow**
4. Dans le champ **confirm**, tapez exactement : `DESTROY`
5. Cliquez sur **Run workflow**

⚠️ **Sécurité** : Le workflow échouera si vous ne tapez pas exactement `DESTROY` dans le champ de confirmation.

## Commandes Locales

### Initialisation

```bash
cd terraform
terraform init
```

### Planification (test sans appliquer)

```bash
terraform plan
```

### Application locale (non recommandé si vous utilisez GitHub Actions)

```bash
terraform apply
```

### Affichage des outputs

```bash
terraform output
```

Pour obtenir uniquement l'IP publique :

```bash
terraform output instance_public_ip
```

Pour obtenir uniquement le DNS public :

```bash
terraform output instance_public_dns
```

### Destruction locale (non recommandé si vous utilisez GitHub Actions)

```bash
terraform destroy
```

## Récupération de l'IP et du DNS

### Via Terraform Outputs

Après le déploiement, les outputs sont disponibles :

```bash
terraform output instance_public_ip
terraform output instance_public_dns
```

### Via la Console AWS

1. Connectez-vous à la [Console AWS](https://console.aws.amazon.com)
2. Allez dans **EC2 > Instances**
3. Recherchez l'instance nommée `awsworkflow-ec2`
4. L'IP publique et le DNS public sont visibles dans les détails de l'instance

### Via GitHub Actions

Les outputs Terraform sont également visibles dans les logs du workflow GitHub Actions après l'exécution de `terraform apply`.

## Accès à l'Application

Une fois l'instance déployée, vous pouvez accéder à la page web via :

- **HTTP** : `http://<instance_public_ip>` ou `http://<instance_public_dns>`
- La page affiche : "OK - deployed by Terraform + GitHub Actions"

## Notes de Sécurité

### ⚠️ Restriction SSH

Par défaut, le Security Group autorise SSH (port 22) depuis `0.0.0.0/0`, ce qui signifie que n'importe qui peut tenter de se connecter.

**Pour restreindre l'accès SSH** :

1. Modifiez la variable `ssh_cidr` dans `terraform/variables.tf` ou passez-la via `terraform.tfvars` :

```hcl
ssh_cidr = "VOTRE_IP_PUBLIQUE/32"
```

2. Ou modifiez directement dans le Security Group dans `terraform/main.tf`

### ⚠️ Clé SSH

Si vous souhaitez vous connecter en SSH à l'instance, vous devez :

1. Créer une paire de clés dans AWS EC2
2. Passer le nom de la clé via la variable `key_name` :

```hcl
key_name = "nom-de-votre-cle"
```

Ou via `terraform.tfvars` :

```hcl
key_name = "nom-de-votre-cle"
```

## Structure du Projet

```
awsworkflow/
├── terraform/
│   ├── versions.tf          # Versions Terraform et providers
│   ├── providers.tf         # Configuration du provider AWS
│   ├── backend.tf           # Configuration du backend S3
│   ├── variables.tf         # Variables Terraform
│   ├── main.tf              # Ressources principales (EC2, Security Group)
│   ├── outputs.tf           # Outputs Terraform (IP, DNS)
│   └── user_data.sh         # Script d'initialisation EC2 (nginx)
├── .github/
│   └── workflows/
│       ├── terraform-apply.yml    # Workflow automatique (apply)
│       └── terraform-destroy.yml  # Workflow manuel (destroy)
└── README.md                # Ce fichier
```

## Variables Terraform

| Variable | Description | Défaut |
|----------|-------------|--------|
| `aws_region` | Région AWS | `us-east-1` |
| `project_name` | Nom du projet | `awsworkflow` |
| `instance_type` | Type d'instance EC2 | `t3.micro` |
| `ssh_cidr` | CIDR autorisé pour SSH | `0.0.0.0/0` ⚠️ |
| `key_name` | Nom de la clé SSH AWS | `null` |

## Dépannage

### Erreur : "Backend configuration changed"

Si vous modifiez le backend, vous devez migrer le state :

```bash
terraform init -migrate-state
```

### Erreur : "Bucket does not exist"

Vérifiez que vous avez bien créé le bucket S3 avec les commandes de bootstrap.

### Le workflow GitHub Actions échoue

1. Vérifiez que les secrets GitHub sont bien configurés
2. Vérifiez les logs du workflow dans l'onglet Actions
3. Vérifiez que les credentials AWS ont les permissions nécessaires (EC2, S3)

## Support

Pour toute question ou problème, consultez les logs GitHub Actions ou les logs Terraform locaux.

