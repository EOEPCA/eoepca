resource "kubernetes_persistent_volume" "pv-sample-eo-data-1" {
  metadata {
    name = "pv-sample-eo-data-1"
	  labels = {
	    vol_type = "eo-end-user-data"
	    vol_id = "vol_1999"
	  }
  }
  spec {
    capacity = {
      storage = "2Gi"
    }
    access_modes = ["ReadWriteOnce"]
	
    persistent_volume_reclaim_policy = "Retain"
	
	  persistent_volume_source {
	    host_path {
	      path = "/mnt"
	    }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_persistent_volume" "pv-sample-eo-data-2" {
  metadata {
    name = "pv-sample-eo-data-2"
	  labels = {
	    vol_type = "eo-end-user-data"
	    vol_id = "vol_0001"
	  }
  }
  spec {
    capacity = {
      storage = "1Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_reclaim_policy = "Retain"
	  persistent_volume_source {
	    host_path {
	      path = "/mnt"
	    }
    }
    storage_class_name = "standard"
  }
}

#resource "kubernetes_persistent_volume_claim" "pvc-sample-eo-data" {
#  metadata {
#    name = "pvc-sample-eo-data"
#	  namespace = "eo-user-compute"
#  }
#  spec {
#    access_modes = ["ReadWriteOnce"]
#    resources {
#      requests = {
#        storage = "1Gi"
#      }
#    }
#    selector {
#	    match_labels = {
#	      vol_type = "eo-user-compute"
#		    vol_id = "vol_1999"
#	    }
#	  }
#    storage_class_name = "standard"
#  }
#}
