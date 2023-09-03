output "vm1_nginx_external_ip" {
  value       = "${yandex_compute_instance.host1.name}: ${yandex_compute_instance.host1.network_interface.0.nat_ip_address}"
  description = "The Name and public IP address of VM1 instance."
  sensitive   = false
}

output "vm1_nginx_internal_ip" {
  value       = "${yandex_compute_instance.host1.name}: ${yandex_compute_instance.host1.network_interface.0.ip_address}"
  description = "The Name and internal IP address of VM1 instance."
  sensitive   = false
}

/*=EXAMPLE_OUTPUT:

    Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

    Outputs:

    vm1_nginx_external_ip = "nginx: 158.160.23.86"
    vm1_nginx_internal_ip = "nginx: 10.0.10.14"
*/
