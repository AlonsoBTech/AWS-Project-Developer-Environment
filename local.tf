locals {
  my_ip = jsondecode(data.http.my_public_ip.response_body)
}
