terraform {
  backend "s3" {
    bucket         = "tajawal-terraform-states-pocs"
    key            = "poc-account/dev/aws-ireland/eks/v2/secondary-managed-node-mixed-spot-pvc-multi-az/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "tajawal-terraform-states"
    profile        = "ct-poc" 
  }
}

module "eks" {
#   source = "git@github.com:tajawal/terraform-modules.git//terraform-mixed-instance-managed-ng-eks?ref=gc-setup"
  source = "/Users/syed.hassan/Documents/MyTasks/repos/terraform-modules/terraform-mixed-instance-managed-ng-eks"

  cluster-name   = "tajawal-poc"
  aws-region     = "eu-west-1"
  k8s_ng_version = "1.30"

  instance_types = ["t2.large", "m3.large", "m1.large", "m7i.large", "m6i.large", "m5dn.large", "m5d.large", "m6gd.large", "t3.large", "t4g.large"]

  subcomponent = "node"
  minimum-node = "3"
  maximum-node = "5"
  desired-node = "3"

  node_group_type = "mixed-spot-pvc-multi-az"
#   taint_key   = "application_type"
#   taint_value = "multi-az"
  capacity_type   = "SPOT"
  # availability_zones = ["eu-west-1c"]
  force_update_version = true

  key                     = "tajawal-poc"
  launch_template_version = "$Latest"

  root_device_name = "/dev/xvda"
  root_device_size = "150"
  component        = "eks"
  role             = "k8s"
  businessunit     = "tajawal"
  environment      = "dev"
  organization     = "altayyargroup"
  profile          = "ct-poc" // this will be used to get creds from shared file.
  service_type     = "k8s"

  # These tags will be only changed when we are creating a new version of environment or new version of this subcomponent.
  environmentversion = "v1"
  infraversion       = "v1"
}