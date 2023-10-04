resource "shoreline_notebook" "unresponsive_mysql_service_on_pod_with_database_lock" {
  name       = "unresponsive_mysql_service_on_pod_with_database_lock"
  data       = file("${path.module}/data/unresponsive_mysql_service_on_pod_with_database_lock.json")
  depends_on = [shoreline_action.invoke_list_pods,shoreline_action.invoke_lock_cleanup]
}

resource "shoreline_file" "list_pods" {
  name             = "list_pods"
  input_file       = "${path.module}/data/list_pods.sh"
  md5              = filemd5("${path.module}/data/list_pods.sh")
  description      = "Next Step"
  destination_path = "/agent/scripts/list_pods.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "lock_cleanup" {
  name             = "lock_cleanup"
  input_file       = "${path.module}/data/lock_cleanup.sh"
  md5              = filemd5("${path.module}/data/lock_cleanup.sh")
  description      = "If the locks cannot be released, try restarting the MySQL service or the entire pod to clear all locks."
  destination_path = "/agent/scripts/lock_cleanup.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_list_pods" {
  name        = "invoke_list_pods"
  description = "Next Step"
  command     = "`chmod +x /agent/scripts/list_pods.sh && /agent/scripts/list_pods.sh`"
  params      = []
  file_deps   = ["list_pods"]
  enabled     = true
  depends_on  = [shoreline_file.list_pods]
}

resource "shoreline_action" "invoke_lock_cleanup" {
  name        = "invoke_lock_cleanup"
  description = "If the locks cannot be released, try restarting the MySQL service or the entire pod to clear all locks."
  command     = "`chmod +x /agent/scripts/lock_cleanup.sh && /agent/scripts/lock_cleanup.sh`"
  params      = ["MYSQL_SERVICE_NAME","NAMESPACE","MYSQL_USER","POD_NAME","MYSQL_PASSWORD"]
  file_deps   = ["lock_cleanup"]
  enabled     = true
  depends_on  = [shoreline_file.lock_cleanup]
}

