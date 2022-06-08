https://redis.io/docs/manual/scaling/

https://severalnines.com/database-blog/hash-slot-resharding-and-rebalancing-redis-cluster

https://netpoint-dc.com/blog/nastroika-redis-docker-dlya-produktovogo-ispolzovaniya/

https://netpoint-dc.com/blog/redis-cluster-linux/

https://programmer.ink/think/establishment-of-redis-cluster-redis-replication.html

https://alex.dzyoba.com/blog/redis-cluster/

[схемы](https://www.google.com/search?q=redis+sharding+replica&newwindow=1&source=lnms&tbm=isch&sa=X&ved=2ahUKEwicyLiK6Z34AhWMlYsKHURDA5cQ_AUoAXoECAEQAw&biw=1920&bih=947&dpr=1#imgrc=9lXwrpSMNoel8M)

https://www.javacodegeeks.com/2015/09/redis-clustering.html

https://www.javacodegeeks.com/2015/09/redis-sharding.html



Создать кластер: 
```bash
redis-cli --cluster create 51.250.77.151:6379 51.250.84.205:6379 51.250.69.57:6379
```
Например:
```log
$ redis-cli --cluster create 51.250.77.151:6379 51.250.84.205:6379 51.250.69.57:6379
>>> Performing hash slots allocation on 3 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
M: 79bd7ef83b053e86541631ac78a7c101c827a8fd 51.250.77.151:6379
   slots:[0-5460] (5461 slots) master
M: 0768d8bd53e383b783f3673cbcb1fb190752ef70 51.250.84.205:6379
   slots:[5461-10922] (5462 slots) master
M: b36d1f8c0f1bc4019b45baf4931755bafa287026 51.250.69.57:6379
   slots:[10923-16383] (5461 slots) master
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join
.
>>> Performing Cluster Check (using node 51.250.77.151:6379)
M: 79bd7ef83b053e86541631ac78a7c101c827a8fd 51.250.77.151:6379
   slots:[0-5460] (5461 slots) master
M: 0768d8bd53e383b783f3673cbcb1fb190752ef70 51.250.84.205:6379
   slots:[5461-10922] (5462 slots) master
M: b36d1f8c0f1bc4019b45baf4931755bafa287026 51.250.69.57:6379
   slots:[10923-16383] (5461 slots) master
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```
Объединить ноды в кластер https://redis.io/commands/cluster-meet/
```
redis-cli -h 51.250.77.151 CLUSTER MEET  51.250.84.205 6379
redis-cli -h 51.250.77.151 CLUSTER MEET 51.250.69.57 6379
```
Добавить слейв
```
redis-cli  --cluster add-node 51.250.77.151:6380 51.250.77.151:6379 --cluster-slave --cluster-master-id  0768d8bd53e383b783f3673cbcb1fb190752ef70
```
Посмотреть информацию по нодам в кластере
```
redis-cli -h 51.250.69.57 -p 6379 cluster nodes
```
Например
```
$ redis-cli -h 51.250.69.57 -p 6379 cluster nodes
79bd7ef83b053e86541631ac78a7c101c827a8fd 51.250.77.151:6379@16379 master - 0 1654703759346 1 connected 0-5460
0768d8bd53e383b783f3673cbcb1fb190752ef70 51.250.84.205:6379@16379 master - 0 1654703757337 2 connected 5461-10922
b36d1f8c0f1bc4019b45baf4931755bafa287026 10.128.0.30:6379@16379 myself,master - 0 1654703758000 3 connected 10923-16383
```
Посмотреть распределение слотов по нодам
```
redis-cli -h 51.250.69.57 -p 6379 cluster slots
```
Например:
```
$ redis-cli -h 51.250.69.57 -p 6379 cluster slots
1) 1) (integer) 0
   2) (integer) 5460
   3) 1) "51.250.77.151"
      2) (integer) 6379
      3) "79bd7ef83b053e86541631ac78a7c101c827a8fd"
2) 1) (integer) 5461
   2) (integer) 10922
   3) 1) "51.250.84.205"
      2) (integer) 6379
      3) "0768d8bd53e383b783f3673cbcb1fb190752ef70"
3) 1) (integer) 10923
   2) (integer) 16383
   3) 1) "10.128.0.30"
      2) (integer) 6379
      3) "b36d1f8c0f1bc4019b45baf4931755bafa287026"
```
Проверить состояние кластера
```
redis-cli --cluster check 51.250.77.151:6379
```
Например
```
$ redis-cli --cluster check 51.250.77.151:6379
51.250.77.151:6379 (79bd7ef8...) -> 0 keys | 5461 slots | 0 slaves.
51.250.84.205:6379 (0768d8bd...) -> 0 keys | 5462 slots | 0 slaves.
51.250.69.57:6379 (b36d1f8c...) -> 0 keys | 5461 slots | 0 slaves.
[OK] 0 keys in 3 masters.
0.00 keys per slot on average.
>>> Performing Cluster Check (using node 51.250.77.151:6379)
M: 79bd7ef83b053e86541631ac78a7c101c827a8fd 51.250.77.151:6379
   slots:[0-5460] (5461 slots) master
M: 0768d8bd53e383b783f3673cbcb1fb190752ef70 51.250.84.205:6379
   slots:[5461-10922] (5462 slots) master
M: b36d1f8c0f1bc4019b45baf4931755bafa287026 51.250.69.57:6379
   slots:[10923-16383] (5461 slots) master
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```
`cluster info`:
```
$ redis-cli -h 51.250.69.57 -p 6379 cluster info
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:3
cluster_size:3
cluster_current_epoch:3
cluster_my_epoch:3
cluster_stats_messages_ping_sent:284
cluster_stats_messages_pong_sent:281
cluster_stats_messages_meet_sent:1
cluster_stats_messages_sent:566
cluster_stats_messages_ping_received:281
cluster_stats_messages_pong_received:285
cluster_stats_messages_received:566
```