output "public_ip" {
  value = aws_instance.web_server.public_ip
}

output "ephemeral_backend_api_key_demo" {
  value     = ephemeral.vault_kv_secret_v2.backend_api.data["backend_api_key"]
  ephemeral = true
}

output "public_dns" {
  value = aws_instance.web_server.public_dns
}

output "instance_id" {
  value = aws_instance.web_server.id
}
