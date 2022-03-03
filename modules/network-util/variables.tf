
#NOTE: This is passed in via the SHORELINE_URL env var.
#        SHORELINE_TOKEN is also required.
#variable "shoreline_url" {
#  type        = string
#  #default     = "https://test.us.api.shoreline-test4.io"
#  description = "The API URL for the shoreline service."
#}

variable "prefix" {
  type        = string
  description = "A prefix to isolate multiple instances of the module with different parameters."
  default     = "net_"
}


