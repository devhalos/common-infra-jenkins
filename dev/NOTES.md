# Notes

## Steps to deploy Scalable Jenkins to ECS

### VPC

Prefer to create a separate VPC for the deployment. Do not use the default VPC

Assign IPv4 CIDR

- 10.0.0.0/16

#### Create Subnets

Prefer creating at minimum, for each AZ. Minimum of 2 AZ

- 1 Private Subnet
- 1 Public Subnet

Add identifier such as *private* and *public* to the subnet names to easily identify their use case

Given 2 AZ, You would have 4 subnets with IPv4 CIDRs:

AZ 1
- <common-identifier>-public-1 10.0.0.0/24
- <common-identifier>-private-1 10.0.2.0/24
  
AZ 2
- <common-identifier>-public-2 10.0.1.0/24
- <common-identifier>-private-3 10.0.3.0/24

#### Create Internet Gateway

Internet gateway is needed to allow traffic from internet to the application in the private subnets

It should reside in the public subnets of the VPC

#### Create Nat Gateways

NAT gateway is needed to allow traffic from the applications in the private subnets to the internet

Create one for each public subnet created

#### Create Route Tables

Create one route tables for the public subnets. Route 0.0.0.0/0 to the internet gateway created

Create one for each private subnet. Route 0.0.0.0/0 to the NAT gateway created in the public subnet in the same AZ

#### Create Endpoints

Endpoints are needed to access aws resources from private subnets without exposing them to the internet

- s3 - gateway
- ecr - api => connect to private subnets
- ecr - dkr => connect to private subnets
- logs => connect to private subnets

#### Create Security Groups

- One for the load balancer
    - with inbound 8080 to 0.0.0.0/0
- One for the ecs tasks 
    - with inbound 8080 and 50000 to 0.0.0.0/0
- ONe for the efs
    - with inbound 2049 to sg group created for ecs tasks
    
#### Create Load Balancer

Create an ALB to for the jenkins dashboard. The DNS name can also be use as jenkins url. It should be in all public subnets created

Add listeners 80 and 8080

#### Create Target Groups

Create target group for ALB listeners for port 8080

### Cloud Map

Create namespace to enable service discovery between the jenkins master and agents

Create service with dns configuration:
- A record with TTL=<any value>
- SRV record with port=50000 and TTL=<any value>

The DNS can be use as the value for the ecs task tunnel in jenkins cloud ecs configuration with the ff. format: <namespace-name>.<service-name>:50000

### EFS

Create a file system in EFS to be use for jenkins master as volume

#### Create an access point

- root directory path = /
- posix user id = 0
- posix group id = 0
- root directory owner user id = 1000 => jenkins user
- root directory owner group id = 1000 => jenkins group
- root directory permissions = 755 
- attach to private subnets