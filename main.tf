
locals {
  tmp_dir               = "${path.cwd}/.tmp"
  gitops_dir            = var.gitops_dir != "" ? var.gitops_dir : "${path.cwd}/gitops"
  chart_name            = "sourcecontrol"
  chart_dir             = "${local.gitops_dir}/${local.chart_name}"
  release_name          = "sourcecontrol"
  display_name          = var.type == "github" ? "GitHub" : title(var.type)
  apply                 = var.type != "" && var.type != "none"
  global_config = {
    clusterType = var.cluster_type_code
  }
  github_config = {
    name = "sourcecontrol"
    type = var.type
    displayName = local.display_name
    url = var.url
    applicationMenu = true
    otherConfig = {
      type = var.type
    }
  }
}

resource "null_resource" "create_dirs" {
  count = local.apply ? 1 : 0

  provisioner "local-exec" {
    command = "mkdir -p ${local.tmp_dir}"
  }

  provisioner "local-exec" {
    command = "mkdir -p ${local.gitops_dir}"
  }
}

resource "null_resource" "setup-chart" {
  count = local.apply ? 1 : 0
  depends_on = [null_resource.create_dirs]

  provisioner "local-exec" {
    command = "mkdir -p ${local.chart_dir} && cp -R ${path.module}/chart/${local.chart_name}/* ${local.chart_dir}"
  }
}

resource "null_resource" "delete-helm-source-control" {
  count = local.apply ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl delete secret -n ${var.cluster_namespace} -l name=${local.release_name} --ignore-not-found"

    environment = {
      KUBECONFIG = var.config_file_path
    }
  }

  provisioner "local-exec" {
    command = "kubectl delete configmap -n ${var.cluster_namespace} -l name=${local.release_name} --ignore-not-found"

    environment = {
      KUBECONFIG = var.config_file_path
    }
  }

  provisioner "local-exec" {
    command = "kubectl delete secret -n ${var.cluster_namespace} github-access --ignore-not-found"

    environment = {
      KUBECONFIG = var.config_file_path
    }
  }

  provisioner "local-exec" {
    command = "kubectl delete configmap -n ${var.cluster_namespace} github-config --ignore-not-found"

    environment = {
      KUBECONFIG = var.config_file_path
    }
  }

  provisioner "local-exec" {
    command = "kubectl delete secret -n ${var.cluster_namespace} sourcecontrol-access --ignore-not-found"

    environment = {
      KUBECONFIG = var.config_file_path
    }
  }

  provisioner "local-exec" {
    command = "kubectl delete configmap -n ${var.cluster_namespace} sourcecontrol-config --ignore-not-found"

    environment = {
      KUBECONFIG = var.config_file_path
    }
  }
}

resource "null_resource" "delete-consolelink" {
  count      = var.cluster_type_code == "ocp4" && local.apply ? 1 : 0

  provisioner "local-exec" {
    command = "kubectl delete consolelink toolkit-github --ignore-not-found"

    environment = {
      KUBECONFIG = var.config_file_path
    }
  }

  provisioner "local-exec" {
    command = "kubectl delete consolelink toolkit-sourcecontrol --ignore-not-found"

    environment = {
      KUBECONFIG = var.config_file_path
    }
  }
}

resource "local_file" "source-control-values" {
  count = local.apply ? 1 : 0
  depends_on = [null_resource.setup-chart]

  content  = yamlencode({
    global = local.global_config
    tool-config = local.github_config
  })
  filename = "${local.chart_dir}/values.yaml"
}

resource "null_resource" "print-values" {
  count = local.apply ? 1 : 0

  provisioner "local-exec" {
    command = "cat ${local_file.source-control-values[0].filename}"
  }
}

resource "helm_release" "sourcecontrol_setup" {
  count = local.apply ? 1 : 0
  depends_on = [null_resource.delete-helm-source-control, null_resource.delete-consolelink, local_file.source-control-values]

  name              = local.release_name
  chart             = local.chart_dir
  namespace         = var.cluster_namespace
  timeout           = 1200
  dependency_update = true
  force_update      = true
  replace           = true

  disable_openapi_validation = true
}
