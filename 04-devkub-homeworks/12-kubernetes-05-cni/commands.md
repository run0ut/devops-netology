```
kubectl exec hello-node-6d5f754cc9-bk4t7 -- curl -m 1 -s http://10.233.72.3:8080 | grep -e request_uri -e host -e client_address
kubectl exec hello-node-6d5f754cc9-mvdxn -- curl -m 1 -s http://10.233.72.2:8080 | grep -e request_uri -e host -e client_address
```
```
$ kubectl get pods -o wide
NAME                          READY   STATUS    RESTARTS   AGE   IP            NODE            NOMINATED NODE   READINESS GATES
hello-node-6d5f754cc9-bk4t7   1/1     Running   0          91m   10.233.72.2   n125-worker-0   <none>           <none>
hello-node-6d5f754cc9-mvdxn   1/1     Running   0          91m   10.233.72.3   n125-worker-0   <none>           <none>
```

