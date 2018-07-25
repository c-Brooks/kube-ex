# ZOOKEEPER DEMO


```
# apply while watching the pods
k get po -w
k apply -f .
```

See the config
```
kubectl exec zk-0 -- cat /opt/zookeeper/conf/zoo.cfg
```

```
kubectl exec zk-0 zkCli.sh create /hello world
kubectl exec zk-1 zkCli.sh get /hello
```

Apply a change (CPU Request)
```
kubectl patch sts zk \
--type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources/requests/cpu", "value":"0.3"}]'

kubectl rollout status
```

See history of the deployment
```
kubectl rollout history sts/zk
```

Rollback
```
kubectl rollout undo sts/zk
```

cause an error
```
kubectl exec zk-0 -- pkill java
```


## Simulating Maintainance
```
kubectl get nodes
```

```
kubectl cordon <node>
kubectl get pdb zk-pdb
```

```

kubectl drain $(kubectl get pod zk-1 --template {{.spec.nodeName}}) --ignore-daemonsets --force --delete-local-data <node> cordoned
kubectl get pods -w
```

```
kubectl exec zk-0 zkCli.sh get /hello
```
```
kubectl uncordon <node>
```

```
# kill the pod
```

