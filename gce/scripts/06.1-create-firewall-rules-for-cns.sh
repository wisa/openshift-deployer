#!/bin/bash

# CNS to CNS node
echo "=> Creating Firewall Rule for Gluster replication..."
gcloud compute firewall-rules create ${CLUSTERID}-cns-to-cns \
  --direction=INGRESS --priority=1000 --network=${CLUSTERID_NETWORK} \
  --action=ALLOW --rules=tcp:2222 \
  --source-tags=${CLUSTERID}-cns --target-tags=${CLUSTERID}-cns

# Node to CNS node (client)
echo "=> Creating Firewall Rule for OCS mount..."
gcloud compute firewall-rules create ${CLUSTERID}-node-to-cns \
  --direction=INGRESS --priority=1000 --network=${CLUSTERID_NETWORK} \
  --action=ALLOW \
  --rules=tcp:111,udp:111,tcp:3260,tcp:24007-24010,tcp:49152-49664 \
  --source-tags=${CLUSTERID}-node --target-tags=${CLUSTERID}-cns
