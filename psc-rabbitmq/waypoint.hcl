project = "prosanteconnect/psc-ecosystem-components/psc-rabbitmq"

# Labels can be specified for organizational purposes.
labels = { "domaine" = "psc" }

runner {
  enabled = true
  data_source "git" {
    url = "https://github.com/prosanteconnect/psc-ecosystem-components.git"
    path = "psc-rabbitmq"
  }
}

# An application to deploy.
app "prosanteconnect/psc-ecosystem-components/psc-rabbitmq" {

  # Deploy to Nomad
  deploy {
    use "nomad-jobspec" {
      jobspec = templatefile("${path.app}/psc-rabbitmq.nomad.tpl", {
        public_hostname = var.public_hostname
      })
    }
  }
}

variable "public_hostname" {
  type    = string
  default = "forge.psc.henix.asipsante.fr"
}
