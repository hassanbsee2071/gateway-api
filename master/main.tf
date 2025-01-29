terraform {
  backend "s3" {
    bucket         = "tajawal-terraform-states-pocs"
    key            = "poc-account/dev/aws-ireland/eks/v3/master/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "tajawal-terraform-states"
    profile        = "ct-poc" #this profile is only used for s3 backend
  }
}

module "eks" {
#   source = "git@github.com:tajawal/terraform-modules.git//terraform-eks?ref=ALM_v1.3.6_v33"
  source = "/Users/syed.hassan/Documents/MyTasks/repos/terraform-modules/terraform-eks"

  ###############################################
  ## variables are used for eks master
  ###############################################

  cluster-name       = "tajawal-poc"
  aws-region         = "eu-west-1"
  k8s_master_version = "1.30"

  subcomponent       = "node"



  ###############################################
  ## variables are common for eks nodes SG
  ###############################################

  custom_node_sg_rules = {
  "web-alb-traffic" = {
    from_port      = 80
    to_port        = 80
    protocol       = "tcp"
    cidr_blocks    = []
    security_groups = ["sg-04e4726e52da12870"]
    description    = "web-ALB"
  },
  "web-alb-traffic-health-check" = {
    from_port      = 10254
    to_port        = 10254
    protocol       = "tcp"
    cidr_blocks    = []
    security_groups = ["sg-04e4726e52da12870"]
    description    = "web-ALB"
  },
  "web-alb-kong-traffic-health-check" = {
    from_port      = 8000
    to_port        = 8000
    protocol       = "tcp"
    cidr_blocks    = []
    security_groups = ["sg-04e4726e52da12870"]
    description    = "web-ALB-Kong"
  }
}

  ###############################################
  ## variables are common for eks master & nodes
  ###############################################

  component    = "eks"
  role         = "k8s"
  businessunit = "tajawal"
  environment  = "poc"
  organization = "altayyargroup"
  profile      = "ct-poc" // this will be used to get creds from shared file.

  # These tags will be only changed when we are creating a new version of environment or new version of this subcomponent.
  environmentversion = "v1"
  infraversion       = "v1"
  service_type       = "k8s"
  #map-migrated       = "d-server-02jb5ut3bn2b83" # Map ID default set to same value in the modules.

  #localdns-ip = "169.254.20.10" # node local dns IP, its a static and applied from TIIC utilities directory.

  # The following cluster control plane log types are availabl: ["api","controllerManager","scheduler","audit","Authenticator"]
#   enabled_cluster_log_types = ["api","audit"]
  ###############################################
  ## variables are used for eks cluster addons
  ###############################################
  
  cluster_addon_enabled = true
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }

    aws-ebs-csi-driver = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
      # before_compute           = true
      # service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      # addon_version = "v1.15.5-eksbuild.1"  # Specify a specific version to upgrade to if necessary
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html         
          WARM_PREFIX_TARGET           = "1"
          AWS_VPC_K8S_CNI_EXTERNALSNAT = "true"
        }
      })
    }
    aws-efs-csi-driver = {
      most_recent = true
    }
  }
}