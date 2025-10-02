#!/bin/bash

# Deployment script for GCP Data Pipeline Infrastructure
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install Terraform first."
        exit 1
    fi
    
    if ! command -v gcloud &> /dev/null; then
        print_error "Google Cloud SDK is not installed. Please install gcloud first."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Check if terraform.tfvars exists
check_config() {
    if [ ! -f "terraform.tfvars" ]; then
        print_warning "terraform.tfvars not found. Creating from example..."
        cp terraform.tfvars.example terraform.tfvars
        print_error "Please edit terraform.tfvars with your configuration and run this script again."
        exit 1
    fi
    print_success "Configuration file found"
}

# Initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    terraform init
    print_success "Terraform initialized"
}

# Plan deployment
plan_deployment() {
    print_status "Planning deployment..."
    terraform plan -out=tfplan
    print_success "Deployment plan created"
}

# Apply deployment
apply_deployment() {
    print_status "Applying deployment..."
    terraform apply tfplan
    print_success "Deployment completed"
}

# Show outputs
show_outputs() {
    print_status "Deployment outputs:"
    echo ""
    terraform output
    echo ""
    print_success "Infrastructure deployed successfully!"
    echo ""
    print_status "Next steps:"
    echo "1. SSH to your VMs using the commands shown above"
    echo "2. Install your applications using docker-compose"
    echo "3. Configure data warehouse connections"
    echo "4. Set up monitoring dashboards"
}

# Main deployment function
deploy() {
    print_status "Starting GCP Data Pipeline Infrastructure deployment..."
    
    check_prerequisites
    check_config
    init_terraform
    plan_deployment
    
    # Ask for confirmation
    echo ""
    print_warning "Review the plan above. Do you want to proceed with deployment? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        apply_deployment
        show_outputs
    else
        print_status "Deployment cancelled"
        exit 0
    fi
}

# Destroy function
destroy() {
    print_warning "This will destroy ALL infrastructure. Are you sure? (y/N)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        print_status "Destroying infrastructure..."
        terraform destroy
        print_success "Infrastructure destroyed"
    else
        print_status "Destroy cancelled"
    fi
}

# Help function
show_help() {
    echo "GCP Data Pipeline Infrastructure Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  deploy    Deploy the infrastructure (default)"
    echo "  destroy   Destroy the infrastructure"
    echo "  plan      Show deployment plan only"
    echo "  output    Show current outputs"
    echo "  help      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 deploy   # Deploy infrastructure"
    echo "  $0 destroy  # Destroy infrastructure"
    echo "  $0 plan     # Show what will be deployed"
}

# Main script logic
case "${1:-deploy}" in
    "deploy")
        deploy
        ;;
    "destroy")
        destroy
        ;;
    "plan")
        check_prerequisites
        check_config
        init_terraform
        terraform plan
        ;;
    "output")
        terraform output
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        show_help
        exit 1
        ;;
esac