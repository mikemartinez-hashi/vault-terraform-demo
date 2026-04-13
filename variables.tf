variable "region" {
  type        = string
  description = "AWS Region"
}

variable "instance_type" {
  type        = string
  description = "EC2 Instance Type"
  default     = "t3.medium"
  # default     = "t3.large"
  # default     = "t3.micro"
}

# variable "ami" {
#   type        = string
#   description = "AMI for EC2 Instance"
# }

# variable "allow_sg" {
#   type        = string
#   description = "AMI for EC2 Instance"
#   default     = "sg-001c64f56592ce4ee"
# }

variable "key_name" {
  type        = string
  description = "The name of the existing key pair for SSH access"
  default     = "linux-demo-kp"
}

variable "server" {
  #type = map(string)
  type    = string
  default = "web-server"
}

variable "demo" {
  #type = map(string)
  type    = string
  default = "tf-demo"
}
variable "environment" {
  #type = map(string)
  type        = string
  description = "Environment Type"
}

variable "owner" {
  #type = map(string)
  type    = string
  default = "SE Team"
}
