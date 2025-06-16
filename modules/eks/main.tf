resource "aws_iam_role" "clusterrole" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
  
}
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.clusterrole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "node_role" {
  name = "${var.cluster_name}-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })    
  }

  resource "aws_iam_role_policy_attachment" "node_policy" {
    role       = aws_iam_role.node_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  } 

  resource "aws_eks_node_group" "node_group" {
    for_each = var.node_groups

    cluster_name    = var.cluster_name
    node_group_name = each.key
    node_role_arn   = aws_iam_role.node_role.arn
    subnet_ids      = var.subnet_ids

    scaling_config {
      desired_size = each.value.scaling_config.desired_size
      max_size     = each.value.scaling_config.max_size
      min_size     = each.value.scaling_config.min_size
    }

    instance_types = each.value.instance_types
    capacity_type  = each.value.capacity_type

    tags = {
      Name = "${var.cluster_name}-${each.key}-node-group"
    }
  }
  