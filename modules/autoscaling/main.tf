resource "aws_security_group" "pub_sg" {
  vpc_id = var.vpc
  ingress {
        from_port       = 22
        to_port         = 22
        protocol        = "tcp" 
        cidr_blocks      = ["0.0.0.0/0"]
    }
    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp" 
        cidr_blocks      = ["0.0.0.0/0"]
    }
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        prefix_list_ids = [] 
    }
    tags = {
        Name = "pub-SG"
    }
}
resource "aws_launch_template" "pub_launch_template" {
  name = "publaunchtemplate"
  image_id = var.ami
  instance_type = var.instance_type
  key_name = "terraform"
  network_interfaces {
    associate_public_ip_address = true
    security_groups = ["${aws_security_group.pub_sg.id}"]
  }

  user_data = base64encode(<<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
sudo cat > /etc/nginx/sites-enabled/default << EOL
server {
    listen 80 default_server;
    location / {
      proxy_pass http://${var.lb_dns};
    }
} 
EOL
sudo systemctl restart nginx
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "pub-EC2"
    }
  }
}

resource "aws_autoscaling_group" "pub_ASG" {
  name = "pub-ASG"
  vpc_zone_identifier  = var.pub_subnets#["${aws_subnet.pri_subnet[0].id}", "${aws_subnet.pri_subnet[1].id}"
  target_group_arns = [var.pub_target_group] #["${aws_lb_target_group.target_group.arn}"]
  health_check_type = "EC2"
  desired_capacity   = 2
  max_size           = 3
  min_size           = 2

  launch_template {
    id      = aws_launch_template.pub_launch_template.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "pri_launch_template" {
  name = "prilaunchtemplate"
  image_id = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = ["${aws_security_group.pub_sg.id}"]
  key_name = "terraform"

  user_data = base64encode(<<EOF
#!/bin/bash
sudo apt update -y
sudo apt install -y apache2
sudo systemctl enable apache2
sudo systemctl start apache2
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "pri-EC2"
    }
  }
}

resource "aws_autoscaling_group" "pri_ASG" {
  name = "pri-ASG"
  vpc_zone_identifier  = var.pri_subnets#["${aws_subnet.pri_subnet[0].id}", "${aws_subnet.pri_subnet[1].id}"
  target_group_arns = [var.pri_target_group] #["${aws_lb_target_group.target_group.arn}"]
  health_check_type = "EC2"
  desired_capacity   = 4
  max_size           = 6
  min_size           = 2

  launch_template {
    id      = aws_launch_template.pri_launch_template.id
    version = "$Latest"
  }
}
