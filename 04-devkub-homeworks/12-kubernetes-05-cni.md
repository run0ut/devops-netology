# Домашнее задание к занятию "12.5 Сетевые решения CNI"

> После работы с Flannel появилась необходимость обеспечить безопасность для приложения. Для этого лучше всего подойдет Calico.
## Задание 1: установить в кластер CNI плагин Calico

> Для проверки других сетевых решений стоит поставить отличный от Flannel плагин — например, Calico. Требования: 
> * установка производится через ansible/kubespray;
> * после применения следует настроить политику доступа к hello-world извне. Инструкции [kubernetes.io](https://kubernetes.io/docs/concepts/services-networking/network-policies/), [Calico](https://docs.projectcalico.org/about/about-network-policy)

###  Установка производится через ansible/kubespray

Установил связкой [terraform + kubespray + ansible](./12-kubernetes-05-cni/terraform/).

Ноды
```console
$ yclist
VM
+----------------------+----------------+---------------+---------+---------------+-------------+
|          ID          |      NAME      |    ZONE ID    | STATUS  |  EXTERNAL IP  | INTERNAL IP |
+----------------------+----------------+---------------+---------+---------------+-------------+
| fhmahafu86sm6u04ubg3 | n125-worker-0  | ru-central1-a | RUNNING | 62.84.114.157 | 10.128.0.4  |
| fhmrharemujr8fhq3mp8 | n125-control-0 | ru-central1-a | RUNNING | 62.84.114.21  | 10.128.0.25 |
+----------------------+----------------+---------------+---------+---------------+-------------+
```
```console
$ kubectl get nodes -o wide
NAME             STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME
n125-control-0   Ready    control-plane   96m   v1.24.2   10.128.0.25   <none>        Ubuntu 20.04.4 LTS   5.4.0-120-generic   containerd://1.6.6
n125-worker-0    Ready    <none>          94m   v1.24.2   10.128.0.4    <none>        Ubuntu 20.04.4 LTS   5.4.0-120-generic   containerd://1.6.6
```
Деплоймент
```console
$ kubectl get deploy -o wide
NAME         READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                      SELECTOR
hello-node   2/2     2            2           90m   echoserver   k8s.gcr.io/echoserver:1.4   app=hello-node
```
Поды
```console
$ kubectl get pods -o wide
NAME                          READY   STATUS    RESTARTS   AGE   IP            NODE            NOMINATED NODE   READINESS GATES
hello-node-6d5f754cc9-bk4t7   1/1     Running   0          91m   10.233.72.2   n125-worker-0   <none>           <none>
hello-node-6d5f754cc9-mvdxn   1/1     Running   0          91m   10.233.72.3   n125-worker-0   <none>           <none>
```
Сервисы
```console
$ kubectl get services -o wide
NAME         TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE   SELECTOR
hello-node   LoadBalancer   10.233.41.14   <pending>     8080:31619/TCP   91m   app=hello-node
kubernetes   ClusterIP      10.233.0.1     <none>        443/TCP          97m   <none>
```
### Настроить политику доступа к hello-world извне

Добавил две политики:
* [accept-pods-communication](./12-kubernetes-05-cni/policies/accept-pods-communication.yml) - разрешает хождение трафика между репликами hello-node
* [default-ingress-deny](./12-kubernetes-05-cni/policies/default-ingress-deny.yml) - запрещает прочие коммуникации

Проверяем доступ без политик
```console
$ kubectl get netpol -A
No resources found
```
* Доступ от одного пода к другому - работает
    ```console
    18:37:58 ~ sergey@Intel8086:~/git/devops-netology/04-devkub-homeworks/12-kubernetes-05-cni/policies (main *=)
    $ kubectl exec hello-node-6d5f754cc9-bk4t7 -- curl -m 1 -s http://10.233.72.3:8080 | grep -e request_uri -e host -e client_address
    client_address=10.233.72.2
    request_uri=http://10.233.72.3:8080/
    host=10.233.72.3:8080
    18:39:12 ~ sergey@Intel8086:~/git/devops-netology/04-devkub-homeworks/12-kubernetes-05-cni/policies (main *=)
    $ kubectl exec hello-node-6d5f754cc9-mvdxn -- curl -m 1 -s http://10.233.72.2:8080 | grep -e request_uri -e host -e client_address
    client_address=10.233.72.3
    request_uri=http://10.233.72.2:8080/
    host=10.233.72.2:8080
    ```
* Доступ извне - работает
    ```console
    18:37:50 ~ sergey@Intel8086:~/git/devops-netology/04-devkub-homeworks/12-kubernetes-05-cni/policies (main *=)
    $ curl -s -m 1 http://62.84.114.21:31619 | grep -e request_uri -e host -e client_address
    client_address=10.233.101.0
    request_uri=http://62.84.114.21:8080/
    host=62.84.114.21:31619
    ```
Применяем политики
```console
$ kubectl apply -f accept-pods-communication.yml
networkpolicy.networking.k8s.io/accept-pods-communication created
```
```console
$ kubectl apply -f default-ingress-deny.yml
networkpolicy.networking.k8s.io/default-deny-ingress created
```
```console
$ kubectl get netpol -A
NAMESPACE   NAME                        POD-SELECTOR     AGE
default     accept-pods-communication   app=hello-node   22s
default     default-deny-ingress        app=hello-node   17s
```
* Доступ от одного пода к другому - по-прежнему работает
    ```console
    18:40:16 ~ sergey@Intel8086:~/git/devops-netology/04-devkub-homeworks/12-kubernetes-05-cni/policies (main *=)
    $ kubectl exec hello-node-6d5f754cc9-bk4t7 -- curl -m 1 -s http://10.233.72.3:8080 | grep -e request_uri -e host -e client_address
    client_address=10.233.72.2
    request_uri=http://10.233.72.3:8080/
    host=10.233.72.3:8080
    18:40:52 ~ sergey@Intel8086:~/git/devops-netology/04-devkub-homeworks/12-kubernetes-05-cni/policies (main *=)
    $  kubectl exec hello-node-6d5f754cc9-mvdxn -- curl -m 1 -s http://10.233.72.2:8080 | grep -e request_uri -e host -e client_address
    client_address=10.233.72.3
    request_uri=http://10.233.72.2:8080/
    host=10.233.72.2:8080
    ```
* Доступ извне - не работает.
    ```console
    18:42:17 ~ sergey@Intel8086:~/git/devops-netology/04-devkub-homeworks/12-kubernetes-05-cni/policies (main *=)
    $ curl -s -v -m 1 http://62.84.114.21:31619 | grep -e request_uri -e host -e client_address
    *   Trying 62.84.114.21:31619...
    * Connection timed out after 1001 milliseconds
    * Closing connection 0
    ```

## Задание 2: изучить, что запущено по умолчанию

> Самый простой способ — проверить командой calicoctl get <type>. Для проверки стоит получить список нод, ipPool и profile.
> Требования: 
> * установить утилиту calicoctl;
> * получить 3 вышеописанных типа в консоли.

### Установить утилиту calicoctl;

Установил по [документации](https://projectcalico.docs.tigera.io/maintenance/clis/calicoctl/install#install-calicoctl-as-a-binary-on-a-single-host)
```console
$ curl -L https://github.com/projectcalico/calico/releases/download/v3.23.1/calicoctl-linux-amd64 -o calicoctl
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100 56.4M  100 56.4M    0     0  3292k      0  0:00:17  0:00:17 --:--:-- 3347k
18:48:36 ~ sergey@Intel8086:~/git/devops-netology/04-devkub-homeworks/12-kubernetes-05-cni/policies (main=)
$ chmod +x ./calicoctl
```

### Получить 3 вышеописанных типа в консоли.

- ноды
    ```console
    $ ./calicoctl get node
    NAME
    n125-control-0
    n125-worker-0
    ```
- ipPool
    ```console
    $ ./calicoctl get ipPool
    NAME           CIDR             SELECTOR
    default-pool   10.233.64.0/18   all()
    ```
- profile
    ```console
    $ ./calicoctl get profile
    NAME
    projectcalico-default-allow
    kns.default
    kns.kube-node-lease
    kns.kube-public
    kns.kube-system
    ksa.default.default
    ksa.kube-node-lease.default
    ksa.kube-public.default
    ksa.kube-system.attachdetach-controller
    ksa.kube-system.bootstrap-signer
    ksa.kube-system.calico-node
    ksa.kube-system.certificate-controller
    ksa.kube-system.clusterrole-aggregation-controller
    ksa.kube-system.coredns
    ksa.kube-system.cronjob-controller
    ksa.kube-system.daemon-set-controller
    ksa.kube-system.default
    ksa.kube-system.deployment-controller
    ksa.kube-system.disruption-controller
    ksa.kube-system.dns-autoscaler
    ksa.kube-system.endpoint-controller
    ksa.kube-system.endpointslice-controller
    ksa.kube-system.endpointslicemirroring-controller
    ksa.kube-system.ephemeral-volume-controller
    ksa.kube-system.expand-controller
    ksa.kube-system.generic-garbage-collector
    ksa.kube-system.horizontal-pod-autoscaler
    ksa.kube-system.job-controller
    ksa.kube-system.kube-proxy
    ksa.kube-system.namespace-controller
    ksa.kube-system.node-controller
    ksa.kube-system.nodelocaldns
    ksa.kube-system.persistent-volume-binder
    ksa.kube-system.pod-garbage-collector
    ksa.kube-system.pv-protection-controller
    ksa.kube-system.pvc-protection-controller
    ksa.kube-system.replicaset-controller
    ksa.kube-system.replication-controller
    ksa.kube-system.resourcequota-controller
    ksa.kube-system.root-ca-cert-publisher
    ksa.kube-system.service-account-controller
    ksa.kube-system.service-controller
    ksa.kube-system.statefulset-controller
    ksa.kube-system.token-cleaner
    ksa.kube-system.ttl-after-finished-controller
    ksa.kube-system.ttl-controller
    ```