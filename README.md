# teste-ilia

## Desafio

#### INSTRUÇÕES

- Usar o Terraform para criar um cluster Kubernetes na AWS. Você deverá configurar o cluster de forma segura, escalável e eficiente.
- Usar o Helm Charts para instalar e configurar um Grafana no cluster Kubernetes.Você deverá personalizar o Grafana de acordo com as necessidades.
- Criar um AWS Timestream ou Athena e adicionar dados de teste no mesmo.
- Adicionar o datasource do AWS Timestream ou Athena no Grafana e mostrar os dados do Timestream ou Athena por meio de algum dashboard. Você deverá criar gráficos, tabelas e painéis que apresentem as informações de forma clara e intuitiva.
- Prover observabilidade dos recursos criados durante o desafio. Você deverá monitorar o desempenho, a disponibilidade e o consumo dos recursos.
  
- Esperamos que você documente todo o processo de criação do desafio, explicando as suas escolhas, os passos realizados e os resultados obtidos. Você também deverá fornecer os arquivos que foram usados no desafio por meio de um repositório no GitHub. Você será avaliado pela qualidade, criatividade e eficiência da sua solução. Boa sorte!
- EXTRA
  - Adicionar um microserviço a sua escolha no cluster, monitorar os logs e utilização de recursos dele no Grafana, implementar uma pipeline de CI/CD para esse serviço.
  
### O QUE FOI FEITO

- Realizei a criação da infraestrutura utilizando Terraform via GitHub Actions e algumas ações manuais via AWS Console.
- Infraestrutura provisionada pelo Terraform: VPC, IAM, Security Groups, EKS, Athena e S3.
- Algumas Policies e Roles, como as presentes no final desse arquivo, foram elaboradas manualmente.
- As configurações do Kubernetes foram realizadas via GitHub Actions, assim como a instalação do Grafana.
- Após a criação da Infraestrutura e deploy do Grafana no cluster, o mesmo encontra-se disponível neste [link](http://a8a5c287c65b84f4c8d5fa6623e0024b-e5f418666810f11a.elb.us-east-1.amazonaws.com/admin/users/edit/aew325mwfrhfkd).
- Após acessar o Grafana, dicionei o Data Source Athena através do plugin já existente na aplicação.
- Para popular o Athena utilizei alguns dados fictícios e realizei a adição do arquivo .csv no S3 manualmente.

Algumas informações relacionadas à infraestrutura e ao deploy via Actions podem ser encontradas abaixo:

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

### Athena

- S3 Bucket dedicado para armazenamento dos dados processados pelo Athena
- Bucket com política de acesso permitindo a role eks-grafana-sa realizar operações completas (s3:*)
- Glue Catalog Database
  - Banco de dados no Glue Catalog para organização das tabelas do Athena
- Glue Catalog Table
  - Tabela externa configurada para leitura de arquivos Parquet no bucket S3
  - Schema da tabela definido conforme os dados inseridos
- Permissões
  - Acesso controlado via IAM Role específica para integração com o EKS/Grafana

---

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
  - Instalação do Helm chart do Grafana com PVC existente, senha admin via secret GRAFANA_ADMIN_PASSWORD e LoadBalancer (NLB)
  - Check de pods, PVCs, services e storage classes
  - Aguarda Grafana ficar pronto
  - Exibe o endpoint público do Grafana URL doLoadBalancer

### Demais ações
Conforme relatado acima, algumas policies e roles foram criadas na mão pra facilitar e agilizar a disponibilidade do Grafana e a integração com o Datasource do Athena, como as roles e policies abaixo.

  - Roles:
    - 'AssumeRole' para a role eks-grafana-sa 
    ~~~json
    {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Action": "sts:AssumeRole",
              "Resource": "arn:aws:iam::184488529047:role/eks-grafana-sa"
          }
      ]
    }
    ~~~

