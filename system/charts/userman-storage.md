

## um-login-service

`claimName: eoepca-userman-pvc`

### config

* pvc = eoepca-userman-pvc
  * config-init/db => /opt/config-init/db/


### opendj

* pvc = eoepca-userman-pvc
  * opendj/config => /opt/opendj/config
  * opendj/ldif   => /opt/opendj/ldif
  * opendj/logs   => /opt/opendj/logs
  * opendj/db     => /opt/opendj/db
  * opendj/flag   => /flag

### oxauth

* pvc = eoepca-userman-pvc
  * oxauth/logs          => /opt/gluu/jetty/oxauth/logs
  * oxauth/lib/ext       => /opt/gluu/jetty/oxauth/lib/ext
  * oxauth/custom/static => /opt/gluu/jetty/oxauth/custom/static
  * oxauth/custom/pages  => /opt/gluu/jetty/oxauth/custom/pages

### oxtrust

* pvc = eoepca-userman-pvc
  * oxtrust/logs          => /opt/gluu/jetty/identity/logs
  * oxtrust/lib/ext       => /opt/gluu/jetty/identity/lib/ext
  * oxtrust/custom/static => /opt/gluu/jetty/identity/custom/static
  * oxtrust/custom/pages  => /opt/gluu/jetty/identity/custom/pages


## um-pdp-engine

* pvc = eoepca-userman-pvc
  * pdp-engine/db/policy => /data/db/


## um-pep-engine

* pvc = eoepca-userman-pvc
  * pep-engine/db/resource => /data/db/


## user-profile

* pvc = eoepca-userman-pvc
  * um-user-profile-config => /opt/user-profile/db/um-user-profile-config
  * user-profile/logs => /opt/gluu/jetty/user-profile/logs

