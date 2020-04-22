terraform {
    backend "swift" {
        container         = "eoepca-staging-terraform-state"
    }
}