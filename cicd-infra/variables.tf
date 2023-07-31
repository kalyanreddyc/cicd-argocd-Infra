variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}
variable "vpc" {
   description = "vpc id"
   default     = "vpc-06fac6ced71fe52da"
}

variable "instance_ami" {
     default = "ami-026ebd4cfe2c043b2"
}

variable "instance_type" {
  default  = "t2.xlarge"

}

variable "public_subnet" {
   default = "subnet-01c1008dd8460baf6"
}

variable "key_name" {
  default = "kalyancisco"
}