Já em relação as policies foram criadas as polciies:
  - Policies:
    - 'SalvaTFStateNoS3'
      ~~~json
      {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "s3:ListBucket",
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:DeleteObject"
                ],
                "Resource": [
                    "arn:aws:s3:::teste-ilia-deploy-k8s",
                    "arn:aws:s3:::teste-ilia-deploy-k8s/*"
                ]
            }
        ]
      }
      ~~~
  
    - 'Terraform-deploy-k8s' para o usuario de criação usado pelo terraform e contem permissões para criar recursos em geral, como EC2, EKS, IAM, ELB, STS, Cloudwatch, logs etc.
      ~~~json
      {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "ec2:*",
                    "eks:*",
                    "iam:*",
                    "elasticloadbalancing:*",
                    "autoscaling:*",
                    "sts:GetCallerIdentity",
                    "cloudwatch:*",
                    "logs:*"
                ],
                "Resource": "*"
            },
            {
                "Effect": "Allow",
                "Action": [
                    "s3:ListBucket",
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:DeleteObject"
                ],
                "Resource": [
                    "arn:aws:s3:::meu-terraform-state",
                    "arn:aws:s3:::meu-terraform-state/*"
                ]
            },
            {
                "Effect": "Allow",
                "Action": [
                    "dynamodb:PutItem",
                    "dynamodb:GetItem",
                    "dynamodb:DeleteItem",
                    "dynamodb:UpdateItem"
                ],
                "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/terraform-locks"
            }
        ]
      }
      ~~~
    
    - 'GlueS3' para permitir algumas ações no glue, S3 e Athena.
      ~~~json
      {
      	"Version": "2012-10-17",
      	"Statement": [
      		{
      			"Effect": "Allow",
      			"Action": [
      				"s3:GetObject",
      				"s3:PutObject",
      				"s3:ListBucket",
      				"s3:GetBucketPolicy",
      				"s3:GetBucketAcl",
      				"s3:GetBucketCORS",
      				"s3:GetBucketWebsite",
      				"s3:GetBucketLocation",
      				"s3:GetEncryptionConfiguration",
      				"s3:AbortMultipartUpload",
      				"s3:GetBucketVersioning",
      				"s3:GetAccelerateConfiguration",
      				"s3:GetBucketRequestPayment",
      				"s3:GetBucketLogging",
      				"s3:GetLifecycleConfiguration",
      				"s3:GetReplicationConfiguration",
      				"s3:GetBucketObjectLockConfiguration",
      				"s3:GetBucketTagging",
      				"s3:DeleteObject",
      				"s3:PutObjectAcl",
      				"s3:ListBucketMultipartUploads",
      				"s3:*"
      			],
      			"Resource": [
      				"arn:aws:s3:::teste-ilia-athena-data",
      				"arn:aws:s3:::teste-ilia-athena-data/*"
      			]
      		},
      		{
      			"Effect": "Allow",
      			"Action": [
      				"glue:GetDatabase",
      				"glue:GetDatabases",
      				"glue:GetTable",
      				"glue:GetTables",
      				"glue:GetTags",
      				"glue:CreateTable",
      				"glue:UpdateTable",
      				"glue:DeleteTable"
      			],
      			"Resource": [
      				"arn:aws:glue:us-east-1:184488529047:catalog",
      				"arn:aws:glue:us-east-1:184488529047:database/monitoring_db",
      				"arn:aws:glue:us-east-1:184488529047:table/monitoring_db/*",
      				"arn:aws:glue:us-east-1:184488529047:userDefinedFunction/monitoring_db/*"
      			]
      		}
      	]
      }
      ~~~
    
    - 'AthenaAll'
      ~~~json
      {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": "athena:*",
                "Resource": [
                    "arn:aws:athena:us-east-1:184488529047:workgroup/primary",
                    "arn:aws:athena:us-east-1:184488529047:datacatalog/AwsDataCatalog"
                ]
            }
        ]
      }
      ~~~
  