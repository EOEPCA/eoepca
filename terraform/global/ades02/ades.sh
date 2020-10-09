#!/usr/bin/env bash

ORIG_DIR="$(pwd)"
cd "$(dirname "$0")"
BIN_DIR="$(pwd)"

trap "cd '${ORIG_DIR}'" EXIT

TEMP_DIR="generated"
K8S_YAML_FILE="${TEMP_DIR}/ades.yaml"
NAMESPACE="eoepca"
ADES_SERVICE_ACCOUNT="ades"
KUBECONFIG="${TEMP_DIR}/kubeconfig"

mkdir -p "${TEMP_DIR}"

function prepareRoles() {
    # namespace
    kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml >${K8S_YAML_FILE}

    # 'ades' service account
    echo "---"  >>${K8S_YAML_FILE}
    kubectl -n "${NAMESPACE}" create serviceaccount "${ADES_SERVICE_ACCOUNT}" --dry-run=client -o yaml >>${K8S_YAML_FILE}

    # add 'cluster-admin' role to 'ades' service account
    echo "---"  >>${K8S_YAML_FILE}
    kubectl create clusterrolebinding ades-cluster-admin --clusterrole=cluster-admin --serviceaccount="${NAMESPACE}:${ADES_SERVICE_ACCOUNT}" --dry-run=client -o yaml >>${K8S_YAML_FILE}
}

function prepareKubeconfig() {
    kubeconfig "$@"
    echo "---"  >>${K8S_YAML_FILE}
    kubectl -n "${NAMESPACE}" create configmap ades-kubeconfig --from-file=${KUBECONFIG} --dry-run=client -o yaml >>${K8S_YAML_FILE}
}

function prepareADES() {
    # ades-config ConfigMap
    echo "---"  >>${K8S_YAML_FILE}
    kubectl -n "${NAMESPACE}" create configmap ades-config --from-env-file=ades.conf --dry-run=client -o yaml >>${K8S_YAML_FILE}

    # persistent volume claim (ades config)
    echo "---"  >>${K8S_YAML_FILE}
    cat - <<EOF >>${K8S_YAML_FILE}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ades-config-pv-claim
  namespace: ${NAMESPACE}
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 100Mi
EOF

    # persistent volume claim (ades user data)
    echo "---"  >>${K8S_YAML_FILE}
    cat - <<EOF >>${K8S_YAML_FILE}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ades-user-data-pv-claim
  namespace: ${NAMESPACE}
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 10Gi
EOF

    # persistent volume claim (ades processing servics)
    echo "---"  >>${K8S_YAML_FILE}
    cat - <<EOF >>${K8S_YAML_FILE}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ades-processing-services-pv-claim
  namespace: ${NAMESPACE}
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 5Gi
EOF

    # ades deployment
    echo "---"  >>${K8S_YAML_FILE}
    cat - <<EOF >>${K8S_YAML_FILE}
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: ades
  name: ades
  namespace: ${NAMESPACE}
spec:
  replicas: 1
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: ades
  template:
    metadata:
      labels:
        app: ades
    spec:
      containers:
        - name: ades
          envFrom:
            - configMapRef:
                name: ades-config
          image: eoepca/proc-ades:latest
          imagePullPolicy: IfNotPresent
          resources:
            requests:
              memory: "2Gi"
              cpu: "1"
              ephemeral-storage: "2Gi"
            limits:
              memory: "4Gi"
              cpu: "2"
              ephemeral-storage: "5Gi"
          ports:
            - containerPort: 80
          volumeMounts:
            - name: ades-config
              mountPath: /var/etc/ades
            - name: ades-user-data
              mountPath: /var/www/html/res
            - name: ades-processing-services
              mountPath: /opt/zooservices_user
            - name: kubeconfig-volume
              mountPath: /var/etc/ades/kubeconfig
              subPath: kubeconfig
      volumes:
        - name: ades-config
          persistentVolumeClaim:
            claimName: ades-config-pv-claim
        - name: ades-user-data
          persistentVolumeClaim:
                claimName: ades-user-data-pv-claim
        - name: ades-processing-services
          persistentVolumeClaim:
                claimName: ades-processing-services-pv-claim
        - name: kubeconfig-volume
          configMap:
            name: ades-kubeconfig
      restartPolicy: Always
EOF

    # ades service
    echo "---"  >>${K8S_YAML_FILE}
    cat - <<EOF >>${K8S_YAML_FILE}
kind: Service
apiVersion: v1
metadata:
  name: ades
  namespace: ${NAMESPACE}
  labels:
      app: ades
spec:
  selector:
    app: ades
  ports:
  - name: http
    protocol: TCP
    port: 80
    nodePort: 30999
  type: NodePort
EOF
}

function apply() {
    echo "=== ROLES ==="
    prepareRoles "$@"
    kubectl apply -f "${K8S_YAML_FILE}"
    echo "=== KUBECONFIG ==="
    prepareKubeconfig "$@"
    kubectl apply -f "${K8S_YAML_FILE}"
    echo "=== ADES ==="
    prepareADES "$@"
    kubectl apply -f "${K8S_YAML_FILE}"
}

function delete() {
    kubectl delete -f "${K8S_YAML_FILE}"
}

function kubeconfig() {
    # Gather cluster details
    CLUSTER_NAME=`kubectl config view -o json | jq -r '.clusters[0].name'`
    SERVER=`kubectl config view -o json | jq -r '.clusters[0].cluster.server'`
    CERT_AUTHORITY=`kubectl config view -o json | jq -r '.clusters[0].cluster."certificate-authority"'`

    # extract token from serviceaccount (needed later)
    TOKENNAME=`kubectl -n "${NAMESPACE}" get "serviceaccount/${ADES_SERVICE_ACCOUNT}" -o jsonpath='{.secrets[0].name}'`
    TOKEN=`kubectl -n "${NAMESPACE}" get secret $TOKENNAME -o jsonpath='{.data.token}' | base64 -d`

    # Initialise kubeconfig
    kubectl config --kubeconfig=${KUBECONFIG} set-cluster "${CLUSTER_NAME}" \
    --server="${SERVER}" --embed-certs --certificate-authority="${CERT_AUTHORITY}"

    # Add user info to kubeconfig
    kubectl config set-context ades-context --kubeconfig=${KUBECONFIG} --cluster="${CLUSTER_NAME}" --namespace "${NAMESPACE}" --user "${ADES_SERVICE_ACCOUNT}"
    kubectl config set-credentials "${ADES_SERVICE_ACCOUNT}" --kubeconfig=${KUBECONFIG} --token=$TOKEN
    kubectl config use-context ades-context --kubeconfig=${KUBECONFIG}
}

function main() {
    ACTION="$1" && shift
    if test -z "$ACTION"; then echo "ERROR: must supply ACTION"; return 1; fi
    case "$ACTION" in
        apply)
            apply "$@"
            ;;
        delete)
            delete "$@"
            ;;
        *)
            echo "ERROR: bad action=$ACTION"
            return 2
    esac
}

main "$@"
