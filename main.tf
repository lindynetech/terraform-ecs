
## TODO
# Create Service

data "aws_vpc" "default" {
  default = true
}

data "aws_security_groups" "default-vpc-sgs" {
  filter {
    name   = "group-name"
    values = ["*WebTier*"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_subnet_ids" "default-vpc-subnets" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "default-vpc-subnets" {
  for_each = data.aws_subnet_ids.default-vpc-subnets.ids
  id       = each.value
}

resource "aws_ecs_cluster" "tf-ecs-cluster" {
  name = "tf-ecs-cluster"
}

resource "aws_instance" "ecs-cluster-instance" {
  ami                         = "ami-05250bd90f5750ed7"
  instance_type               = "t2.micro"
  key_name                    = "sysops-key"
  associate_public_ip_address = true
  vpc_security_group_ids      = [element(data.aws_security_groups.default-vpc-sgs.ids, 0)]
  iam_instance_profile        = "EC2-ECS-Access"

  user_data = file("register-ecs-instance.sh")

  tags = {
    Name = "tf-ecs-instance"
    Env  = "Terraform"
    Role = "CLusterInstance"
  }
}

resource "aws_ecs_task_definition" "tf-td" {
  family                = "tf-td"
  task_role_arn         = ""
  execution_role_arn    = "arn:aws:iam::359591046374:role/ecsTaskExecutionRole"
  network_mode          = "bridge"
  container_definitions = templatefile("tf-td.tmpl", { imagetag = var.imagetag })
}

data "aws_ecs_container_definition" "demoapp" {
  task_definition = aws_ecs_task_definition.tf-td.id
  container_name  = "demoapp"
}

resource "aws_ecs_service" "demoapp-service" {
  name                = "demoapp-service"
  cluster             = aws_ecs_cluster.tf-ecs-cluster.id
  task_definition     = aws_ecs_task_definition.tf-td.arn
  desired_count       = 2
  scheduling_strategy = "REPLICA"
  launch_type         = "EC2" # default

  deployment_controller {
    type = "ECS"
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }
}