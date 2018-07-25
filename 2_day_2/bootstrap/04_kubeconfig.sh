KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe kube-ex \
  --region $(gcloud config get-value compute/region) \
  --format 'value(address)')

# workers
for instance in worker-0 worker-1 worker-2; do
  kubectl config set-cluster kube-ex \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-credentials system:node:${instance} \
    --client-certificate=${instance}.pem \
    --client-key=${instance}-key.pem \
    --embed-certs=true \
    --kubeconfig=${instance}.kubeconfig

  kubectl config set-context default \
    --cluster=kube-ex \
    --user=system:node:${instance} \
    --kubeconfig=${instance}.kubeconfig

  kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done

# admin (kube-apiserver)
kubectl config set-cluster kube-ex \
  --certificate-authority=ca.pem \
  --embed-certs=true \
  --server=https://127.0.0.1:6443 \
  --kubeconfig=admin.kubeconfig

kubectl config set-credentials admin \
  --client-certificate=admin.pem \
  --client-key=admin-key.pem \
  --embed-certs=true \
  --kubeconfig=admin.kubeconfig

kubectl config set-context default \
  --cluster=kube-ex \
  --user=admin \
  --kubeconfig=admin.kubeconfig

kubectl config use-context default --kubeconfig=admin.kubeconfig

# other components
for COMPONENT in kube-proxy kube-controller-manager kube-scheduler; do
  kubectl config set-cluster kube-ex \
    --certificate-authority=ca.pem \
    --embed-certs=true \
    --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
    --kubeconfig=${COMPONENT}.kubeconfig

  kubectl config set-credentials system:${COMPONENT} \
    --client-certificate=${COMPONENT}.pem \
    --client-key=${COMPONENT}-key.pem \
    --embed-certs=true \
    --kubeconfig=${COMPONENT}.kubeconfig

  kubectl config set-context default \
    --cluster=kube-ex \
    --user=system:${COMPONENT} \
    --kubeconfig=${COMPONENT}.kubeconfig

  kubectl config use-context default --kubeconfig=${COMPONENT}.kubeconfig
done

# copy kubelet & kube-proxy to workers
for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp \
    ${instance}.kubeconfig \
    kube-proxy.kubeconfig \
  ${instance}:~/
done

# copy admin, controller-manager, scheduler to controllers
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp \
    admin.kubeconfig \
    kube-controller-manager.kubeconfig \
    kube-scheduler.kubeconfig \
  ${instance}:~/
done
