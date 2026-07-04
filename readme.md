# TaskFlow - Projeto Final de DevOps

Projeto prático para a disciplina de **Fundamentos de DevOps**. Consiste no provisionamento de infraestrutura na AWS utilizando **Terraform**, orquestração de containers com **K3s** e deploy automatizado contínuo via **GitOps** com **ArgoCD**.

---

## 📁 Estrutura do Repositório

```text
.
├── app/
│   ├── Backend (FastAPI)
│   ├── Frontend (Vue.js)
│   └── Dockerfiles
├── k8s/
│   └── Manifestos Kubernetes (Deployment, Service, Ingress, Middleware)
├── infra/
│   └── terraform/
│       └── Infraestrutura como Código (IaC) para AWS
└── .github/
    └── workflows/
        └── Pipeline de CI com GitHub Actions
```

### Diretórios

- **`app/`**
  - Código-fonte da aplicação.
  - Backend desenvolvido em **FastAPI**.
  - Frontend desenvolvido em **Vue.js**.
  - Contém os respectivos **Dockerfiles**.

- **`k8s/`**
  - Manifestos Kubernetes utilizados pelo **ArgoCD**.
  - Inclui:
    - Deployment
    - Service
    - Ingress
    - Middleware

- **`infra/terraform/`**
  - Arquivos de **Infraestrutura como Código (IaC)** responsáveis pela criação das máquinas virtuais na AWS.

- **`.github/workflows/`**
  - Pipeline de **Integração Contínua (CI)** utilizando **GitHub Actions** para automatizar o build das imagens Docker.

---

# 🚀 Instruções de Reprodução

## 1. Provisionamento da Infraestrutura (AWS)

Utilize o Terraform para criar as instâncias EC2:

```bash
cd infra/terraform
terraform init
terraform apply -auto-approve
```

---

## 2. Configuração do Cluster Kubernetes (K3s)

### No Control Plane (Master)

Instale o K3s e anote o **token** gerado durante a instalação.

### Nos Worker Nodes

Conecte os nós ao cluster executando o script de instalação do K3s apontando para:

- URL do Master
- Token obtido anteriormente

---

## 3. Deploy Contínuo (ArgoCD)

Com o cluster em funcionamento, instale o ArgoCD e aplique o manifesto principal para iniciar a esteira GitOps.

```bash
sudo k3s kubectl create namespace argocd

sudo k3s kubectl apply -n argocd \
-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

sudo k3s kubectl apply -f k8s/application.yaml
```

---

## 4. Acessos à Aplicação

O tráfego de entrada é gerenciado pelo **Traefik** na porta **80**, utilizando o IP público do Control Plane.

### Frontend

```text
http://<IP_PUBLICO_DO_MASTER>/
```

### Backend (API)

```text
http://<IP_PUBLICO_DO_MASTER>/api
```

### Banco de Dados (Adminer)

Por segurança de rede, o acesso ao Adminer requer um túnel SSH local.

Crie o túnel:

```bash
ssh -i sua-chave.pem -L 8080:localhost:8080 ubuntu@<IP_PUBLICO_DO_MASTER>
```

Depois, no servidor, execute:

```bash
sudo k3s kubectl port-forward svc/adminer-service 8080:8080
```

Por fim, acesse no navegador local:

```text
http://localhost:8080
```