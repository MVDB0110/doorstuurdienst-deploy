variable "counts" {
  type = map
  default = {
    "loadbalancer"  = 2
    "forwardserver" = 2
    "api" = 1
  }
}
