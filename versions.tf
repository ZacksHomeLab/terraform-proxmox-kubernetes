terraform {
  required_version = ">=1.3.0"
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "3.3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.1"
    }
    proxmox = {
      source  = "Telmate/proxmox"
      version = "2.9.14"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    macaddress = {
      source  = "ivoronin/macaddress"
      version = "0.3.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.5.1"
    }
  }
}
