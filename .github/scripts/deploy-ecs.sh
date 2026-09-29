#!/usr/bin/env bash
# Deploy ECS rolling: registra la task def con la imagen nueva y fuerza
# el despliegue del servicio (usado por deploy-dev y deploy-prod).
# Requiere: ECS_TASK_FAMILY, TARGET_IMAGE, ECS_CLUSTER, ECS_SERVICE.
set -euo pipefail

aws ecs describe-task-definition \
  --task-definition "$ECS_TASK_FAMILY" \
  --query taskDefinition > taskdef.json

jq --arg img "$TARGET_IMAGE" \
  '.containerDefinitions[0].image = $img
   | del(.taskDefinitionArn, .revision, .status,
         .requiresAttributes, .compatibilities,
         .registeredAt, .registeredBy)' \
  taskdef.json > taskdef-new.json

aws ecs register-task-definition \
  --cli-input-json file://taskdef-new.json

aws ecs update-service \
  --cluster "$ECS_CLUSTER" \
  --service "$ECS_SERVICE" \
  --task-definition "$ECS_TASK_FAMILY" \
  --force-new-deployment
