
variable "instances" {
  type = map(object({
    instance_type = string
    volume_type   = string
    volume_size   = number
    key_name      = string
  }))
}

variable "ami" {
  type        = string
  description = "AMI ID used for the EC2 instances"
}
