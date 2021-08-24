project = "prosanteconnect/psc-ecosystem-components/psc-alertmanager"

# Labels can be specified for organizational purposes.
labels = { "domaine" = "psc" }

runner {
  enabled = true
  data_source "git" {
    url = "https://github.com/prosanteconnect/psc-ecosystem-components.git"
    path = "psc-alertmanager"
  }
}

# An application to deploy.
app "prosanteconnect/psc-ecosystem-components/psc-alertmanager" {

  # Deploy to Nomad
  deploy {
    use "nomad-jobspec" {
      jobspec = templatefile("${path.app}/psc-alertmanager.nomad.tpl", {
        public_hostname = var.public_hostname
      })
    }
  }
}

variable "public_hostname" {
  type    = string
  default = "forge.psc.henix.asipsante.fr"
}