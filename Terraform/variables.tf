variable "counts" {
  type = map
  default = {
    "loadbalancer"  = 2
    "forwardserver" = 1
    "api" = 1
  }
}
