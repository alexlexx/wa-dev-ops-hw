variable "gitlab_token" {
  description = "Gitlab token"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Project name"
  type = string
}

variable "group_name" {
  description = "Group name"
  type = string
}

variable "create_deploy_token" {
  description = "Is deploy token must be created" 
  type = bool
}
