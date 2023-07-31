locals {
#  account_id            = "969921119504"
  region             = "us-east-1"
  availability_zones = ["${local.region}a", "${local.region}b", "${local.region}c"]
  tags               = {
    "Environment" : "DEV"
    "Project" : "Infrastructure"
  }
}
