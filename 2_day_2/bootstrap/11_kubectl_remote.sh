  KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kube-ex \
    --region $(gcloud config get-value compute/region) \
    --format 'value(address)')

  kubectl config set-cluster kube-ex \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443

  kubectl config set-credentials admin \
    --client-certificate=admin.pem \
    --client-key=admin-key.pem

  kubectl config set-context kube-ex \
    --cluster=kube-ex \
    --user=admin

  kubectl config use-context kube-ex

#
# verify
#
kubectl get componentstatuses
kubectl get nodes

