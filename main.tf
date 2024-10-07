## Security group

resource "aws_security_group" "sg" {
  name        = "${var.component}-${var.env}-sg"
  description = "${var.component}-${var.env}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5672  # Rabbitmq port
    to_port     = 5672
    protocol    = "tcp"
    cidr_blocks = var.sg_subnet_cidr # We are allowing app subnet to this instance to access
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allow_ssh_cidr # We wanted workstation to access this node
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.component}-${var.env}"  },    var.tags)
}


## EC2
## For EC2 we would require data for aws ami which is stored in data.tf file

resource "aws_instance" "rabbitmq_instance" {
  ami                    = data.aws_ami.ami.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name
  tags                   = merge({ Name = "${var.component}-${var.env}" }, var.tags)
  subnet_id              = var.subnet_id

  # We are giving a template file for user data path . module then the file is in the module, if it is path . root it is in root module
  user_data = templatefile("${path.module}/userdata.sh", {
    env       = var.env
    component = var.component
  })

  # We have to create a root block device specific to encryption
  root_block_device {
    encrypted = true
    kms_key_arn = var.kms_key_arn
  }
}

resource "aws_route53_record" "rabbitmq"{
  name    = "${var.component}-${var.env}"
  type    = "A"
  zone_id = var.zone_id
  ttl     = "30"
  records = [aws_instance.rabbitmq_instance.private_ip]

}

