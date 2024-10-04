## Security group

resource "aws_security_group" "sg" {
  name        = "${var.component}-${var.env}-sg"
  description = "${var.component}-${var.env}-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5672  # Rabbitmq port
    to_port     = 5672
    protocol    = "-1"
    cidr_blocks = var.sg_subnet_cidr # We are allowing app subnet to this instance to access
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


#
### DNS records (route 53)
#
#resource "aws_route53_record" "dns" {
#  zone_id = "Z00238782DN7KNOSJPFLV"
#  name    = "${var.component}-dev"
#  type    = "A"
#  ttl     = 30
#  records = [aws_instance.instance.private_ip]# We are accessing all the ec2 instances using the private IP address
#}
### Null Resource - Ansible
#
#resource "null_resource" "ansible" {
#  depends_on = [aws_instance.instance, aws_route53_record.dns] # We have written this once ec2 instances and route 53 records have been created we need to start the remote execution.
#  provisioner "remote-exec" {
#
#    connection {
#      type     = "ssh"
#      user     = "centos"
#      password = "DevOps321"
#      host     = aws_instance.instance.public_ip
#    }
#
#
#    inline = [
#      "sudo set-hostname -skip-apply ${var.component}",
#      "sudo labauto ansible",
#      "ansible-pull -i localhost, -U https://github.com/gnavien/roboshop-ansible.git main.yml -e env=${var.env} -e role_name=${var.component}"
#    ]
#  }
#}
#



## EC2
## For EC2 we would require data for aws ami which is stored in data.tf file

resource "aws_instance" "rabbitmq_instance" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.sg.id]
  iam_instance_profile = aws_iam_instance_profile.instance_profile.name
  tags = merge({    Name = "${var.component}-${var.env}"  },    var.tags)
  subnet_id = var.subnet_id
}

