# teste-ilia

### Rede (VPC)

1 VPC principal com CIDR 10.0.0.0/16
1 Internet Gateway para acesso à internet
1 NAT Gateway para saída dos recursos privados
1 Elastic IP para o NAT Gateway

### Subnets (4 subnets)

2 Subnets Públicas: 10.0.1.0/24 e 10.0.2.0/24
2 Subnets Privadas: 10.0.3.0/24 e 10.0.4.0/24
Distribuídas nas AZs us-east-1a e us-east-1b

### Roteamento

2 Route Tables (pública e privada)
4 Route Table Associations (uma para cada subnet)

### EKS 

1 EKS Cluster com Kubernetes v1.32
1 Node Group com instâncias t3.medium

Configuração: Min: 1, Desired: 2, Max: 3 nodes
Disco: 20GB por node


### IAM

2 IAM Roles: uma para o cluster, outra para os nodes
5 Policy Attachments:

AmazonEKSClusterPolicy
AmazonEKSServicePolicy
AmazonEKSWorkerNodePolicy
AmazonEKSCNIPolicy
AmazonEC2ContainerRegistryReadOnly

###  Security Groups

1 Security Group para o EKS cluster

Ingress: Porta 443 (HTTPS) de qualquer lugar
Egress: Todo tráfego liberado
