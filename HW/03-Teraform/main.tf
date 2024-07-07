provider "gitlab" {
  # Configuration options
  base_url = "https://mygitlab.local/api/v4"
  token = var.gitlab_token
  insecure = true
}

resource "gitlab_group" "example" {
  name        = "example"
  path        = "example"
  description = "An example group"
}

resource "gitlab_group_variable" "example" {
  group             =  gitlab_group.example.id
  key               = "group_variable_key"
  value             = "group_variable_value"
  protected         = false
  masked            = false
  environment_scope = "*"
}

resource "gitlab_project" "example" {
  name        = "example"
  description = "My awesome codebase"

  visibility_level = "public"
}

resource "gitlab_project_access_token" "example" {
  project      = gitlab_project.example.id
  name         = "Example project access token"
  expires_at   = "2025-01-01"
  access_level = "reporter"

  scopes = ["api"]
}
