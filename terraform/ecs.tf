resource "aws_ecs_cluster" "main" {
  name = "devops-cluster"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "my-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256" # 0.25 vCPU (Free Tier Friendly)
  memory                   = "512" # 0.5 GB (Free Tier Friendly)
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([{
    name      = "my-app"
    image     = "506995421637.dkr.ecr.ap-south-2.amazonaws.com/my-python-app:latest" # We start with Nginx, then your pipeline will update this to your Python ECR image
    essential = true
    portMappings = [{
      containerPort = 9999
      hostPort      = 9999
    }]
    logConfiguration = {
    logDriver = "awslogs"
    options = {
      "awslogs-group"         = "/ecs/my-app"
      "awslogs-region"        = "ap-south-2"
      "awslogs-stream-prefix" = "ecs"
      "awslogs-create-group"  = "true"
    }
  }
  }])
}

resource "aws_ecs_service" "main" {
  name            = "my-app-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets          = [aws_subnet.public.id]
    security_groups  = [aws_security_group.ecs_sg.id]
    assign_public_ip = true
  }
}