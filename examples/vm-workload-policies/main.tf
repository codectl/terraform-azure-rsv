module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "regions" {
  source  = "codectl/locations/azure"
  version = "~> 1.0"

  location = {
    primary = "westeurope"
  }
}

module "rg" {
  source  = "codectl/rg/azure"
  version = "~> 1.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = module.regions.location.primary.name
    }
  }
}

module "rsv" {
  source  = "codectl/rsv/azure"
  version = "~> 1.0"

  vault = {
    name                = module.naming.recovery_services_vault.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    policies = {
      vm_workloads = {
        sqlserver = {
          workload_type = "SQLDataBase"
          settings = {
            time_zone           = "UTC"
            compression_enabled = false
          }
          protection_policies = {
            full = {
              policy_type = "Full"
              backup = {
                frequency = "Weekly"
                time      = "23:00"
                weekdays  = ["Sunday"]
              }
              retention_weekly = {
                count    = 8
                weekdays = ["Sunday"]
              }
            }
            log = {
              policy_type = "Log"
              backup = {
                frequency_in_minutes = 15
              }
              simple_retention = {
                count = 8
              }
            }
          }
        }
      }
    }
  }
}
