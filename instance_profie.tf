# Instance Profile Terraform script

locals {
  role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}

# Create one instance profile, the reference name must be the same as the main.tf
resource "aws_iam_instance_profile" "this" {
  name = "EC2-Profile"
  role = aws_iam_role.this.name
}

/* Create policy attachment that uses AmazonEC2RoleForSSM that allows EC2 to talk to SSM service,
and CloudWatchAgentServerPolicy that allows EC2 to talk to CloudWatch service. */
resource "aws_iam_role_policy_attachment" "this" {
  count = length(local.role_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = element(local.role_policy_arns, count.index)
}

/* Create a custom role policy that will allow EC2 to make API call ssm:GetParameter, the main reason we need to allow
linux_server permission again is that we will need CloudWatch agent to load the configuration from SSM service and
the action is using linux_server permission which not include in AmazonEC2RoleForSSM. */
resource "aws_iam_role_policy" "this" {
  name = "EC2-Inline-Policy"
  role = aws_iam_role.this.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:GetParameter"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}

# Create assume role policy for ec2.amazonaws.com
resource "aws_iam_role" "this" {
  name = "EC2-Role"
  path = "/"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Effect" : "Allow"
        }
      ]
    }
  )
}