# teste-ilia

---

# Infraestrutura

### VPC

- VPC com DNS e hostnames habilitados
- Subnets públicas com IP publico e subnets privadas distribuídas pelas AZs
- Internet Gateway para acesso a internet
- NAT Gateway na subnet publica com Elastic IP

- Route Tables
  - Publica: roteamento 0.0.0.0/0 → Internet Gateway
  - Privada: roteamento 0.0.0.0/0 → NAT Gateway
- Associações de Route Table

### EKS

- EKS Cluster
  - Versão definida em var.k8s_version
  - Endpoints público e privado habilitados
  - Associado a Security Groups específicos

- Node Group
  - Auto Scaling configurado
  - Acesso remoto via chave SSH configurado via terraform
- IAM Roles for Service Accounts
- EBS CSI Driver addon com IAM Role dedicada para gerenciamento de PV (EBS)

### IAM

- Role do Cluster EKS
  - Policies
    - AmazonEKSClusterPolicy
    - AmazonEKSServicePolicy

- Role dos Worker Nodes
  - Policies
    - AmazonEKSWorkerNodePolicy - gerenciamento de nodes
    - AmazonEKS_CNI_Policy - rede do Kubernetes
    - AmazonEC2ContainerRegistryReadOnly - acesso ao ECR

- Role do EBS CSI Driver
  - Policies
    - AmazonEBSCSIDriverPolicy

- Security Groups
  - Security Group para o EKS Cluster
    - Ingress: API Server do Kubernetes liberada para qualquer origem na porta 443
    - Egress: Todo o tráfego liberado

### Timestream

- Database Timestream
- Tabela Timestream


# GitHub Actions Workflow

## Jobs

### Terraform Infrastructure

- Provisiona infraestrutura AWS (VPC, EKS, Node Group, Timestream, IAM, Policies e Security Groups) via Terraform

- Steps
  - Checkout do repositório
  - Configuração de credenciais AWS com GitHub Secrets
  - Instalação do Terraform
  - Terraform init
  - Terraform validate
  - Terraform plan
  - Terraform state list (para caso já exista estrutura provisionada)
  - Terraform apply com auto-approve
  - Terraform output
  - Espera EKS e Node Group ficarem ativos
  
### Kubernetes Deployment

> Optei por separar as configurações do K8s do terraform para ficar mais fácil a leitura e manutenção do código

- Configura recursos Kubernetes e instala o Grafana no cluster

- Steps
  - Checkout do repositório
  - Configuração de credenciais AWS com GitHub Secrets
  - Instala kubectl e helm
  - Atualiza kubeconfi pra poder conectar no cluster
  - Verifica de conectividade com o cluster
  - Espera pelos nodes ficarem prontos
  - Configuração do EBS CSI Driver
    - Verifica StorageClasses disponíveis
    - Remove gp2 caso exista
    - Aplica nova configuração via manifest
    - Aguarda pods estarem prontos
  - Cria namespace monitoring
  - Teste de provisionamento de volume com PVC de teste
  - Cria PV PVC pro Grafana via manifest
  - Espera até o PVC do Grafana estar Bound (até 10 minutos)
  - Instalação do Helm chart do Grafana com:
    - Persistência habilitada (20Gi)
    - PVC existente (grafana-pvc)
    - Senha admin via secret GRAFANA_ADMIN_PASSWORD
    - Service exposto como LoadBalancer (NLB da AWS)
  - Check de pods, PVCs, services e storage classes
  - Aguarda Grafana ficar pronto
  - Exibe o endpoint público do Grafana URL doLoadBalancer