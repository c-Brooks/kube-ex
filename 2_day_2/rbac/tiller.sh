# create serviceaccount named Tiller
kubectl create serviceaccount tiller --namespace kube-system

kubectl create -f tiller-clusterrolebinding.yaml

helm init --service-account tiller --upgrade
