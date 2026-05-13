# AWS EKS Project

This Terraform project provisions an Amazon Elastic Kubernetes Service (EKS) cluster along with the necessary networking infrastructure on AWS. The infrastructure includes a VPC, public and private subnets, security groups, and IAM roles configured for a production-ready EKS environment.

## Architecture

The project creates the following AWS resources:

- **VPC**: Custom VPC with configurable CIDR block
- **Subnets**: 
  - 2 Public subnets with internet access
  - 2 Private subnets for EKS nodes
- **Internet Gateway**: For public subnet internet access
- **NAT Gateway**: For private subnet outbound traffic
- **Security Groups**: 
  - Public SG: Allows HTTP (80), HTTPS (443), and SSH access
  - Private SG: Allows internal traffic and Redis access
- **EKS Cluster**: Kubernetes control plane
- **EKS Node Group**: Worker nodes using spot instances (t2.medium/t3.medium)
- **IAM Roles**: Required roles for EKS cluster and nodes
- **Access Entries**: Grants cluster admin access to users in the "admins" IAM group

## Prerequisites

Before deploying this infrastructure, ensure you have:

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.14.0 installed
3. **AWS CLI** configured with credentials
4. **IAM Group** named "admins" with users who need cluster access
5. **S3 Bucket** for Terraform state (configure in `backend.tf`)

## Quick Start

### 1. Clone and Configure

```bash
git clone https://github.com/ahmed3oun/aws-eks-project.git
cd aws-eks-project
```

### 2. Configure Backend

Edit `backend.tf` with your S3 bucket details:

```hcl
terraform {
  backend "s3" {
    bucket       = "your-terraform-state-bucket"
    key          = "aws-eks-project/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

### 3. Configure Variables

Update `terraform.tfvars` with your values:

```hcl
fullname   = "your-project-name"
cidr_block = "10.0.0.0/16"
tags = {
  "project" : "aws-eks-project",
  "owner" : "your-name"
}
# ... configure subnets as needed
```

### 4. Initialize and Deploy

```bash
# Initialize Terraform
terraform init

# Create workspace (if needed)
terraform workspace select dev || terraform workspace new dev

# Plan the deployment
terraform plan

# Apply the changes
terraform apply
```

## Configuration

### Variables

| Variable | Description | Type | Required |
|----------|-------------|------|----------|
| `fullname` | Project name prefix for resources | string | Yes |
| `tags` | Tags to apply to resources | map(string) | Yes |
| `cidr_block` | VPC CIDR block | string | Yes |
| `public_subnets` | List of public subnet configurations | list(object) | Yes |
| `private_subnets` | List of private subnet configurations | list(object) | Yes |

### Security Groups

Security group rules are defined in `sg_rules.csv`. The current configuration allows:

- **Public Subnets**: HTTP (80), HTTPS (443) from anywhere, SSH from private subnets
- **Private Subnets**: Redis (6379) from public subnets, internal traffic

### Workspaces

The project uses Terraform workspaces for environment isolation. Current setup supports:
- `dev` - Development environment

## Modules

### Network Module (`modules/network/`)

Handles VPC, subnets, gateways, and security groups creation.

### EKS Module (`modules/eks/`)

Creates the EKS cluster, node groups, IAM roles, and access policies.

## CI/CD

GitHub Actions workflows are included for automated deployment:

- **Provision Infrastructure** (`.github/workflows/provision-infra.yml`): Deploys the infrastructure
- **Destroy Infrastructure** (`.github/workflows/destroy-infra.yml`): Destroys all resources

### Required Secrets

Set these in your GitHub repository secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `TF_BACKEND_S3_BUCKET_NAME`
- `TF_BACKEND_S3_BUCKET_KEY`
- `TF_BACKEND_S3_BUCKET_REGION`

## Usage

### Connecting to the Cluster

After deployment, configure kubectl:

```bash
aws eks update-kubeconfig --region us-east-1 --name <cluster-name>
```

### Scaling Node Groups

Update the `scaling_config` in `modules/eks/main.tf`:

```hcl
scaling_config {
  desired_size = 2  # Change as needed
  max_size     = 3
  min_size     = 1
}
```

### Adding More Security Rules

Edit `sg_rules.csv` and update the locals in `locals.tf` accordingly.

## Cost Optimization

- Uses **Spot instances** for worker nodes to reduce costs
- Configurable node scaling (1-3 nodes)
- NAT Gateway per AZ for high availability

## Security Considerations

- Private subnets for worker nodes
- IAM roles with least privilege
- Security groups restrict traffic
- Access entries limit cluster admin access

## Troubleshooting

### Common Issues

1. **Backend Configuration**: Ensure S3 bucket exists and credentials have access
2. **IAM Permissions**: Verify AWS credentials have EKS and VPC permissions
3. **Subnet Conflicts**: Check for overlapping CIDR blocks
4. **Node Group Issues**: Ensure VPC CNI policy is attached to node role

### Logs

Check Terraform logs with:

```bash
terraform apply -auto-approve 2>&1 | tee terraform.log
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test
4. Submit a pull request

## License

This project is licensed under the MIT License.