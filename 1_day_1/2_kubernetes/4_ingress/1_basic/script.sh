
# give ourselves cluster-admin role
k create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin \
  --user $(gcloud config get-value account)

k apply -f \
https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml
