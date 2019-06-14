#!/bin/bash
#set -x
################################################################################
# Author    : Anibal Enrique Ojeda Gonzalez
# Version   : 1.1
# Date      : 14-6-2019
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
read -r var1
echo -n "Enter storage in Gb: "
read -r var2
echo -n "Enter volume directory: "
read -r var3
echo -n "Enter namespace: "
read -r var4

cat > $volumedir/$var1-pv-volume.yaml << EOF
kind: PersistentVolume
apiVersion: v1
metadata:
  name: $var1-pv-volume
  namespace: $var4
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
  namespace: $var4
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
read -r var1
echo -n "Enter volume directory: "
read -r var2

    kubectl delete -f $volumedir/$var1-pv-claim.yaml
    kubectl delete -f $volumedir/$var1-pv-volume.yaml
    ex +g/$var1-pv-volume.yaml/d -cwq $kustom
    ex +g/$var1-pv-claim.yaml/d -cwq $kustom
    rm -rf /opt/$var2
    rm $volumedir/$var1-pv-volume.yaml
    rm $volumedir/$var1-pv-claim.yaml

;;
-h)
   echo "PersistentVolume_Claim.sh options
-a to add PersistentVolumeClaim and PersistentVolume
-d to delete
-v to view";;

-v)
   cat $kustom;;

 *) echo "Option $1 not recognized. Use -h for help" ;; # In case you typed a different option other than a,d,h,v

  esac

    shift

done
