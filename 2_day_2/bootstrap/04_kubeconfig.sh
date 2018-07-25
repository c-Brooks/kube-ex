KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kube-ex \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')

# workers
for instance in worker-0 worker-1 worker-2; do
  kubectl config set-cluster kube-ex \
    --certificate-authority=certs/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kubeconfigs/${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=certs/${instance}.pem \
    --client-key=certs/${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=kubeconfigs/${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kube-ex \
    --user=system:node:${instance} \
    --kubeconfig=kubeconfigs/${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=kubeconfigs/${instance}.kubeconfig
done

# admin (kube-apiserver)
kubectl config set-cluster kube-ex \
  --certificate-authority=certs/ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=kubeconfigs/admin.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=certs/admin.pem \
  --client-key=certs/admin-key.pem \
  --embed-certs=true \
  --kubeconfig=kubeconfigs/admin.kubeconfig

kubectl config set-context default \
  --cluster=kube-ex \
  --user=admin \
  --kubeconfig=kubeconfigs/admin.kubeconfig

kubectl config use-context default --kubeconfig=kubeconfigs/admin.kubeconfig

# other components
for COMPONENT in kube-proxy kube-controller-manager kube-scheduler; do
  kubectl config set-cluster kube-ex \
    --certificate-authority=certs/ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=kubeconfigs/${COMPONENT}.kubeconfig

  kubectl config set-credentials system:${COMPONENT} \
    --client-certificate=certs/${COMPONENT}.pem \
    --client-key=certs/${COMPONENT}-key.pem \
    --embed-certs=true \
    --kubeconfig=kubeconfigs/${COMPONENT}.kubeconfig

  kubectl config set-context default \
    --cluster=kube-ex \
    --user=system:${COMPONENT} \
    --kubeconfig=kubeconfigs/${COMPONENT}.kubeconfig

  kubectl config use-context default --kubeconfig=kubeconfigs/${COMPONENT}.kubeconfig
done

# copy kubelet & kube-proxy to workers
for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp \
    kubeconfigs/${instance}.kubeconfig \
    kubeconfigs/kube-proxy.kubeconfig \
  ${instance}:~/
done

# copy admin, controller-manager, scheduler to controllers
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp \
    kubeconfigs/admin.kubeconfig \
    kubeconfigs/kube-controller-manager.kubeconfig \
    kubeconfigs/kube-scheduler.kubeconfig \
  ${instance}:~/
done
