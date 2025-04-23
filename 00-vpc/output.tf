# output "azs_info" {
#   value = module.vpc.azs_info
# }

# output "public_subnet_info" {
#   value = module.vpc.public_subnet_info
# }

# output "eip_info" {
#   value = module.vpc.eip_info
# }

# output "default_vpc_info" {
#   value = module.vpc.default_vpc_info
# }

output "default_vpc_main_rt_id" {
  value = module.vpc.default_vpc_main_rt_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}