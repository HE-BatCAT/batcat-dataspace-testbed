variable "linkahead-image" {
  description = "The docker image tag of the linkahead build you want to be loaded."
  default = "indiscale/linkahead:0.16.2-rc"
}

variable "elabftw-image" {
  description = "The docker image tag of the elabftw build you want to be loaded."
  default = "elabftw/elabimg:stable"
}
