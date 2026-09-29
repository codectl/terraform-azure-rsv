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
      vms = {
        daily = {
          timezone = "UTC"
          backup = {
            frequency = "Daily"
            time      = "23:00"
          }
          retention = {
            daily = {
              count = 7
            }
            weekly = {
              count    = 2
              weekdays = ["Monday", "Wednesday"]
            }
          }
        }
      }
    }
  }
}
