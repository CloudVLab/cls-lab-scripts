## --------------------------------------------------------------
## Custom variable defintions
## --------------------------------------------------------------


output "project_id" {
  value = var.gcp_project_id
}

output "random_zone" {
  value = "${local.random_zone}"
}

output "random_integer" {
  value = "${local.my_random_integer}"
}