locals {
	dockerconfigjson = {
		"auths": {
			"https://hub.docker.com" = {
				email    = var.dh_user_email
				username = var.dh_user_name
				password = var.dh_user_password
				auth     = base64encode(join(":",[var.dh_user_name, var.dh_user_password]))
			}
		}
	}
}
resource "kubernetes_secret" "dockerhub-imagepullsecret" {
	metadata {
		name      = "dockerhub-imagepullsecret"
	}
	data = {
		".dockerconfigjson" = jsonencode(local.dockerconfigjson)
	}
	type = "kubernetes.io/dockerconfigjson"
}