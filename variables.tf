variable "region" {
  description = "Region to deploy in"
}
variable "imagename" {
  description = "Name of the image to deploy"
}
variable "imagetag" {
  description = "Tag of the image to deploy"
}

variable "vpc_id" {
  description = "Default VPC"
  default     = "vpc-100fe06d"
}