variable "stage_name" {
  default = "dit099"
  type    = string
}

variable "backbone_url" {
  default = "http://k8s-oagfarga-backbone-a03b7ea046-5ea3c894b1bc6d7c.elb.ca-central-1.amazonaws.com/backbone"
  type    = string
}

variable "lob_url" {
  default = "http://localhost:8080/dummy"
  type    = string
}