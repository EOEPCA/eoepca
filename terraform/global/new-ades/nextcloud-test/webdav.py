import owncloud

# oc = owncloud.Client('http://workspace.test.172.17.0.3.nip.io/remote.php/dav/files/eoepca/')
oc = owncloud.Client('http://workspace.test.172.17.0.3.nip.io/')
# oc = owncloud.Client('http://workspace.default/')

oc.login('eoepca', 'telespazio')

oc.mkdir('testdir')
