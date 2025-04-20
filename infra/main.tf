# Configuración del proveedor Azure
 provider "azurerm" {
   features {}
   subscription_id = "fab7526b-56a5-4c43-9ba1-85eb890d86d5"
 }
 
 # Referencia al resource group existente
 data "azurerm_resource_group" "taller1" {
   name = "taller1"
 }
 
 # Referencia al Azure Container Registry existente
 data "azurerm_container_registry" "taller1" {
   name                = "taller1"
   resource_group_name = data.azurerm_resource_group.taller1.name
 }
 
 # Creación del entorno de Container Apps
 resource "azurerm_container_app_environment" "microservices" {
   name                = "microservices-env"
   resource_group_name = data.azurerm_resource_group.taller1.name
   location            = data.azurerm_resource_group.taller1.location
 }
 
 # Configuración común para todos los Container Apps
 locals {
   container_apps = {
     auth_api = {
       name      = "auth-api"
       image     = "${data.azurerm_container_registry.taller1.login_server}/auth-api:latest"
       port      = 8081
       cpu       = 0.5
       memory    = "1Gi"
       min_replicas = 1
       max_replicas = 2
       env_vars = {
         JWT_SECRET       = "PRFT"
         AUTH_API_PORT    = "8081"
         USERS_API_ADDRESS = "http://users-api:8083" # Usamos nombre DNS interno
       }
     }
     frontend = {
       name      = "frontend"
       image     = "${data.azurerm_container_registry.taller1.login_server}/frontend:latest"
       port      = 8080
       cpu       = 0.5
       memory    = "1Gi"
       min_replicas = 1
       max_replicas = 3
       env_vars = {
         PORT              = "8080"
         AUTH_API_ADDRESS  = "http://auth-api:8081" # DNS interno
         TODOS_API_ADDRESS = "http://todos-api:8082" # DNS interno
       }
     }
     log_processor = {
       name      = "log-message-processor"
       image     = "${data.azurerm_container_registry.taller1.login_server}/log-message-processor:latest"
       port      = null # No expuesto públicamente
       cpu       = 0.5
       memory    = "1Gi"
       min_replicas = 1
       max_replicas = 1
       env_vars = {
         REDIS_HOST    = "redis"
         REDIS_PORT    = "6379"
         REDIS_CHANNEL = "log_channel"
       }
     }
     todos_api = {
       name      = "todos-api"
       image     = "${data.azurerm_container_registry.taller1.login_server}/todos-api:latest"
       port      = 8082
       cpu       = 0.5
       memory    = "1Gi"
       min_replicas = 1
       max_replicas = 2
       env_vars = {
         TODO_API_PORT = "8082"
         JWT_SECRET    = "PRFT"
         REDIS_HOST    = "redis"
         REDIS_PORT    = "6379"
         REDIS_CHANNEL = "log_channel"
       }
     }
     users_api = {
       name      = "users-api"
       image     = "${data.azurerm_container_registry.taller1.login_server}/users-api:latest"
       port      = 8083
       cpu       = 0.5
       memory    = "1Gi"
       min_replicas = 1
       max_replicas = 2
       env_vars = {
         JWT_SECRET  = "PRFT"
         SERVER_PORT = "8083"
       }
     },
     # Patron 
     redis = {
       name      = "redis"
       image     = "docker.io/redis:7.0"
       port      = 6379
       cpu       = 0.5
       memory    = "1Gi"
       min_replicas = 1
       max_replicas = 1
       env_vars = {}
     }
   }
 }
 
 # Creación de los Container Apps usando un bucle
 resource "azurerm_container_app" "app" {
   for_each = local.container_apps
 
   name                         = each.value.name
   container_app_environment_id = azurerm_container_app_environment.microservices.id
   resource_group_name          = data.azurerm_resource_group.taller1.name
   revision_mode                = "Single"
 
   template {
     container {
       name   = "${each.value.name}-container"
       image  = each.value.image
       cpu    = each.value.cpu
       memory = each.value.memory
 
       dynamic "env" {
         for_each = each.value.env_vars
         content {
           name  = env.key
           value = env.value
         }
       }
     }
 
     min_replicas = each.value.min_replicas
     max_replicas = each.value.max_replicas
   }
 
   dynamic "ingress" {
     for_each = each.value.port != null ? [1] : []
     content {
       external_enabled = true
       target_port     = each.value.port
       traffic_weight {
         percentage      = 100
         latest_revision = true
       }
     }
   }
 
   secret {
     name  = "acr-password"
     value = data.azurerm_container_registry.taller1.admin_password
   }
 
   registry {
     server               = data.azurerm_container_registry.taller1.login_server
     username             = data.azurerm_container_registry.taller1.admin_username
     password_secret_name = "acr-password"
   }
 }
 
 # Outputs útiles
 output "frontend_url" {
   value = "http://${azurerm_container_app.app["frontend"].ingress[0].fqdn}"
 }
 
 output "auth_api_url" {
   value = "http://${azurerm_container_app.app["auth_api"].ingress[0].fqdn}:8081"  # Cambiado a 8081
 }
 
 output "todos_api_url" {
   value = "http://${azurerm_container_app.app["todos_api"].ingress[0].fqdn}:8082"
 }
 
 output "users_api_url" {
   value = "http://${azurerm_container_app.app["users_api"].ingress[0].fqdn}:8083"