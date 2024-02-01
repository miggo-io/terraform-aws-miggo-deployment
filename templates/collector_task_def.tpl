[
  {
    "name": "${name}",
    "image": "${collector_image}:${collector_version}",
    "repositoryCredentials": {
        "credentialsParameter": "${docker_hub_arn_secret}"
    }
    "cpu": ${cpu},
    "memory": ${memory},
    "memoryReservation": ${memory},
    "essential": true,
    "portMappings": [
      {
        "containerPort": ${port_http}
      },
      {
        "containerPort": ${port_grpc}
      },
      {
        "containerPort": 13133
      }
    ],
    "environment": [
%{for key, value in additional_env_vars}
      ,{
        "name": "${key}",
        "value": "${value}"
      }
%{endfor ~}
    ],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${log_group}",
            "awslogs-region": "${aws_region}",
            "awslogs-stream-prefix": "${log_stream}"
        }
    },
    "healthCheck": {
        "retries": 3,
        "command": [
            "CMD-SHELL",
            "wget http://localhost:13133/ -O /dev/null || exit 1"
        ],
        "timeout": 5,
        "interval": 30,
        "startPeriod": null
    }
  }
]