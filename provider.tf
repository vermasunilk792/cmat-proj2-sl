provider "aws" {
  profile = "skadm"
  region  = "us-east-1"
}

resource "aws_key_pair" "key-tfnew" {
  key_name   = "key-tfnew"
  public_key = file("~/.ssh/id_rsa.pub")

}
