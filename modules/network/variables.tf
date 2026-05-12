variable "fullname" {
  type = string
}

variable "env" {
  type = string
}
variable "tags" {
  type = map(string)
}

variable "cidr_block" {
  type = string
}

variable "public_subnets" {
  type = list(object({
    name              = string
    cidr_block        = string
    availability_zone = string
  }))
}

variable "private_subnets" {
  type = list(object({
    name              = string
    cidr_block        = string
    availability_zone = string
  }))
}

variable "public_subnet_sg_inbound_rules" {
  type = map(object({
    name                       = string
    rule_type                  = string
    protocol                   = string
    priority                   = number
    access                     = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix_cidr = string
    destination_address_prefix = string
  }))
}

variable "private_subnet_sg_inbound_rules" {
  type = map(object({
    name                       = string
    rule_type                  = string
    protocol                   = string
    priority                   = number
    access                     = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix_cidr = string
    destination_address_prefix = string
  }))
}
