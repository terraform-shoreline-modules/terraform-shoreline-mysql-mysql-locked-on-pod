terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "unresponsive_mysql_service_on_pod_with_database_lock" {
  source    = "./modules/unresponsive_mysql_service_on_pod_with_database_lock"

  providers = {
    shoreline = shoreline
  }
}