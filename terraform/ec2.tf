resource "aws_spot_instance_request" "sample" {
  count                   = local.LENGTH
  ami                     = "ami-0bb6af715826253bf"
  spot_price              = "0.0755"
  instance_type           = "t2.micro"
  wait_for_fulfillment    = true
  vpc_security_group_ids  = [aws_security_group.allow_ssh.id]
  tags = {
    Name                  = element(var.COMPONENTS, count.index)
  }
}


resource "aws_ec2_tag" "name-tag" {
  count                   = local.LENGTH
  resource_id             = element(aws_spot_instance_request.sample.*.spot_instance_id, count.index)
  key                     = "Name"
  value                   = element(var.COMPONENTS, count.index)
}

resource "aws_route53_record" "records" {
  count                   = local.LENGTH
  name                    = element(var.COMPONENTS, count.index)
  type                    = "A"
  zone_id                 = "Z0344920CYRF77G0UQSC"
  ttl                     = "300"
  records                 = [element(aws_spot_instance_request.sample.*.private_ip, count.index)]
}

locals {
  LENGTH                   = length(var.COMPONENTS)
}

resource "local_file" "inv"{
  filename                 = "/tmp/roboshop-inv"
  content                  = "[FRONTEND]\n${aws_spot_instance_request.sample.*.private_ip[9]}\n[PAYMENT]\n${aws_spot_instance_request.sample.*.private_ip[8]}\n[SHIPPING]\n${aws_spot_instance_request.sample.*.private_ip[7]}\n[USER]\n${aws_spot_instance_request.sample.*.private_ip[6]}\n[CATALOGUE]\n${aws_spot_instance_request.sample.*.private_ip[5]}\n[CART]\n${aws_spot_instance_request.sample.*.private_ip[4]}\n[REDIS]\n${aws_spot_instance_request.sample.*.private_ip[3]}\n[RABBITMQ]\n${aws_spot_instance_request.sample.*.private_ip[2]}\n[MONGODB]\n${aws_spot_instance_request.sample.*.private_ip[1]}\n[MYSQL]\n${aws_spot_instance_request.sample.*.private_ip[0]}"
}