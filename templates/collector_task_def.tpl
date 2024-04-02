[
  {
    "name": "${name}",
    "image": "${collector_image}:${collector_version}",
    "repositoryCredentials": {
        "credentialsParameter": "${dockerhub_secret_arn}"
    },
    "cpu": ${cpu},
    "memory": ${memory},
    "memoryReservation": ${memory},
    "essential": true,
    "command": [
      "--config=/conf/miggo/collector.yaml"
    ],
    "mountPoints": [
      {
          "sourceVolume": "otel-config",
          "containerPath": "/conf/miggo",
          "readOnly": false
      }
    ],
    "dependsOn": [
      {
          "containerName": "install-miggo",
          "condition": "COMPLETE"
      }
    ],
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
      {
        "name": "MIGGO_TRACES_ENDPOINT",
        "value": "${miggo_endpoint}"
      },
      {
        "name": "MIGGO_OTEL_AUTH",
        "value": "${miggo_secret}"
      }
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
            "curl -f http://localhost:13133/ || exit 1"
        ],
        "timeout": 5,
        "interval": 30,
        "startPeriod": null
    }
  },
  {
    "name": "install-miggo",
    "image": "alpine:3",
    "cpu": 0,
    "portMappings": [],
    "essential": false,
    "repositoryCredentials": {
        "credentialsParameter": "${dockerhub_secret_arn}"
    },
    "entryPoint": [
        "/bin/sh",
        "-c"
    ],
    "command": [
        "wget -O /conf/miggo/collector.yaml https://raw.githubusercontent.com/miggo-io/terraform-aws-miggo-deployment/init/configs/collector.yaml && cat /conf/miggo/collector.yaml"
    ],
    "environment": [],
    "environmentFiles": [],
    "mountPoints": [
      {
          "sourceVolume": "otel-config",
          "containerPath": "/conf/miggo",
          "readOnly": false
      }
    ],
    "volumesFrom": [],
    "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-group": "${log_group}",
            "awslogs-region": "${aws_region}",
            "awslogs-stream-prefix": "${log_stream}"
        }
    }
  }
]