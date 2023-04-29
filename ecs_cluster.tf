# Define the provider
provider "aws" {
  region = "ap-south-1"
}

# Create the ECS cluster
resource "aws_ecs_cluster" "dummy_data_api_cluster" {
  name = "dummy_data_api_cluster"
}

# Create the ECS task definition
resource "aws_ecs_task_definition" "dummy_data_api_task_definition" {
  family                   = "dummy_data_api"
  container_definitions    = jsonencode([{
    name      = "dummy_data_api"
    image     = "<registry-url>/image-name:tag"
    cpu       = 256
    memory    = 512
    portMappings = [{
      containerPort = 3000
      hostPort      = 0
    }]
  }])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
}

# Create the ECS service
resource "aws_ecs_service" "dummy_data_api_service" {
  name            = "dummy_data_api_service"
  cluster         = aws_ecs_cluster.dummy_data_api_cluster.id
  task_definition = aws_ecs_task_definition.dummy_data_api_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = ["sg-group"]
    subnets         = ["subnet"]
  }
}

# Create the Application Load Balancer
resource "aws_lb" "dummy_data_api_lb" {
  name               = "dummy_data_api_lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet"]
  security_groups    = ["sg- group"]
}

# Create the target group
resource "aws_lb_target_group" "dummy_data_api_target_group" {
  name     = "dummy_data_api_target_group"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "vpc-0f70ed55924292737"
}

# Create the listener
resource "aws_lb_listener" "dummy_data_api_listener" {
  load_balancer_arn = aws_lb.dummy_data_api_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dummy_data_api_target_group.arn
  }
}

# Register the ECS service with the target group
resource "aws_lb_target_group_attachment" "dummy_data_api_target_group_attachment" {
  target_group_arn = aws_lb_target_group.dummy_data_api_target_group.arn
  target_id        = aws_ecs_service.dummy_data_api_service.id
  port             = 3000
}