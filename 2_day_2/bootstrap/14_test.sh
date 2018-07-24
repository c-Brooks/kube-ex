# test data encryption
kubectl create secret generic kube-ex \
  --from-literal="mykey=mydata"

# Get it straight from etcd
gcloud compute ssh controller-0 \
  --command "sudo ETCDCTL_API=3 etcdctl get \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/etcd/ca.pem \
  --cert=/etc/etcd/kubernetes.pem \
  --key=/etc/etcd/kubernetes-key.pem\
  /registry/secrets/default/kube-ex | hexdump -C"

# note
# k8s:enc:aescbc:v1:key1
# means we used aescbc to encrypt data

# test deployments
kubectl run nginx --image=nginx
kubectl get pods -l run=nginx

# test port forwarding
POD_NAME=$(kubectl get pods -l run=nginx -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward $POD_NAME 8080:80

# test logs
kubectl logs $POD_NAME

# test exec
kubectl exec -ti $POD_NAME -- nginx -v

# test services
kubectl expose deployment nginx --port 80 --type NodePort
# expose the node port
gcloud compute firewall-rules create kube-ex-allow-nginx-service \
  --allow=tcp:${NODE_PORT} \
  --network kube-ex
EXTERNAL_IP=$(gcloud compute instances describe worker-0 \
  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')

curl http://${EXTERNAL_IP}:${NODE_PORT}
