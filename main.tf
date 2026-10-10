
module "ec2" {
  source = "./modules/ec2"

  instances = var.instances
  ami       = var.ami
}