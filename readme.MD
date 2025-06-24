# VPC Module
This module is developed for VPC

## Inputs
* Project (required) - Users should specify their project name
* environment (required) - Users should specify their environment
* cidr_block (optional) - Users can provide their CIDR block.

## Outputs
Exports VPC ID Created
Exposing the VPC ID in output.tf when module is used by another person like in 00-vpc--> main.tf
#Steps to Create VPC Module
1. We need to Create VPC so here we need to take Input as cidr_block range and it should be in 10.0.0.0/16 (/16 means it will block first 2 ports i.e. 10.0 for network port) to create VPC
Eg: 10.0.0.0/24 (/24 means it will block first 3 ports i.e. 10.0.0 for network port)
2. After creating the VPC we are attaching the VPC to Internet Gateway in order to allow    the Incoming traffic to VPC From internet Gateway 
Input is "VPC-Id" for the internet Gateway
3. Creating the 