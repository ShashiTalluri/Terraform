#from GIT
#VPC Creation

resource "aws_vpc" "name" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "my-vpc"
    }
  }

#public subnet (Bastionhost)
resource "aws_subnet" "publicSubnet" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.0.0/18"
    depends_on = [ aws_vpc.name ]
    tags = {
        Name = "bastionhostSubnet"
    }
}

# frontend subnet-01
resource "aws_subnet" "frontendSubnet-01" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.64.0/18"
    depends_on = [ aws_vpc.name ]
    tags = {
        Name = "frontendSubnet-01"
    }
    availability_zone = "us-east-1a"
}

# frontend subnet-02
resource "aws_subnet" "frontendSubnet-02" {
    vpc_id = aws_vpc.name.id
    cidr_block = "10.0.128.0/18"
    depends_on = [ aws_vpc.name ]
    tags = {
        Name = "frontendSubnet-02"
    }
    availability_zone = "us-east-1b"
}   
#IGW Creation
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.name.id
    tags = {
        Name = "my-igw"
    }
}

resource "aws_eip" "natgw" {
       tags = {
        Name = "my-eip"
    }
}
#NAT gateway Creation
resource "aws_nat_gateway" "natgw" {
    allocation_id = aws_eip.natgw.id
    subnet_id = aws_subnet.publicSubnet.id
    tags = {
        Name = "my-natgw"
    }
}

# create public SG SSH and HTTP access

resource "aws_security_group" "sg_public" {
    name = "sg_public"
    description = "Allow SSH and HTTP access"
    vpc_id = aws_vpc.name.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "sg_public"
    }
}  
    #Create load balancer 
    
resource "aws_lb" "public_LB" {
        name = "publicLB"
        internal = false
        load_balancer_type = "application"
        security_groups = [aws_security_group.sg_public.id]
        subnets = [aws_subnet.frontendSubnet-01.id, aws_subnet.frontendSubnet-02.id]
        tags = {
            Name = "public_LB"
        }
    }

#create EC2 instance in public subnet (Bastion host)
resource "aws_instance" "EC2_BastionHost" {
    ami = "ami-0c94855ba95c71c99"
    instance_type = var.ec2_instance_type
    subnet_id = aws_subnet.publicSubnet.id
    security_groups = [aws_security_group.sg_public.id]
    tags = {
        Name = "EC2_BastionHost"
    }
  
}

#create EC2 instance in frontend subnet-01
resource "aws_instance" "EC2_frontend-01" {
    ami = "ami-0c94855ba95c71c99"
    instance_type = var.ec2_instance_type
    subnet_id = aws_subnet.frontendSubnet-01.id
    security_groups = [aws_security_group.sg_public.id]
    tags = {
        Name = "EC2_frontend-01"
    }
  
}

#create EC2 instance in frontend subnet-02
resource "aws_instance" "EC2_frontend-02" {
    ami = "ami-0c94855ba95c71c99"
    instance_type = var.ec2_instance_type
    subnet_id = aws_subnet.frontendSubnet-02.id
    security_groups = [aws_security_group.sg_public.id]
    tags = {
        Name = "EC2_frontend-02"
    }
}

resource "aws_instance" "EC2_frontend-03" {
    ami = "ami-0c94855ba95c71c99"
    instance_type = var.ec2_instance_type
    subnet_id = aws_subnet.frontendSubnet-01.id
    security_groups = [aws_security_group.sg_public.id]
    tags = {
        Name = "EC2_frontend-03"
    }
  
}
  
  
resource "aws_security_group" "sg_private" {
    name = "sg_private"
    description = "Allow HTTP access from public SG"
    vpc_id = aws_vpc.name.id

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        security_groups = [aws_security_group.sg_public.id]
    }

    egress {
            from_port = 0
            to_port = 0
            protocol = "-1"
            cidr_blocks = ["0.0.0.0/0"]
    }
    tags = {
        Name = "sg_private"
    }
}  
    