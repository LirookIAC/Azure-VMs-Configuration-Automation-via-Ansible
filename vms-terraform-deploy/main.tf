resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "centralindia"
}

resource "azurerm_public_ip" "example" {
  for_each = var.vms
  name                = "${each.value.name}-public-ip"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.3.0/24"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.3.0/25"]
}

resource "azurerm_network_interface" "example" {
  for_each = var.vms
  name                = "${each.value.name}-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.example[each.key].id
  }
}

resource "azurerm_network_interface_security_group_association" "example" {
  for_each = var.vms
  network_interface_id      = azurerm_network_interface.example[each.key].id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_linux_virtual_machine" "example" {
  for_each = var.vms
  name                = each.value.name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B1s"
  admin_username      = "student"
  admin_password = "Password@1234"
  network_interface_ids = [
    azurerm_network_interface.example[each.key].id,
  ]
  boot_diagnostics {}
  disable_password_authentication = false
  # priority = "Spot"
  # eviction_policy = "Deallocate"
  custom_data = filebase64("${path.module}/cloud-init.yaml")
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
    version   = each.value.version
  }
dynamic "plan" {
    # Only create the block if plan_info exists for this VM
    for_each = each.value.plan_required ? [1] : []
    
    content {
      name      = each.value.offer
      publisher = each.value.publisher
      product   = each.value.sku # Often SKU and Product are the same for Rocky/SLES
    }
  }
}



resource "azurerm_network_security_group" "example" {
  name                = "myNSG"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "AllowICMP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "Allow161UDP"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "161"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_managed_disk" "example1" {
  for_each = { for k, v in var.vms : k => v if v.data_disk_enabled }
  name                = "${each.value.name}-data-disk1"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  storage_account_type = "Standard_LRS"
  disk_size_gb        = 10
  create_option       = "Empty"
}

resource "azurerm_virtual_machine_data_disk_attachment" "example1" {
  for_each = { for k, v in var.vms : k => v if v.data_disk_enabled }
  managed_disk_id    = azurerm_managed_disk.example1[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.example[each.key].id
  lun                = 10
  caching            = "ReadWrite"
}

resource "azurerm_managed_disk" "example2" {
  for_each = { for k, v in var.vms : k => v if v.data_disk_enabled }
  name                = "${each.value.name}-data-disk2"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  storage_account_type = "Standard_LRS"
  disk_size_gb        = 10
  create_option       = "Empty"
}

resource "azurerm_virtual_machine_data_disk_attachment" "example2" {
  for_each = { for k, v in var.vms : k => v if v.data_disk_enabled }
  managed_disk_id    = azurerm_managed_disk.example2[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.example[each.key].id
  lun                = 11
  caching            = "ReadWrite"
}

output "VMs" {
  value = {
    for vm_key, vm in var.vms : vm_key => {
      name       = azurerm_linux_virtual_machine.example[vm_key].name
      public_ip  = azurerm_public_ip.example[vm_key].ip_address
      private_ip = azurerm_network_interface.example[vm_key].private_ip_address
    }
  }
}
