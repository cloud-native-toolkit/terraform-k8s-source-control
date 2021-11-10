
locals {
  tmp_dir       = "${path.cwd}/.tmp"
  bin_dir       = module.setup_clis.bin_dir
  gitops_dir    = var.gitops_dir != "" ? var.gitops_dir : "${path.cwd}/gitops"
  chart_name    = "sourcecontrol"
  chart_dir     = "${local.gitops_dir}/${local.chart_name}"
  release_name  = "sourcecontrol"
  display_name  = var.type == "github" ? "GitHub" : title(var.type)
  github_img_url = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTAyNCIgaGVpZ2h0PSIxMDI0IiB2aWV3Qm94PSIwIDAgMTAyNCAxMDI0IiBmaWxsPSJub25lIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgo8cGF0aCBmaWxsLXJ1bGU9ImV2ZW5vZGQiIGNsaXAtcnVsZT0iZXZlbm9kZCIgZD0iTTggMEMzLjU4IDAgMCAzLjU4IDAgOEMwIDExLjU0IDIuMjkgMTQuNTMgNS40NyAxNS41OUM1Ljg3IDE1LjY2IDYuMDIgMTUuNDIgNi4wMiAxNS4yMUM2LjAyIDE1LjAyIDYuMDEgMTQuMzkgNi4wMSAxMy43MkM0IDE0LjA5IDMuNDggMTMuMjMgMy4zMiAxMi43OEMzLjIzIDEyLjU1IDIuODQgMTEuODQgMi41IDExLjY1QzIuMjIgMTEuNSAxLjgyIDExLjEzIDIuNDkgMTEuMTJDMy4xMiAxMS4xMSAzLjU3IDExLjcgMy43MiAxMS45NEM0LjQ0IDEzLjE1IDUuNTkgMTIuODEgNi4wNSAxMi42QzYuMTIgMTIuMDggNi4zMyAxMS43MyA2LjU2IDExLjUzQzQuNzggMTEuMzMgMi45MiAxMC42NCAyLjkyIDcuNThDMi45MiA2LjcxIDMuMjMgNS45OSAzLjc0IDUuNDNDMy42NiA1LjIzIDMuMzggNC40MSAzLjgyIDMuMzFDMy44MiAzLjMxIDQuNDkgMy4xIDYuMDIgNC4xM0M2LjY2IDMuOTUgNy4zNCAzLjg2IDguMDIgMy44NkM4LjcgMy44NiA5LjM4IDMuOTUgMTAuMDIgNC4xM0MxMS41NSAzLjA5IDEyLjIyIDMuMzEgMTIuMjIgMy4zMUMxMi42NiA0LjQxIDEyLjM4IDUuMjMgMTIuMyA1LjQzQzEyLjgxIDUuOTkgMTMuMTIgNi43IDEzLjEyIDcuNThDMTMuMTIgMTAuNjUgMTEuMjUgMTEuMzMgOS40NyAxMS41M0M5Ljc2IDExLjc4IDEwLjAxIDEyLjI2IDEwLjAxIDEzLjAxQzEwLjAxIDE0LjA4IDEwIDE0Ljk0IDEwIDE1LjIxQzEwIDE1LjQyIDEwLjE1IDE1LjY3IDEwLjU1IDE1LjU5QzEzLjcxIDE0LjUzIDE2IDExLjUzIDE2IDhDMTYgMy41OCAxMi40MiAwIDggMFoiIHRyYW5zZm9ybT0ic2NhbGUoNjQpIiBmaWxsPSIjMUIxRjIzIi8+Cjwvc3ZnPgo="
  gitlab_img_url = "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjUwMCIgaGVpZ2h0PSIyMzA1IiB2aWV3Qm94PSIwIDAgMjU2IDIzNiIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiBwcmVzZXJ2ZUFzcGVjdFJhdGlvPSJ4TWluWU1pbiBtZWV0Ij48cGF0aCBkPSJNMTI4LjA3NSAyMzYuMDc1bDQ3LjEwNC0xNDQuOTdIODAuOTdsNDcuMTA0IDE0NC45N3oiIGZpbGw9IiNFMjQzMjkiLz48cGF0aCBkPSJNMTI4LjA3NSAyMzYuMDc0TDgwLjk3IDkxLjEwNEgxNC45NTZsMTEzLjExOSAxNDQuOTd6IiBmaWxsPSIjRkM2RDI2Ii8+PHBhdGggZD0iTTE0Ljk1NiA5MS4xMDRMLjY0MiAxMzUuMTZhOS43NTIgOS43NTIgMCAwIDAgMy41NDIgMTAuOTAzbDEyMy44OTEgOTAuMDEyLTExMy4xMi0xNDQuOTd6IiBmaWxsPSIjRkNBMzI2Ii8+PHBhdGggZD0iTTE0Ljk1NiA5MS4xMDVIODAuOTdMNTIuNjAxIDMuNzljLTEuNDYtNC40OTMtNy44MTYtNC40OTItOS4yNzUgMGwtMjguMzcgODcuMzE1eiIgZmlsbD0iI0UyNDMyOSIvPjxwYXRoIGQ9Ik0xMjguMDc1IDIzNi4wNzRsNDcuMTA0LTE0NC45N2g2Ni4wMTVsLTExMy4xMiAxNDQuOTd6IiBmaWxsPSIjRkM2RDI2Ii8+PHBhdGggZD0iTTI0MS4xOTQgOTEuMTA0bDE0LjMxNCA0NC4wNTZhOS43NTIgOS43NTIgMCAwIDEtMy41NDMgMTAuOTAzbC0xMjMuODkgOTAuMDEyIDExMy4xMTktMTQ0Ljk3eiIgZmlsbD0iI0ZDQTMyNiIvPjxwYXRoIGQ9Ik0yNDEuMTk0IDkxLjEwNWgtNjYuMDE1bDI4LjM3LTg3LjMxNWMxLjQ2LTQuNDkzIDcuODE2LTQuNDkyIDkuMjc1IDBsMjguMzcgODcuMzE1eiIgZmlsbD0iI0UyNDMyOSIvPjwvc3ZnPg=="
  git_img_url    = "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBzdGFuZGFsb25lPSJubyI/Pgo8IURPQ1RZUEUgc3ZnIFBVQkxJQyAiLS8vVzNDLy9EVEQgU1ZHIDIwMDEwOTA0Ly9FTiIKICJodHRwOi8vd3d3LnczLm9yZy9UUi8yMDAxL1JFQy1TVkctMjAwMTA5MDQvRFREL3N2ZzEwLmR0ZCI+CjxzdmcgdmVyc2lvbj0iMS4wIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciCiB3aWR0aD0iOTIuMDAwMDAwcHQiIGhlaWdodD0iOTIuMDAwMDAwcHQiIHZpZXdCb3g9IjAgMCA5Mi4wMDAwMDAgOTIuMDAwMDAwIgogcHJlc2VydmVBc3BlY3RSYXRpbz0ieE1pZFlNaWQgbWVldCI+CjxtZXRhZGF0YT4KQ3JlYXRlZCBieSBwb3RyYWNlIDEuMTYsIHdyaXR0ZW4gYnkgUGV0ZXIgU2VsaW5nZXIgMjAwMS0yMDE5CjwvbWV0YWRhdGE+CjxnIHRyYW5zZm9ybT0idHJhbnNsYXRlKDAuMDAwMDAwLDkyLjAwMDAwMCkgc2NhbGUoMC4xMDAwMDAsLTAuMTAwMDAwKSIKZmlsbD0iIzAwMDAwMCIgc3Ryb2tlPSJub25lIj4KPHBhdGggZD0iTTQzNSA5MTAgYy0xMSAtNCAtMzggLTI3IC02MCAtNDkgbC0zOSAtNDEgNDkgLTUwIGMyOSAtMjkgNTggLTUwIDcxCi01MCAzNCAwIDc0IC0zNyA3NCAtNjkgMCAtMzIgODUgLTEyMSAxMTYgLTEyMSAyNiAwIDY0IC0yNyA3MyAtNTQgMjAgLTUzIC0zNwotMTA4IC05MiAtODcgLTI5IDExIC00NyAzOSAtNDcgNzMgMCAxNSAtMTYgMzkgLTQwIDYzIGwtNDAgMzkgMCAtMTIxIGMwIC05NQozIC0xMjMgMTUgLTEzMyAyMyAtMTkgMTkgLTc2IC03IC0xMDAgLTI4IC0yNiAtNTggLTI2IC05MiAxIC0zMiAyNSAtMzQgNjYgLTYKMTAyIDE3IDIyIDIwIDQwIDIwIDE0MiAwIDEwMiAtMyAxMjAgLTIwIDE0MiAtMTEgMTQgLTIwIDM4IC0yMCA1MiAwIDE5IC0xNQo0MSAtNTAgNzYgbC01MCA1MCAtMTQyIC0xNDIgYy0xMjIgLTEyMiAtMTQxIC0xNDYgLTE0MSAtMTczIDAgLTI4IDI1IC01NyAyMTEKLTI0MiAxODUgLTE4NiAyMTQgLTIxMSAyNDIgLTIxMSAyOCAwIDU2IDI1IDI0MCAyMDkgMTE0IDExNSAyMTEgMjIwIDIxNSAyMzMKNiAyMSAtMTkgNTAgLTIxNyAyNDcgLTEyMyAxMjMgLTIyOCAyMjQgLTIzMyAyMjMgLTYgMCAtMTkgLTQgLTMwIC05eiIvPgo8L2c+Cjwvc3ZnPgo="
  imageUrl      = var.type == "github" ? local.github_img_url : var.type == "gitlab" ? local.gitlab_img_url : local.git_img_url
  apply         = var.type != "" && var.type != "none"
  git_config = {
    name = "sourcecontrol"
    url = var.url
    imageUrl = local.imageUrl
    displayName = local.display_name
    category = "source"
    otherValues = {
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

resource null_resource print_toolkit_namespace {
  provisioner "local-exec" {
    command = "echo 'Toolkit namespace: ${var.toolkit_namespace}'"
  }
}

module setup_clis {
  source = "github.com/cloud-native-toolkit/terraform-util-clis.git"

  clis = ["helm"]
}

resource "local_file" "source-control-values" {
  count = local.apply ? 1 : 0
  depends_on = [null_resource.setup-chart]

  content  = yamlencode({
    git-config = local.git_config
  })
  filename = "${local.chart_dir}/values.yaml"
}

resource null_resource print-values {
  count = local.apply ? 1 : 0

  provisioner "local-exec" {
    command = "cat ${local_file.source-control-values[0].filename}"
  }
}

resource null_resource sourcecontrol_helm {
  count = local.apply ? 1 : 0
  depends_on = [local_file.source-control-values]

  provisioner "local-exec" {
    command = "${local.bin_dir}/helm template --namespace ${var.cluster_namespace} sourcecontrol ${local.chart_dir} | kubectl apply -n ${var.cluster_namespace} -f -"

    environment = {
      KUBECONFIG = var.config_file_path
    }
  }
}
