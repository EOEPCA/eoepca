# this is already set to the volume configured in the docker file
#zzz KUBECONFIG=/var/etc/ades/kubeconfig
KUBECONFIG=/var/etc/kubeconfig
# This is the resource manager endpoint of the catalog used for processing results publication
# CATALOG_ENDPOINT=https://catalog.terradue.com/rconway
CATALOG_ENDPOINT=aHR0cHM6Ly9jYXRhbG9nLnRlcnJhZHVlLmNvbS9yY29ud2F5
# catalog username
# CATALOG_USERNAME=rconway
CATALOG_USERNAME=cmNvbndheQ==
# catalog password (may be base64 encoded)
# CATALOG_APIKEY=AKCp8hyEYSMqk4swUndyCDVZW7g3XFYfvE2xVFQEdYagJLqVJY1qKbXcmStLoUFEyEhL5tKcY
CATALOG_APIKEY=QUtDcDhoeUVZU01xazRzd1VuZHlDRFZaVzdnM1hGWWZ2RTJ4VkZRRWRZYWdKTHFWSlkxcUtiWGNtU3RMb1VGRXlFaEw1dEtjWQ==
# This is the resource manager endpoint of the store used for processing results persistent storage (WebDAV)
# STORAGE_HOST=http://workspace.default/
STORAGE_HOST=aHR0cDovL3dvcmtzcGFjZS5kZWZhdWx0Lw==
# store username
# STORAGE_USERNAME=eoepca
STORAGE_USERNAME=ZW9lcGNh
# store password (may be base64 encoded)
# STORAGE_APIKEY=telespazio
STORAGE_APIKEY=dGVsZXNwYXppbw==
# kubernetes storage class to be used for provisioning volumes. Must be a persistent volume claim compliant (glusterfs-storage)
STORAGE_CLASS=standard
# Size of the Kubernetes Volumes in gigabytes
VOLUME_SIZE=4