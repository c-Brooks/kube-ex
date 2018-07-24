for d in certs/*; do
    echo "executing $d gencert script"
    cd $d
    ./gencert.sh
    cd -
done

# copy certificate and private key to each worker
# they will be used by worker's Kubelet
for instance in worker-0 worker-1 worker-2; do
  gcloud compute scp \
    certs/ca/ca.pem \
    certs/client/${instance}-key.pem \
    certs/client/${instance}.pem \
  ${instance}:~/
done

# copy certificate and private key for to each controller
for instance in controller-0 controller-1 controller-2; do
  gcloud compute scp \
    certs/ca/ca.pem \
    certs/ca/ca-key.pem \
    certs/api-server/kubernetes-key.pem \
    certs/api-server/kubernetes.pem \
    certs/service_acct/service-account-key.pem \
    certs/service_acct/service-account.pem \
  ${instance}:~/
done
