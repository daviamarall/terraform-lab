# terraform-lab

[![CI](https://github.com/daviamarall/terraform-lab/actions/workflows/ci.yml/badge.svg)](https://github.com/daviamarall/terraform-lab/actions/workflows/ci.yml)
![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.6-7B42BC?logo=terraform&logoColor=white)
![AWS](https://img.shields.io/badge/AWS-provider_~5-FF9900?logo=amazonaws&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)

Infraestrutura como código (IaC) na **AWS** com **Terraform**: uma VPC completa com subnets públicas, um servidor web em EC2 e um bucket S3 seguro — tudo parametrizado, com validação automática na CI.

> Projeto de portfólio focado em **DevOps / Cloud**. Não é para rodar em produção sem revisão — é um laboratório de boas práticas.

---

## 🎯 O que este repositório demonstra

- **Infraestrutura declarativa** em módulo raiz, com variáveis e outputs
- **Rede** completa: VPC, 2 subnets públicas em AZs distintas, Internet Gateway, route table e security group
- **Compute**: instância EC2 (Amazon Linux 2023) com `user_data` provisionando um Apache
- **Storage**: bucket S3 com **versionamento**, **criptografia** e **bloqueio total de acesso público**
- **`default_tags`** para padronizar etiquetas de todos os recursos
- **`terraform fmt` + `validate`** na CI (sem precisar de credenciais AWS)
- Exemplo de **backend remoto** (state no S3 + lock via DynamoDB)

## 🏗️ O que é criado

```
        ┌────────────────────────── AWS VPC (10.0.0.0/16) ──────────────────────────┐
        │                                                                           │
        │   ┌────────────────┐        ┌────────────────┐                            │
        │   │  subnet pub-0  │        │  subnet pub-1  │                            │
        │   │      AZ-a      │        │      AZ-b      │                            │
        │   │  ┌──────────┐  │        │                │                            │
        │   │  │ EC2 web  │  │        │                │                            │
        │   │  └──────────┘  │        │                │                            │
        │   └───────┬────────┘        └────────────────┘                            │
        │           │                                                               │
        │      ┌────┴────┐     ┌──────────────┐                                     │
        │      │  IGW    │     │  S3 bucket   │  (artifacts, versionado + KMS/SSE)  │
        │      └─────────┘     └──────────────┘                                     │
        └───────────────────────────────────────────────────────────────────────────┘
```

## 🚀 Como usar

### Pré-requisitos
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.6
- Credenciais AWS (via `aws configure` ou variáveis de ambiente)

### Comandos

```bash
terraform init          # baixa os providers
terraform fmt -recursive
terraform validate
terraform plan          # revise antes de aplicar!
terraform apply
terraform output
terraform destroy       # limpa tudo ao terminar
```

### Variáveis

Copie o exemplo e ajuste:

```bash
cp terraform.tfvars.example terraform.tfvars
```

| Variável           | Padrão          | Descrição                          |
|--------------------|-----------------|------------------------------------|
| `aws_region`       | `us-east-1`     | Região AWS                         |
| `project`          | `terraform-lab` | Prefixo dos recursos               |
| `environment`      | `dev`           | Ambiente                           |
| `vpc_cidr`         | `10.0.0.0/16`   | CIDR da VPC                        |
| `instance_type`    | `t3.micro`      | Tipo da instância EC2              |
| `allowed_ssh_cidr` | `0.0.0.0/0`     | CIDR liberado para SSH (restrinja!)|

## 🌐 State remoto (boa prática)

Veja [`backend.tf.example`](backend.tf.example). Para equipes, o state **não** deve ficar local:
use **S3** (com encryption) + **DynamoDB** para locking.

## ⚠️ Segurança e custos

- **Nunca** use `allowed_ssh_cidr = 0.0.0.0/0` em produção — restrinja ao seu IP.
- O bucket S3 já nasce **privado** e criptografado.
- Lembre-se de rodar `terraform destroy` — EC2 e S3 geram **custos**.

## 🧩 Pipeline (`ci.yml`)

| Etapa             | Comando                          |
|-------------------|----------------------------------|
| Formatação        | `terraform fmt -check -recursive`|
| Init (sem backend)| `terraform init -backend=false`  |
| Validação         | `terraform validate`             |

> A CI valida a sintaxe e a formatação **sem** aplicar nada — não precisa de credenciais AWS.

## 📁 Estrutura

```
terraform-lab/
├── versions.tf   providers.tf   locals.tf   variables.tf
├── main.tf       # VPC, subnets, IGW, rotas, security group
├── compute.tf    # AMI + instância EC2
├── storage.tf    # bucket S3 (versioning, SSE, public access block)
├── outputs.tf
├── terraform.tfvars.example
├── backend.tf.example
└── .github/workflows/ci.yml
```

## 📄 Licença

MIT — veja [LICENSE](LICENSE).
