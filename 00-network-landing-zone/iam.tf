resource "aws_iam_role" "dev-resources-iam-role" {
  name               = "${local.name}-ec2-role"
  description        = "The role for the developer resources EC2"
  assume_role_policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    }
  EOF
}

resource "aws_iam_role_policy_attachment" "dev-resources-ssm-policy" {
  role       = aws_iam_role.dev-resources-iam-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "dev-resources-iam-profile" {
  name = "${local.name}_ec2_profile"
  role = aws_iam_role.dev-resources-iam-role.name
}

