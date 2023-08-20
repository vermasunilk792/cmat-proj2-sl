variable "aws_ami_id" {
  # ami for ubuntu
  default = "ami-0430580de6244e02e"
  ## "ami-0430580de6244e02e"
}
variable "ssh_key_pair" {
  default = "~/.ssh/id_rsa"
}

variable "ssh_key_pair_pub" {
  default = "~/.ssh/id_rsa.pub"
}
