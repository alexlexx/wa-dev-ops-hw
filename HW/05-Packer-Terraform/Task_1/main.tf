provider "gitlab" {
  # Configuration options
  base_url = "https://mygitlab.local/api/v4"
  token = var.gitlab_token
  insecure = true
}

resource "gitlab_group" "example_2" {
  name        = "example_2"
  path        = "example_2"
  description = "An example_2 group"
}

resource "gitlab_project" "example_2" {
  name        = "example_2"
  description = "My example_3 project"

  visibility_level = "public"
}

resource "gitlab_group_access_token" "gat_example" {
  group        = gitlab_group.example_2.id
  name         = "Example group access token"
  expires_at   = "2025-03-14"
  access_level = "developer"

  scopes = ["api"]
}

resource "gitlab_group_variable" "group_token" {
  group = gitlab_group.example_2.id
  key   = "GROUP_TOKEN"
  value = gitlab_group_access_token.gat_example.token
}

resource "gitlab_deploy_token" "gdt_example" {
  group = gitlab_group.example_2.id
  name  = "Example group deploy token"

  scopes = ["read_repository"]
}

resource "gitlab_group_variable" "deploy_token" {
  group = gitlab_group.example_2.id
  key   = "DEPLOY_TOKEN"
  value = gitlab_deploy_token.gdt_example.token
}

resource "gitlab_branch_protection" "gbp_example" {
  project                = gitlab_project.example_2.id
  branch                 = "main"
  push_access_level      = "maintainer"
  merge_access_level     = "maintainer"
  unprotect_access_level = "maintainer"

  depends_on = [
    gitlab_project.example_2
  ]
}
