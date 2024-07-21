provider "gitlab" {
  # Configuration options
  base_url = "https://mygitlab.local/api/v4"
  token = var.gitlab_token
  insecure = true
}

resource "gitlab_group" "example_group" {
  name        = var.group_name
  path        = var.group_name
  description = "An example_group"
}

resource "gitlab_project" "example_project" {
  name        = var.project_name
  description = "My example_project"

  visibility_level = "public"
}

resource "gitlab_group_access_token" "gat_example" {
  group        = gitlab_group.example_group.id
  name         = "Example group access token"
  expires_at   = "2025-03-14"
  access_level = "developer"

  scopes = ["api"]
}

resource "gitlab_group_variable" "group_token" {
  group = gitlab_group.example_group.id
  key   = "GROUP_TOKEN"
  value = gitlab_group_access_token.gat_example.token
}

resource "gitlab_deploy_token" "gdt_example" {
  count = var.create_deploy_token ? 1 : 0

  group = gitlab_group.example_group.id
  name  = "deploy_toke_${count.index}"

  scopes = ["read_repository"]
}

resource "gitlab_group_variable" "deploy_token" {
  count = var.create_deploy_token ? 1 : 0

  group = gitlab_group.example_group.id
  key   = "DEPLOY_TOKEN"
  value = gitlab_deploy_token.gdt_example[count.index].token
}

resource "gitlab_branch_protection" "gbp_example" {
  project                = gitlab_project.example_project.id
  branch                 = "main"
  push_access_level      = "maintainer"
  merge_access_level     = "maintainer"
  unprotect_access_level = "maintainer"

  depends_on = [
    gitlab_project.example_project
  ]
}
