# nodejs_assign

CI/CD to test, build, push and deploy the NodeJS Dokerized app to AWS ECS using Jenkins Declarative Pipeline.

AWS SERVICES

EC2:

Security Groups: security groups to control inbound and outbound traffic to the EC2 instance running the Node.js application.

Elastic Load Balancer (ELB): ELB to distribute incoming traffic across multiple EC2 instances running the Node.js application for high availability and scalability.

Auto Scaling: Auto Scaling to automatically adjust the number of EC2 instances running the Node.js application based on demand.

Elastic Container Service (ECS): ECS to run the Node.js application in a containerized environment for easier deployment and management.

Elastic Container Registry (ECR): ECR to store and manage Docker images for the Node.js application.

API Gateway: API Gateway to expose the API endpoint for the Node.js application to the internet and manage access to the API.

IAM: IAM to manage access to AWS resources and services, including EC2, ELB, Auto Scaling, ECS, ECR, and API Gateway.

AWS WAF: AWS WAF provides rate limiting and protection against common web exploits.
