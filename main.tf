resource "aws_key_pair" "my-key" {
  key_name   = "devops14-2021"
  public_key = file("${path.module}/my_public_key.txt")
}

resource "aws_eip" "my_eip" {
  vpc = true
  tags = {
    Name  = var.common_tags
    Owner = "Burhan"
  }
}

resource "aws_security_group" "dynamic-sg" {
  name = var.common_tags
  dynamic "ingress" {
    for_each = var.ingress_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = var.protocol
      cidr_blocks = var.cidr
    }
  }
  dynamic "egress" {
    for_each = var.egress_ports
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = var.protocol
      cidr_blocks = var.cidr
    }
  }
}

resource "aws_instance" "ec2-2" {
  ami           = lookup(var.ami, var.region)
  instance_type = lookup(var.instance_type, var.region)
  key_name      = aws_key_pair.my-key.key_name
  tags = {
    Name  = "devops14-2021"
    Owner = "burhan"
  }
}

resource "aws_network_interface_sg_attachment" "sg_attachment" {
  security_group_id    = aws_security_group.dynamic-sg.id
  network_interface_id = aws_instance.ec2-2.primary_network_interface_id
}