# AWS Budget Configuration - SillaLibre

## Resumen

| Campo | Valor |
|-------|-------|
| **Presupuesto** | sillalibre-monthly-forecast |
| **Tipo** | COST (forecast-based) |
| **Umbral Forecast** | $96 USD |
| **Umbral Máximo** | $160 USD |
| **Período** | Mensual |
| **Email** | jbgm93+appbarber@gmail.com |

## Configuración para AWS Real

### Opción 1: AWS CLI

```bash
# Crear presupuesto con alertas
aws budgets create-budget --account-id $(aws sts get-caller-identity --query Account --output text) \
  --budget '{
    "BudgetName": "sillalibre-monthly-forecast",
    "BudgetLimit": {
      "Amount": "160",
      "Unit": "USD"
    },
    "CostTypes": {
      "IncludeTax": true,
      "IncludeSubscription": true,
      "UseBlended": false
    },
    "TimeUnit": "MONTHLY",
    "TimePeriod": {
      "Start": "2026-09-01",
      "End": "2026-12-31"
    },
    "BudgetType": "COST"
  }' \
  --notifications-with-subscribers '[
    {
      "Notification": {
        "NotificationType": "FORECASTED",
        "ComparisonOperator": "GREATER_THAN",
        "Threshold": 80,
        "ThresholdType": "PERCENTAGE"
      },
      "Subscribers": [
        {
          "SubscriptionType": "EMAIL",
          "Address": "jbgm93+appbarber@gmail.com"
        }
      ]
    },
    {
      "Notification": {
        "NotificationType": "FORECASTED",
        "ComparisonOperator": "GREATER_THAN",
        "Threshold": 100,
        "ThresholdType": "PERCENTAGE"
      },
      "Subscribers": [
        {
          "SubscriptionType": "EMAIL",
          "Address": "jbgm93+appbarber@gmail.com"
        }
      ]
    }
  ]'
```

### Opción 2: AWS Console

1. Ir a **AWS Budgets** → **Create budget**
2. Seleccionar **Cost budget**
3. Configurar:
   - Budget name: `sillalibre-monthly-forecast`
   - Budget amount: $160 USD
   - Budget period: Monthly
   - Start date: 2026-09-01
4. Configurar alertas:
   - Alert 1: Forecasted > 80% → Email jbgm93+appbarber@gmail.com
   - Alert 2: Forecasted > 100% → Email jbgm93+appbarber@gmail.com
5. Create budget

## Tags para Cost Allocation

Aplicar a todos los recursos AWS:

| Tag Key | Tag Value | Descripción |
|---------|-----------|-------------|
| `Project` | `SillaLibre` | Nombre del proyecto |
| `Environment` | `dev` o `prod` | Entorno de despliegue |
| `Service` | `<nombre-servicio>` | Nombre del microservicio |
| `ManagedBy` | `Terraform` | Gestión de infraestructura |

## Verificación

```bash
# Listar presupuestos
aws budgets describe-budgets --account-id $(aws sts get-caller-identity --query Account --output text)

# Verificar alertas
aws budgets describe-notifications-for-budget --account-id $(aws sts get-caller-identity --query Account --output text) --budget-name sillalibre-monthly-forecast
```

---

> **Archivo:** `artifacts/HU/HU-ENA-0-01/aws-budget-config.md`
> **Creado por:** Product Owner Agent
> **Fecha:** 2026-09-24
