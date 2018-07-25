

# Pods scheduled to a node receive an IP address from the node's Pod CIDR range.
# At this point nodes CAN reach other nodes.
# However pods can not communicate with other pods running on different nodes.
#
# We need to create a route for each worker node
# that maps the node's Pod CIDR range to the node's internal IP address.

# print internal IP address and Pod CIDR range
echo "NODE IP     POD CIDR"
for instance in worker-0 worker-1 worker-2; do
  gcloud compute instances describe ${instance} \
    --format 'value[separator=" "](networkInterfaces[0].networkIP,metadata.items[0].value)'
done

for i in 0 1 2; do
  gcloud compute routes create kubernetes-route-10-200-${i}-0-24 \
    --network kube-ex \
    --next-hop-address 10.240.0.2${i} \
    --destination-range 10.200.${i}.0/24
done

#
# verify
#
gcloud compute routes list --filter "network: kube-ex"
