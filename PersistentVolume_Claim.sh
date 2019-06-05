#!/bin/bash
################################################################################
# Author    : Anibal Ojeda
# Version   : 1.0
# Date      :
# Description:
################################################################################
echo -n "Enter PersistentVolume name: "
read var1
echo -n "Enter PersistentVolumeClaim name: "
read var2
echo -n "Enter storage in Gb: "
read var3
echo -n "Enter volume directory: "
read var4

cat > /opt/kube_conf_files/volumes/$var1-pv-volume.yaml << EOF
kind: PersistentVolume
apiVersion: v1
metadata:
  name: $var1-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: ${var3}Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "$var4"
EOF

cat > /opt/kube_conf_files/volumes/$var2-pv-claim.yaml << EOF
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: $var2-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: ${var3}Gi
EOF

echo "- $var1-pv-volume.yaml" >> /opt/kube_conf_files/volumes/kustomization.yml
echo "- $var2-pv-claim.yaml" >> /opt/kube_conf_files/volumes/kustomization.yml

cd /opt/kube_conf_files/volumes/
kubectl apply -k ./
