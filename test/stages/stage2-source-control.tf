module "dev_tools_source-control" {
  source = "./module"

  config_file_path = module.dev_cluster.config_file_path
  cluster_type_code = module.dev_cluster.type_code
  cluster_namespace = module.dev_capture_tools_state.namespace
  type = "github"
  url = "https://github.com"
}
