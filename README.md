# bpor-rms-infrastructure

**Description**: Terraform code for bpor-rms-Infrastructure

This is the main Repo for the BPOR-RMS infrastucture code.

The backend code lives over in https://github.com/PA-NIHR-CRN/dte-study-api


**Resources**
* Amazon ECS (Fargate)
* Amazon ECR
* AWS WAF
* AWS Application/Network Load Balancer
* AWS CloudWatch

**Structure of Code**: 

```bash
.
├── README.md
├── cred
│   └── cred.tf
├── global.tf
├── main.tf
├── modules
│   ├── cloudwatch_alarms
│   │   ├── alb-alarms.tf
│   │   ├── ecs-error-alarms.tf
│   │   ├── rds.tf
│   │   └── var.tf
│   ├── container-service
│   │   ├── acm.tf
│   │   ├── iam_role.tf
│   │   ├── lb.tf
│   │   ├── main.tf
│   │   └── var.tf
│   ├── event_role
│   │   ├── iam.tf
│   │   └── var.tf
│   ├── ecs_scheduled_task
│   │   ├── task.tf
│   │   └── var.tf
│   ├── ecr
│   │   ├── main.tf
│   │   └── var.tf
│   ├── waf
│   │   ├── waf.tf
│       └── var.tf
├── output.tf
└── versions.tf
```
