```

docker network create -d bridge cluster

# First we need to bootstrap the server
docker run -d --name node1 -e CLUSTER_ADDR= -e CLUSTER_NAME=cluster -e CLUSTER_NODE_NAME=node1 -e BACKUP_USER=sstuser -e BACKUP_PASSWORD=password -e MYSQL_ROOT_PASSWORD=password -e MYSQL_DATABASE=data -e MYSQL_USER=user -e MYSQL_PASSWORD=pass -e CHECK_PASSWORD=12345 -v /opt/mysql/1:/var/lib.mysql --net=cluster cluster-node

# Now we can connect new nodes to the cluster
docker run -d --name node2 -e CLUSTER_ADDR=node1,node2,node3 -e CLUSTER_NAME=cluster -e CLUSTER_NODE_NAME=node2 -e BACKUP_USER=sstuser -e BACKUP_PASSWORD=password -e CHECK_PASSWORD=12345 -v /opt/mysql/1:/var/lib.mysql --net=cluster cluster-node

docker run -d --name node3 -e CLUSTER_ADDR=node1,node2,node3 -e CLUSTER_NAME=cluster -e CLUSTER_NODE_NAME=node3 -e BACKUP_USER=sstuser -e BACKUP_PASSWORD=password -e CHECK_PASSWORD=12345 -v /opt/mysql/1:/var/lib.mysql --net=cluster cluster-node

# Now we can remove the bootstrap server and reconnect a real node1
docker stop node1 && docker rm node1

docker run -d --name node1 -p 13306:3306 -e CLUSTER_ADDR=node1,node2,node3 -e CLUSTER_NAME=cluster -e CLUSTER_NODE_NAME=node1 -e BACKUP_USER=sstuser -e BACKUP_PASSWORD=password -e CHECK_PASSWORD=12345 -v /opt/mysql/1:/var/lib.mysql --net=cluster cluster-node

docker run -d --name lb -e NODE_1=node1 -e NODE_2=node2 -e NODE_3=node3 -p 3306:3306 --net cluster lb

```
