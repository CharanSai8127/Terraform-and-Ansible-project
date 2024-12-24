# Terraform-and-Ansible-project
# Project Documentation: Nexus Private Docker Repository with Terraform and Ansible

This project demonstrates the setup of a highly functional infrastructure using Terraform and Ansible to:
- Create a virtual machine (VM) and an S3 bucket with Terraform.
- Configure Terraform backend and locking using an S3 bucket and DynamoDB.
- Deploy a Nexus repository on the VM using Ansible.
- Set up a private Docker repository on Nexus.
- Enforce S3 bucket versioning as a policy using Ansible.

## **Project Overview**

### **Infrastructure Components**
1. **Terraform**
   - Creates the virtual machine, S3 bucket, and DynamoDB table.
   - Configures Terraform backend and state locking.

2. **Ansible**
   - Installs and configures Nexus on the VM.
   - Sets up a private Docker repository on Nexus.
   - Enforces versioning on the S3 bucket.

3. **Nexus Repository**
   - Hosts a private Docker repository to push and pull Docker images.

### **Technologies Used**
- **Terraform** for infrastructure provisioning.
- **Ansible** for configuration management.
- **AWS** for cloud resources (EC2, S3, DynamoDB).
- **Nexus** for Docker image repository.

## **Setup Steps**

### **1. Terraform Configuration**

- **Files:**
  - `main.tf`: Defines AWS resources (VM, S3 bucket, DynamoDB table).
  - `backend.tf`: Configures S3 backend for Terraform state.
  - `variables.tf`: Contains input variables for Terraform.

- **Execution:**
  ```bash
  terraform init
  terraform plan
  terraform apply
  ```

### **2. Ansible Playbook**

- **Playbook Files:**
  - `nexus-setup.yml`: Installs Nexus and configures it as a Docker repository.
  - `policy-enforce.yml`: Enforces S3 bucket versioning.

- **Execution:**
  ```bash
  ansible-playbook -i inventory.ini nexus-setup.yml
  ansible-playbook -i inventory.ini policy-enforce.yml
  ```

### **3. Nexus Docker Repository**

- **Steps:**
  - Access the Nexus UI.
  - Create a private Docker repository.
  - Push and pull Docker images using the private repository.

- **Commands:**
  ```bash
  docker tag <image_name> 65.0.18.184:5000/<image_name>
  docker push 65.0.18.184:5000/<image_name>
  docker pull 65.0.18.184:5000/<image_name>
  ```

### **4. Policy-as-Code: S3 Versioning**

- **Playbook Tasks:**
  - List all S3 buckets in the AWS account.
  - Enable versioning for each bucket.

- **Validation:**
  Verify versioning on the S3 bucket through the AWS Management Console.

## **Screenshots**

- Terraform resource creation output.
- S3 bucket properties showing versioning enabled.
- Nexus UI with the private Docker repository.
- Docker commands to push and pull images.
- Ansible playbook execution outputs.

## **Directory Structure**

```
project-name/
├── terraform/
│   ├── main.tf
│   ├── backend.tf
│   ├── variables.tf
│   └── outputs.tf
├── ansible/
│   ├── nexus-setup.yml
│   ├── policy-enforce.yml
│   └── inventory.ini
├── README.md
└── screenshots/
    ├── terraform-output.png
    ├── nexus-ui.png
    ├── docker-commands.png
    └── s3-versioning.png
```

## **Improvements and Scalability**

- **RBAC Policies:** Implement Role-Based Access Control (RBAC) for Nexus and AWS resources.
- **Autoscaling:** Use AWS Auto Scaling for the VM to handle higher loads.
- **CI/CD Integration:** Automate image builds and pushes to the private Docker repository.
- **Monitoring:** Add monitoring for Nexus and the Docker repository using tools like Prometheus and Grafana.

## **Conclusion**

This project demonstrates an end-to-end setup of a private Docker repository using modern Infrastructure-as-Code and Configuration-as-Code tools. It highlights automation, security, and scalability best practices.
