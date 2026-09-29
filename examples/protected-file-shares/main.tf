module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "prd"]
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

module "storage" {
  source  = "codectl/sa/azure"
  version = "~> 1.0"


  storage = {
    name                = module.naming.storage_account.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    share_properties = {
      smb = {
        versions             = ["SMB3.1.1"]
        authentication_types = ["Kerberos"]
      }

      shares = {
        fs1 = {
          quota = 50
          metadata = {
            environment = "dev"
            owner       = "finance team"
          }
        }
        fs2 = {
          quota = 50
          metadata = {
            environment = "dev"
            owner       = "marketing team"
          }
        }
      }
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
    policies            = local.policies
  }
}
