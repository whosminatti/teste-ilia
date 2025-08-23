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


### Arquitetura:
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Infraestrutura EKS</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 20px;
            background: linear-gradient(135deg, #1e3c72, #2a5298);
            color: white;
            min-height: 100vh;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            padding: 30px;
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }
        
        h1 {
            text-align: center;
            color: #fff;
            font-size: 2.5em;
            margin-bottom: 30px;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
        }
        
        .diagram {
            position: relative;
            width: 100%;
            height: 800px;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 15px;
            border: 2px solid rgba(255, 255, 255, 0.2);
            overflow: hidden;
        }
        
        .vpc {
            position: absolute;
            top: 20px;
            left: 20px;
            right: 20px;
            bottom: 20px;
            border: 3px dashed #4CAF50;
            border-radius: 15px;
            background: rgba(76, 175, 80, 0.1);
        }
        
        .vpc-label {
            position: absolute;
            top: 10px;
            left: 20px;
            background: #4CAF50;
            color: white;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: bold;
            font-size: 14px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }
        
        .az {
            position: absolute;
            border: 2px solid #2196F3;
            border-radius: 10px;
            background: rgba(33, 150, 243, 0.1);
        }
        
        .az1 {
            top: 80px;
            left: 40px;
            width: 45%;
            height: 650px;
        }
        
        .az2 {
            top: 80px;
            right: 40px;
            width: 45%;
            height: 650px;
        }
        
        .az-label {
            position: absolute;
            top: 10px;
            left: 15px;
            background: #2196F3;
            color: white;
            padding: 6px 12px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .subnet {
            position: absolute;
            border: 2px solid;
            border-radius: 8px;
            padding: 15px;
            font-size: 12px;
            font-weight: bold;
            text-align: center;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        
        .subnet:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
        }
        
        .public-subnet {
            background: rgba(255, 193, 7, 0.2);
            border-color: #FFC107;
            color: #FFC107;
        }
        
        .private-subnet {
            background: rgba(156, 39, 176, 0.2);
            border-color: #9C27B0;
            color: #9C27B0;
        }
        
        .public-1 { top: 50px; left: 20px; right: 20px; height: 80px; }
        .private-1 { top: 150px; left: 20px; right: 20px; height: 80px; }
        .public-2 { top: 50px; left: 20px; right: 20px; height: 80px; }
        .private-2 { top: 150px; left: 20px; right: 20px; height: 80px; }
        
        .component {
            position: absolute;
            border-radius: 8px;
            padding: 12px;
            text-align: center;
            font-size: 11px;
            font-weight: bold;
            color: white;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            transition: all 0.3s ease;
            cursor: pointer;
        }
        
        .component:hover {
            transform: scale(1.05);
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.3);
        }
        
        .igw {
            top: -10px;
            left: 50%;
            transform: translateX(-50%);
            background: #FF5722;
            width: 100px;
            height: 40px;
            line-height: 16px;
        }
        
        .nat {
            top: 260px;
            left: 50%;
            transform: translateX(-50%);
            background: #607D8B;
            width: 90px;
            height: 50px;
            line-height: 14px;
        }
        
        .eks-cluster {
            top: 350px;
            left: 20px;
            right: 20px;
            height: 100px;
            background: linear-gradient(135deg, #FF6B35, #F7931E);
            font-size: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
        }
        
        .node-group {
            top: 480px;
            left: 30px;
            right: 30px;
            height: 80px;
            background: linear-gradient(135deg, #36D1DC, #5B86E5);
            display: flex;
            align-items: center;
            justify-content: center;
            flex-direction: column;
        }
        
        .security-group {
            top: 590px;
            left: 50%;
            transform: translateX(-50%);
            background: #795548;
            width: 150px;
            height: 40px;
            line-height: 16px;
        }
        
        .connection {
            position: absolute;
            background: rgba(255, 255, 255, 0.6);
            z-index: 1;
        }
        
        .connection-vertical {
            width: 2px;
            left: 50%;
        }
        
        .connection-horizontal {
            height: 2px;
            top: 50%;
        }
        
        .conn1 { top: 30px; height: 50px; }
        .conn2 { top: 310px; height: 40px; }
        .conn3 { top: 460px; height: 20px; }
        
        .legend {
            position: absolute;
            bottom: 20px;
            right: 20px;
            background: rgba(0, 0, 0, 0.7);
            padding: 20px;
            border-radius: 10px;
            font-size: 12px;
        }
        
        .legend-item {
            display: flex;
            align-items: center;
            margin-bottom: 8px;
        }
        
        .legend-color {
            width: 20px;
            height: 20px;
            border-radius: 4px;
            margin-right: 10px;
        }
        
        .resource-count {
            position: absolute;
            top: 20px;
            right: 20px;
            background: rgba(0, 0, 0, 0.7);
            padding: 15px;
            border-radius: 10px;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Infraestrutura EKS - teste-ilia</h1>
        
        <div class="resource-count">
            <strong>📊 Recursos a serem criados: 24</strong>
        </div>
        
        <div class="diagram">
            <!-- VPC -->
            <div class="vpc">
                <div class="vpc-label">VPC: teste-ilia (10.0.0.0/16)</div>
                
                <!-- Internet Gateway -->
                <div class="component igw">
                    🌐 Internet<br>Gateway
                </div>
                
                <!-- Availability Zone 1 -->
                <div class="az az1">
                    <div class="az-label">AZ: us-east-1a</div>
                    
                    <div class="subnet public-subnet public-1">
                        🌍 Public Subnet<br>10.0.1.0/24
                    </div>
                    <div class="subnet private-subnet private-1">
                        🔒 Private Subnet<br>10.0.3.0/24
                    </div>
                </div>
                
                <!-- Availability Zone 2 -->
                <div class="az az2">
                    <div class="az-label">AZ: us-east-1b</div>
                    
                    <div class="subnet public-subnet public-2">
                        🌍 Public Subnet<br>10.0.2.0/24
                    </div>
                    <div class="subnet private-subnet private-2">
                        🔒 Private Subnet<br>10.0.4.0/24
                    </div>
                </div>
                
                <!-- NAT Gateway -->
                <div class="component nat">
                    🔄 NAT<br>Gateway
                </div>
                
                <!-- EKS Cluster -->
                <div class="component eks-cluster">
                    ⚙️ EKS Cluster<br>
                    <strong>teste-ilia</strong><br>
                    Kubernetes v1.32
                </div>
                
                <!-- Node Group -->
                <div class="component node-group">
                    🖥️ Node Group<br>
                    <strong>t3.medium</strong><br>
                    Min: 1, Desired: 2, Max: 3
                </div>
                
                <!-- Security Group -->
                <div class="component security-group">
                    🛡️ Security Group<br>Port 443 (HTTPS)
                </div>
            </div>
            
            <!-- Connections -->
            <div class="connection connection-vertical conn1"></div>
            <div class="connection connection-vertical conn2"></div>
            <div class="connection connection-vertical conn3"></div>
        </div>
        
        <div class="legend">
            <h4>🏷️ Legenda:</h4>
            <div class="legend-item">
                <div class="legend-color" style="background: #4CAF50;"></div>
                VPC (Virtual Private Cloud)
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #FFC107;"></div>
                Subnets Públicas
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #9C27B0;"></div>
                Subnets Privadas
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: linear-gradient(45deg, #FF6B35, #F7931E);"></div>
                EKS Cluster
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: linear-gradient(45deg, #36D1DC, #5B86E5);"></div>
                Worker Nodes
            </div>
        </div>
    </div>
    
    <script>
        // Add hover effects and tooltips
        document.querySelectorAll('.component').forEach(component => {
            component.addEventListener('mouseenter', function() {
                this.style.transform = this.style.transform.replace('scale(1.05)', '') + ' scale(1.05)';
            });
            
            component.addEventListener('mouseleave', function() {
                this.style.transform = this.style.transform.replace(' scale(1.05)', '');
            });
        });
        
        // Add click information
        document.querySelectorAll('.subnet, .component').forEach(element => {
            element.addEventListener('click', function() {
                const info = this.textContent.trim();
                alert(`ℹ️ Informações:\n${info}`);
            });
        });
    </script>
</body>
</html>