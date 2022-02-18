job "psc-mongodb" {
  datacenters = ["${datacenter}"]
  type = "service"

  vault {
    policies = ["psc-ecosystem"]
    change_mode = "restart"
  }

  group "psc-mongodb" {
    count = 1

    restart {
      attempts = 3
      delay = "60s"
      interval = "1h"
      mode = "fail"
    }

    constraint {
      attribute = "$\u007Bnode.class\u007D"
      value     = "data"
    }

    update {
      max_parallel      = 1
      min_healthy_time  = "30s"
      progress_deadline = "5m"
      healthy_deadline  = "2m"
    }

    network {
      port "db" { to = 27017 }
    }

    task "psc-mongodb" {
      driver = "docker"
      template {
        data = <<EOH
          MONGO_INITDB_ROOT_USERNAME = {{ with secret "psc-ecosystem/mongodb" }}{{ .Data.data.root_user }}{{ end }}
          MONGO_INITDB_ROOT_PASSWORD = {{ with secret "psc-ecosystem/mongodb" }}{{ .Data.data.root_pass }}{{ end }}
        EOH
        destination = "secrets/.env"
        change_mode = "restart"
        env = true
      }
      config {
        image = "${image}:${tag}"
        ports = ["db"]
        volumes = ["name=psc-mongodb,fs=xfs,io_priority=high,size=8,repl=2:/data/db",
          "name=psc-mongodb-config, fs=xfs, io_priority=high, size=1, repl=2:/data/configdb"]
        volume_driver = "pxd"
      }
      resources {
        cpu    = 2000
        memory = 6044
      }
      service {
        name = "$\u007BNOMAD_JOB_NAME\u007D"
        port = "db"
        check {
          name         = "alive"
          type         = "tcp"
          interval     = "30s"
          timeout      = "5s"
          failures_before_critical = 5
          port         = "db"
        }
      }
    }

    task "log-shipper" {
      driver = "docker"
      restart {
        interval = "30m"
        attempts = 5
        delay    = "15s"
        mode     = "delay"
      }
      meta {
        INSTANCE = "$\u007BNOMAD_ALLOC_NAME\u007D"
      }
      template {
        data = <<EOH
LOGSTASH_HOST = {{ range service "logstash" }}{{ .Address }}:{{ .Port }}{{ end }}
ENVIRONMENT = "${datacenter}"
EOH
        destination = "local/file.env"
        env = true
      }
      config {
        image = "${registry_path}/filebeat:7.14.2"
      }
    }
  }
}
