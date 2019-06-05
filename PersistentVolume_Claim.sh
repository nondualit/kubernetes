#!/bin/bash
################################################################################
# Author    : Anibal Ojeda
# Version   : 0.1
# Date      : 5-6-2019
# Description: Add and remove ersistentVolume and Claims from Kubernetes Cluster
################################################################################
#Placeholders
volumedir=/opt/kube_conf_files/volumes/
kustom=/opt/kube_conf_files/volumes/kustomization.yml


# Options
while [ -n "$1" ]; do # while loop starts

case "$1" in

-a)

echo -n "Enter PersistentVolume name: "
read var1
echo -n "Enter PersistentVolumeClaim name: "
read var2
echo -n "Enter storage in Gb: "
read var3
echo -n "Enter volume directory: "
read var4

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
    storage: ${var3}Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "$var4"
EOF

cat > $volumedir/$var2-pv-claim.yaml << EOF
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

echo "- $var1-pv-volume.yaml" >> $kustom
echo "- $var2-pv-claim.yaml" >> $kustom

cd $volumedir
kubectl apply -k ./
;;

-d)

echo -n "Enter PersistentVolume name: "
read var1
echo -n "Enter PersistentVolumeClaim name: "
read var2
echo -n "Enter volume directory: "
read var3

    kubectl delete -f $volumedir/$var2-pv-claim.yaml
    kubectl delete -f $volumedir/$var1-pv-volume.yaml
    ex +g/$var1-pv-volume.yaml/d -cwq $kustom
    ex +g/$var2-pv-claim.yaml/d -cwq $kustom
    rm -rf /opt/$var3
    rm $volumedir/$var1-pv-volume.yaml
    rm $volumedir/$var2-pv-claim.yaml

;;
-h)
   echo "Use -a to add PersistentVolumeClaim and PersistentVolume to the kubernetes cluster or -d to delete";;

 *) echo "Option $1 not recognized. Use -h for help" ;; # In case you typed a different option other than a,d,h

  esac

    shift

done
