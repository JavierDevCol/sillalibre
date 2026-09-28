# Arquitectura AWS (floci) - HU-ENA-0-02

## Diagrama de Infraestructura

```mermaid
graph TB
    subgraph AWS["☁️ AWS Account (floci: 000000000000)"]
        subgraph VPC["🔴 VPC sillalibre-dev-vpc<br/>vpc-1fe73985 | 10.0.0.0/16"]

            subgraph PUBLIC["🟢 Subnets Públicas"]
                PUB1["subnet-b2059c9e<br/>us-east-1a<br/>10.0.1.0/24"]
                PUB2["subnet-4e325fc7<br/>us-east-1b<br/>10.0.2.0/24"]
            end

            subgraph PRIVATE["🟠 Subnets Privadas"]
                PRIV1["subnet-b1fb34aa<br/>us-east-1a<br/>10.0.3.0/24"]
                PRIV2["subnet-f69b53ec<br/>us-east-1b<br/>10.0.4.0/24"]
            end

            IGW["🌐 Internet Gateway<br/>igw-a3afa026"]
            NAT["🔒 NAT Gateway<br/>nat-67742300e75f7e54b<br/>EIP: 54.122.59.20"]

            subgraph RESOURCES["📦 Recursos"]
                RDS["🐘 RDS PostgreSQL 17<br/>db-F8E264F34DDE4D738B733217<br/>db.t4g.micro | 20GB<br/>Puerto: 7001"]
                KMS["🔐 KMS Key<br/>alias/sillalibre-dev<br/>d62096d1-d392-4f80-a142-1231d35be673"]
                S3["📦 S3 Bucket<br/>sillalibre-dev-assets<br/>Versionado + Lifecycle"]
                VPCE["🔗 VPC Endpoint S3<br/>vpce-b7fa510201175e8ef<br/>Gateway Type"]
            end

            subgraph BACKEND["⚙️ Terraform Backend"]
                TFSTATE["📁 S3 Bucket<br/>sillalibre-tfstate-000000000000<br/>Estado Terraform"]
                DDB["🔒 DynamoDB Table<br/>sillalibre-tflock<br/>Locking"]
            end
        end
    end

    %% Conexiones
    IGW --> PUB1
    IGW --> PUB2
    PUB1 --> NAT
    NAT --> PRIV1
    NAT --> PRIV2
    PRIV1 --> RDS
    PRIV2 --> RDS
    KMS -.-> RDS
    KMS -.-> S3
    KMS -.-> TFSTATE
    VPCE -.-> S3
    PRIV1 --> VPCE
    PRIV2 --> VPCE

    %% Estilos
    style AWS fill:#1a1a2e,stroke:#16213e,color:#fff
    style VPC fill:#0f3460,stroke:#533483,color:#fff
    style PUBLIC fill:#00FF7F26,stroke:#00FF7F,color:#fff
    style PRIVATE fill:#FFA50026,stroke:#FFA500,color:#fff
    style RESOURCES fill:#0096FF26,stroke:#0096FF,color:#fff
    style BACKEND fill:#FF69B426,stroke:#FF69B4,color:#fff
    style RDS fill:#336791,stroke:#336791,color:#fff
    style KMS fill:#FF9900,stroke:#FF9900,color:#fff
    style S3 fill:#3F8624,stroke:#3F8624,color:#fff
    style TFSTATE fill:#7B42BC,stroke:#7B42BC,color:#fff
    style DDB fill:#4053D6,stroke:#4053D6,color:#fff
```

## Resource Summary

| Componente | Recurso | ID | Valor |
|------------|---------|-----|-------|
| **VPC** | aws_vpc | vpc-1fe73985 | 10.0.0.0/16 |
| **Subnet Pública 1** | aws_subnet | subnet-b2059c9e | 10.0.1.0/24 (us-east-1a) |
| **Subnet Pública 2** | aws_subnet | subnet-4e325fc7 | 10.0.2.0/24 (us-east-1b) |
| **Subnet Privada 1** | aws_subnet | subnet-b1fb34aa | 10.0.3.0/24 (us-east-1a) |
| **Subnet Privada 2** | aws_subnet | subnet-f69b53ec | 10.0.4.0/24 (us-east-1b) |
| **Internet Gateway** | aws_internet_gateway | igw-a3afa026 | — |
| **NAT Gateway** | aws_nat_gateway | nat-67742300e75f7e54b | EIP: 54.122.59.20 |
| **RDS PostgreSQL** | aws_db_instance | db-F8E264F34DDE4D738B733217 | db.t4g.micro, 20GB, puerto 7001 |
| **KMS Key** | aws_kms_key | d62096d1-d392-4f80-a142-1231d35be673 | alias/sillalibre-dev |
| **S3 Assets** | aws_s3_bucket | sillalibre-dev-assets | Versionado + Lifecycle |
| **VPC Endpoint S3** | aws_vpc_endpoint | vpce-b7fa510201175e8ef | Gateway |
| **S3 Backend** | aws_s3_bucket | sillalibre-tfstate-000000000000 | Estado Terraform |
| **DynamoDB Lock** | aws_dynamodb_table | sillalibre-tflock | LockID partition key |
