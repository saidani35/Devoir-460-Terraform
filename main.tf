############################
# Resource Group (Q7)
############################

#resource "azurerm_resource_group" "rg_cr460" {
# name     = "rg-cr460-malika"
#location = "Canada Central"
#}

resource "azurerm_resource_group" "rg_cr460" {
  name     = var.resource_group_name
  location = var.location
}
############################
# Réseau virtuel / Sous-réseau / NIC (Q8)
############################

# Réseau virtuel
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_cr460.name

  tags = {
    Projet = "DevoirCR460"
  }
}

# Sous-réseau
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-${var.prefix}"
  resource_group_name  = azurerm_resource_group.rg_cr460.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Interface réseau
resource "azurerm_network_interface" "nic" {
  name                = "nic-${var.prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_cr460.name

  ip_configuration {
    name                          = "ipconfig-${var.prefix}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    Projet = "DevoirCR460"
  }
}


############################
# Azure Key Vault (Q12)
############################

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                = "malika-cr460-kv"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_cr460.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set"
    ]
  }

  tags = {
    Projet = "DevoirCR460"
  }
}

resource "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-admin-password"
  value        = var.admin_password
  key_vault_id = azurerm_key_vault.kv.id
}

############################
# Machine virtuelle (Q9)
############################

resource "azurerm_virtual_machine" "vm" {
  name                = "${var.prefix}-vm"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_cr460.name

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  vm_size = var.vm_size

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk-${var.prefix}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = substr(lower(replace(var.prefix, "_", "-")), 0, 12)
    admin_username = var.admin_username
    admin_password = azurerm_key_vault_secret.vm_password.value
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  # Q13 - Gestion des coûts
  tags = {
    Projet = "DevoirCR460"
  }
}

############################
# Conteneur Azure (Q10)
############################

resource "azurerm_container_group" "container" {
  name                = "${var.prefix}-container"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_cr460.name
  os_type             = "Linux"
  ip_address_type     = "Public"

  dns_name_label = lower(replace(var.prefix, "_", "-"))

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.acr_identity.id
    ]
  }

  image_registry_credential {
    server                    = "acrcr460malika4073.azurecr.io"
    user_assigned_identity_id = azurerm_user_assigned_identity.acr_identity.id
  }

  container {
    name   = "hello-world"
    image  = "acrcr460malika4073.azurecr.io/nginx:latest"
    cpu    = 0.5
    memory = 1.5

    ports {
      port     = 80
      protocol = "TCP"
    }
  }

  tags = {
    Projet = "DevoirCR460"
  }

  depends_on = [
    azurerm_role_assignment.acr_pull
  ]
}

resource "azurerm_user_assigned_identity" "acr_identity" {
  name                = "id-acr-cr460-malika"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_cr460.name

  tags = {
    Projet = "DevoirCR460"
  }
}

data "azurerm_container_registry" "acr" {
  name                = "acrcr460malika4073"
  resource_group_name = azurerm_resource_group.rg_cr460.name
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = data.azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.acr_identity.principal_id
}
