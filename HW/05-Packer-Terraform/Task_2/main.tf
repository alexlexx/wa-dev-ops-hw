module "terraform_gitlab_module" {
    source  = "./gitlab_module"
    gitlab_token = var.gitlab_token
    project_name = "project_3"
    group_name = "group_3"
    create_deploy_token = false
}
