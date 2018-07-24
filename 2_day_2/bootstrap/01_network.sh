# Create the network
gcloud compute networks create kube-ex --subnet-mode custom

# Create the Kubernetes subnet
gcloud compute networks subnets create kubernetes \
  --network kube-ex \
  --range 10.240.0.0/24

# Allow internal comms from
# 10.240.0.0 -> 10.240.0.255
# 10.200.0.0 -> 10.200.255.255
# allow tcp, udp, and icmp (same protocol as ping)
# This applies to all instances in kube-ex network
gcloud compute firewall-rules create kube-ex-allow-internal \
  --allow tcp,udp,icmp \
  --network kube-ex \
  --source-ranges 10.240.0.0/24,10.200.0.0/16

# Allow external traffic from external sources (from everywhere)
# port 22 (ssh) and 6443 (Service Registry)
gcloud compute firewall-rules create kube-ex-allow-external \
  --allow tcp:22,tcp:6443,icmp \
  --network kube-ex \
  --source-ranges 0.0.0.0/0

 gcloud compute firewall-rules list --filter="network:kube-ex"

# Static IP for Kubernetes API
gcloud compute addresses create kube-ex \
  --region $(gcloud config get-value compute/region)
