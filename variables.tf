
variable "config_file_path" {
  type        = string
  description = "The path to the kube config"
}

variable "gitops_dir" {
  type        = string
  description = "The directory where the gitops configuration should be stored"
  default     = ""
}

variable "cluster_type_code" {
  type        = string
  description = "The cluster_type of the cluster"
  default     = "ocp4"
}

variable "cluster_namespace" {
  type        = string
  description = "The namespace in the cluster where the configuration should be created (e.g. tools)"
}

variable "type" {
  type        = string
  description = "The type of source control system (github or gitlab) currently"
}

variable "url" {
  type        = string
  description = "The url to the git host (base git host, org, or repo url)"
}

variable "toolkit_namespace" {
  type        = string
  description = "Namespace where the toolkit config jobs run."
  default     = ""
}
