variable "name" {
  type        = string
  default     = null
}

variable "billing_mode" {
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "write_capacity" {
  type        = number
  default     = null
}

variable "read_capacity" {
  type        = number
  default     = null
}

variable "stream_enabled" {
  type        = bool
  default     = false
}

variable "stream_view_type" {
  type        = string
  default     = null
}

variable "tags" {
  type = map(string)
}

