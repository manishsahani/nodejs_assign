resource "aws_ecs_cluster" "dummy_data_api_cluster" {
  name = "dummy-data-api-cluster"
}

resource "aws_ecs_task_definition" "dummy_data_api_task" {
  family                   = "dummy-data-api-task"
  container_definitions    = jsonencode([{
    name                    = "dummy-data-api-container"
    image                   = "<registry-url>/dummy-data-api:latest"
    portMappings            = [{
      containerPort         = 3000
      hostPort              = 3000
    }]
    environment             = [{
      name                  = "NODE_ENV"
      value                 = "production"
    }]
  }])
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
}

resource "aws_ecs_service" "dummy_data_api_service" {
  name            = "dummy-data-api-service"
  cluster         = aws_ecs_cluster.dummy_data_api_cluster.id
  task_definition = aws_ecs_task_definition.dummy_data_api_task.arn
  desired_count   = 1

  network_configuration {
    security_groups = [aws_security_group.dummy_data_api_sg.id]
    subnets         = aws_subnet.dummy_data_api_subnet.*.id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.dummy_data_api_tg.arn
    container_name   = "dummy-data-api-container"
    container_port   = 3000
  }
}

resource "aws_security_group" "dummy_data_api_sg" {
  name_prefix = "dummy-data-api-sg"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_subnet" "dummy_data_api_subnet" {
  count = 2

  cidr_block = "10.0.${count.index + 1}.0/24"
}

resource "aws_lb_target_group" "dummy_data_api_tg" {
  name_prefix     = "dummy-data-api-tg"
  port            = 3000
  protocol        = "HTTP"
  target_type     = "ip"
  vpc_id          = aws_vpc.dummy_data_api_vpc.id
}

resource "aws_lb_listener" "dummy_data_api_listener" {
  load_balancer_arn = aws_lb.dummy_data_api_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.dummy_data_api_tg.arn
    type             = "forward"
  }
}

resource "aws_lb" "dummy_data_api_lb" {
  name               = "dummy-data-api-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.dummy_data_api_subnet.*.id
  security_groups    = [aws_security_group.dummy_data_api_lb_sg.id]
}

resource "aws_security_group" "dummy_data_api_lb_sg" {
  name_prefix = "dummy-data-api-lb-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "dummy_data_api_vpc" {
  cidr_block = "10.0.0.0/16"
}