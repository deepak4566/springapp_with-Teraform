output "application_load_balancer" {
    value = module.application_load_balancer
}
output "security_group" {
    value = module.security_group
}
output "ec2" {
    value = module.ec2
}
output "vpc" {
    value = module.vpc
}
output "rds" {
    value = module.rds
	sensitive = true
}
