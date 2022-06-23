```
kubectl exec hello-node-6b89d599b9-2vtqk -- curl -s http://10.244.88.138:8080 --connect-timeout 3
kubectl exec hello-node-6b89d599b9-2vtqk -- curl -s http://10.244.88.130:8080 --connect-timeout 3
kubectl exec hello-node-6b89d599b9-2vtqk -- curl -s http://localhost:8080 --connect-timeout 3
kubectl exec hello-node-6b89d599b9-lf9qt -- curl -s http://10.244.88.138:8080 --connect-timeout 3
kubectl exec hello-node-6b89d599b9-lf9qt -- curl -s http://localhost:8080 --connect-timeout 3
```
```
15:49:33 ~ sergey@work10600:~/git/devops-netology/04-devkub-homeworks/12-kubernetes-05-cni (main=)$ kubectl get pods -o wide
NAME                          READY   STATUS    RESTARTS   AGE     IP              NODE              NOMINATED NODE   READINESS GATES
hello-node-6b89d599b9-2vtqk   1/1     Running   0          127m    10.244.88.138   netology122-vm1   <none>           <none>
hello-node-6b89d599b9-lf9qt   1/1     Running   0          3h55m   10.244.88.130   netology122-vm1   <none>           <none>
```