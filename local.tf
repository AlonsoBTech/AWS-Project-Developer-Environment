locals {
    my_ip = jsondecode(data.http.my_public_ip.body)
}
