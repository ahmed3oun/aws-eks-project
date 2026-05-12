locals {
  env = terraform.workspace
  private_subnet_sg_inbound_rules = {
    for id, rule in csvdecode(file("./sg_rules.csv")) :
    id => {
      name                       = rule["protocol"]
      rule_type                  = rule["rule_type"]
      protocol                   = rule["protocol"]
      priority                   = rule["priority"]
      access                     = rule["access"]
      source_port_range          = rule["source_port_range"]
      destination_port_range     = rule["destination_port_range"]
      source_address_prefix_cidr = rule["source_address_prefix_cidr"]
      destination_address_prefix = rule["destination_address_prefix"]
    }
    if rule["sg_name"] == "private-sg" && rule["rule_type"] == "ingress"
  }
  public_subnet_sg_inbound_rules = {
    for id, rule in csvdecode(file("./sg_rules.csv")) :
    id => {
      name                       = rule["protocol"]
      rule_type                  = rule["rule_type"]
      protocol                   = rule["protocol"]
      priority                   = rule["priority"]
      access                     = rule["access"]
      source_port_range          = rule["source_port_range"]
      destination_port_range     = rule["destination_port_range"]
      source_address_prefix_cidr = rule["source_address_prefix_cidr"]
      destination_address_prefix = rule["destination_address_prefix"]
    }
    if rule["sg_name"] == "public-sg" && rule["rule_type"] == "ingress"
  }
  devops_users = data.aws_iam_group.admins.users[*].arn
  eks_access_entries_devops = flatten([
    for user_arn in local.devops_users : {
      cluster_name  = "${var.fullname}-${local.env}-eks-cluster"
      principal_arn = user_arn
    }
  ])
}
