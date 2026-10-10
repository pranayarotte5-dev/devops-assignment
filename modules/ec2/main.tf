
# Four regular instances
resource "aws_instance" "this" {
  for_each = {
    for name, config in var.instances : name => config
    if name != "app1"
  }

  ami           = var.ami
  instance_type = each.value.instance_type
  key_name      = each.value.key_name

  root_block_device {
    volume_size = each.value.volume_size
    volume_type = each.value.volume_type

    iops = each.value.volume_type == "io1" ? 100 : null
  }

  tags = {
    Name        = each.key
    Environment = "dev"
    Owner       = "pranaya"
  }
}

# Protected instance
resource "aws_instance" "protected" {
  ami           = var.ami
  instance_type = var.instances["app1"].instance_type
  key_name      = var.instances["app1"].key_name

  root_block_device {
    volume_size = var.instances["app1"].volume_size
    volume_type = var.instances["app1"].volume_type
  }

  tags = {
    Name        = "app1"
    Environment = "dev"
    Owner       = "pranaya"
  }

  lifecycle {
    prevent_destroy = true
  }
}
