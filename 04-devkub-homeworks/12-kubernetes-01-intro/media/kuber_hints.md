
Команда `kubectl get deployments`, например:
```
kubectl get deployments
```
```
root@netology121-vm1:~# kubectl get deployments
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
hello-node   1/1     1            1           18m
```
Команда `kubectl get pods`, например:
```
kubectl get pods
```
```
root@netology121-vm1:~# kubectl get pods
NAME                          READY   STATUS    RESTARTS   AGE
hello-node-6b89d599b9-pbdkx   1/1     Running   0          18m
```
Команда `kubectl get events`, например:
```
kubectl get events
```
```
root@netology121-vm1:~# kubectl get events | head
LAST SEEN   TYPE      REASON                                             OBJECT                             MESSAGE
19m         Normal    Scheduled                                          pod/hello-node-6b89d599b9-pbdkx    Successfully assigned default/hello-node-6b89d599b9-pbdkx to netology121-vm1
19m         Normal    Pulling                                            pod/hello-node-6b89d599b9-pbdkx    Pulling image "k8s.gcr.io/echoserver:1.4"
18m         Normal    Pulled                                             pod/hello-node-6b89d599b9-pbdkx    Successfully pulled image "k8s.gcr.io/echoserver:1.4" in 14.87499406s
18m         Normal    Created                                            pod/hello-node-6b89d599b9-pbdkx    Created container echoserver
18m         Normal    Started                                            pod/hello-node-6b89d599b9-pbdkx    Started container echoserver
19m         Normal    SuccessfulCreate                                   replicaset/hello-node-6b89d599b9   Created pod: hello-node-6b89d599b9-pbdkx
19m         Normal    ScalingReplicaSet                                  deployment/hello-node              Scaled up replica set hello-node-6b89d599b9 to 1
19m         Normal    NodeHasSufficientMemory                            node/netology121-vm1               Node netology121-vm1 status is now: NodeHasSufficientMemory
19m         Normal    NodeHasNoDiskPressure                              node/netology121-vm1               Node netology121-vm1 status is now: NodeHasNoDiskPressure
```
Команда `kubectl config view`, например:
```
kubectl config view
```
```
root@netology121-vm1:~# kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority: /root/.minikube/ca.crt
    extensions:
    - extension:
        last-update: Tue, 14 Jun 2022 13:17:44 UTC
        provider: minikube.sigs.k8s.io
        version: v1.25.2
      name: cluster_info
    server: https://10.128.0.10:8443
  name: minikube
contexts:
- context:
    cluster: minikube
    extensions:
    - extension:
        last-update: Tue, 14 Jun 2022 13:17:44 UTC
        provider: minikube.sigs.k8s.io
        version: v1.25.2
      name: context_info
    namespace: default
    user: minikube
  name: minikube
current-context: minikube
kind: Config
preferences: {}
users:
- name: minikube
  user:
    client-certificate: /root/.minikube/profiles/minikube/client.crt
    client-key: /root/.minikube/profiles/minikube/client.key
```
Команда `kubectl get services`, например:
```
kubectl get services
```
```
root@netology121-vm1:~# kubectl get services
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
hello-node   LoadBalancer   10.105.96.172   <pending>     8080:30707/TCP   19m
kubernetes   ClusterIP      10.96.0.1       <none>        443/TCP          19m
```
Команда `minikube addons list`, например:
```
minikube addons list
```
```
root@netology121-vm1:~# minikube addons list | grep enabled
| dashboard                   | minikube | enabled ✅   | kubernetes                     |
| default-storageclass        | minikube | enabled ✅   | kubernetes                     |
| ingress                     | minikube | enabled ✅   | unknown (third-party)          |
| metrics-server              | minikube | enabled ✅   | kubernetes                     |
| storage-provisioner         | minikube | enabled ✅   | google                         |
```
Команда `kubectl get pod,svc -n kube-system`, например:
```
kubectl get pod,svc -n kube-system
```
```
root@netology121-vm1:~# kubectl get pod,svc -n kube-system
NAME                                          READY   STATUS    RESTARTS   AGE
pod/coredns-64897985d-ppfzl                   1/1     Running   0          20m
pod/etcd-netology121-vm1                      1/1     Running   0          20m
pod/kube-apiserver-netology121-vm1            1/1     Running   0          20m
pod/kube-controller-manager-netology121-vm1   1/1     Running   0          20m
pod/kube-proxy-jvchk                          1/1     Running   0          20m
pod/kube-scheduler-netology121-vm1            1/1     Running   0          20m
pod/metrics-server-6b76bd68b6-b9bh8           1/1     Running   0          20m
pod/storage-provisioner                       1/1     Running   0          20m

NAME                     TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                  AGE
service/kube-dns         ClusterIP   10.96.0.10       <none>        53/UDP,53/TCP,9153/TCP   20m
service/metrics-server   ClusterIP   10.104.250.131   <none>        443/TCP                  20m
```