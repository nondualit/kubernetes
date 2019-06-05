#!/bin/bash
################################################################################
# Author    : Anibal Ojeda
# Version   : 0.2
# Date      : 5-6-2019
# Description: Add and remove PersistentVolume and Claims from Kubernetes Cluster
################################################################################
#Placeholders
volumedir=/opt/kube_conf_files/volumes/
kustom=/opt/kube_conf_files/volumes/kustomization.yml


# Options
while [ -n "$1" ]; do # while loop starts

case "$1" in

-a)

echo -n "Enter PersistentVolume and Claim name: "
read var1
echo -n "Enter storage in Gb: "
read var2
echo -n "Enter volume directory: "
read var3

cat > $volumedir/$var1-pv-volume.yaml << EOF
kind: PersistentVolume
apiVersion: v1
metadata:
  name: $var1-pv-volume
  labels:
    type: local
spec:
  storageClassName: manual
  capacity:
    storage: ${var2}Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "$var3"
EOF

cat > $volumedir/$var1-pv-claim.yaml << EOF
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: $var1-pv-claim
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: ${var2}Gi
EOF

echo "- $var1-pv-volume.yaml" >> $kustom
echo "- $var1-pv-claim.yaml" >> $kustom

cd $volumedir
kubectl apply -k ./
;;

-d)

echo -n "Enter PersistentVolume and Claim name: "
read var1
echo -n "Enter volume directory: "
read var2

    kubectl delete -f $volumedir/$var1-pv-claim.yaml
    kubectl delete -f $volumedir/$var1-pv-volume.yaml
    ex +g/$var1-pv-volume.yaml/d -cwq $kustom
    ex +g/$var1-pv-claim.yaml/d -cwq $kustom
    rm -rf /opt/$var2
    rm $volumedir/$var1-pv-volume.yaml
    rm $volumedir/$var1-pv-claim.yaml

;;
-h)
   echo "Use -a to add PersistentVolumeClaim and PersistentVolume to the kubernetes cluster or -d to delete";;

 *) echo "Option $1 not recognized. Use -h for help" ;; # In case you typed a different option other than a,d,h

  esac

    shift

done
