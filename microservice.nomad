job "http-microservice" {
  datacenters = ["dc1"]
  group "echo" {
    count = 1
    task "server" {
      driver = "docker"
      config {
        image = "hashicorp/http-echo:latest"
        args  = [
          "-listen", ":${NOMAD_PORT_http}",
          "-text", "Hello and welcome to ${NOMAD_IP_http} running on port ${NOMAD_PORT_http}. This is my first microservice deployment using Nomad.",
        ]
      }
      resources {
        network {
          mbits = 10
          port "http" {}
        }
      }
    }
  }
}