
#NOTE: This is passed in via the SHORELINE_URL env var.
#        SHORELINE_TOKEN is also required.
#variable "shoreline_url" {
#  type        = string
#  #default     = "https://test.us.api.shoreline-test4.io"
#  description = "The API URL for the shoreline service."
#}

variable "namespace" {
  type        = string
  description = "A namespace to isolate multiple instances of the module with different parameters."
  default     = "net"
}

variable "protocol" {
  type        = string
  description = "The protocol (tcp or udp) to monitor connections on."
  default     = "tcp"
}

variable "port" {
  type        = number
  description = "The local port to monitor connections on."
  default     = 5555
}

variable "connection_threshold" {
  type        = number
  description = "The high-water-mark, of connections before pods are added."
  default     = 300
}

variable "check_interval" {
  type        = number
  description = "Frequency in seconds to check alarms."
  default     = 10
}

variable "resource_query" {
  type        = string
  description = "The set of hosts/pods/containers monitored and affected by this module."
  #default     = "bookstore"
}

variable "hpa_name" {
  type        = string
  description = "The HPA (horizontal pod autoscaler) to increase."
}

variable "hpa_namespace" {
  type        = string
  description = "The kubernetes namespace for the HPA (horizontal pod autoscaler) to increase."
}

variable "increment" {
  type        = number
  description = "Maximum size limit for the horizontal pod autoscaler."
  default     = 50
}

variable "max_size" {
  type        = number
  description = "Maximum size limit for the horizontal pod autoscaler."
  default     = 50
}

variable "script_path" {
  type        = string
  description = "Destination (on selected resources) for the scripts."
  default     = "/tmp"
}

