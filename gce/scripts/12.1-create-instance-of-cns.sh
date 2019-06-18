#!/bin/bash


# Disks multizone and single zone support
eval "$MYZONES_LIST"

for i in $(seq 0 $(($CNS_NODE_COUNT-1))); do
  zone[$i]=${ZONES[$i % ${#ZONES[@]}]}
  gcloud compute disks create ${CLUSTERID}-cns-${i}-containers \
  --type=pd-ssd --size=${CNSCONTAINERSSIZE} --zone=${zone[$i]}
  gcloud compute disks create ${CLUSTERID}-cns-${i}-gluster \
  --type=${CNSGLUSTERDISKTYPE} --size=${CNSGLUSTERSIZE} --zone=${zone[$i]}
done

# CNS instances multizone and single zone support
for i in $(seq 0 $(($CNS_NODE_COUNT-1))); do
  zone[$i]=${ZONES[$i % ${#ZONES[@]}]}
  gcloud compute instances create ${CLUSTERID}-cns-${i} \
    --async --machine-type=${CNSSIZE} \
    --subnet=${CLUSTERID_SUBNET} \
    --address="" --no-public-ptr \
    --maintenance-policy=MIGRATE \
    --scopes=https://www.googleapis.com/auth/cloud.useraccounts.readonly,https://www.googleapis.com/auth/compute,https://www.googleapis.com/auth/devstorage.read_write,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol\
    --tags=${CLUSTERID}-cns,${CLUSTERID}-node,${CLUSTERID}ocp \
    --metadata "ocp-cluster=${CLUSTERID},${CLUSTERID}-type=cns" \
    --image=${OSIMAGE} --image-project=${IMAGEPROJECT} \
    --boot-disk-size=${CNSDISKSIZE} --boot-disk-type=pd-ssd \
    --boot-disk-device-name=${CLUSTERID}-cns-${i} \
    --disk=name=${CLUSTERID}-cns-${i}-containers,device-name=${CLUSTERID}-cns-${i}-containers,mode=rw,boot=no \
    --disk=name=${CLUSTERID}-cns-${i}-gluster,device-name=${CLUSTERID}-cns-${i}-gluster,mode=rw,boot=no \
    --metadata-from-file startup-script=./initialize-cns-node.sh \
    --zone=${zone[$i]}
done
