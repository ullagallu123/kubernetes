#!/bin/bash
NIHA=/home/ubuntu/kubernetes
NS1=instana
NS2=expense

print_message() {
    echo "$1"
}

print_message "Starting Instana Project Mongo,Mysql,Rabbit and Redis.....!"
kubectl apply -f $NIHA/instana/mongo -n $NS1
kubectl apply -f $NIHA/instana/mysql -n $NS1
kubectl apply -f $NIHA/instana/rabbit -n $NS1
kubectl apply -f $NIHA/instana/redis -n $NS1
print_message "Ending Instana Porject Mongo,Mysql,Rabbit and Redis.......!"
sleep 60

print_message "Starting Catalogue,User and Cart..........................!"
kubectl apply -f $NIHA/instana/catalogue -n $NS1
kubectl apply -f $NIHA/instana/user -n $NS1
kubectl apply -f $NIHA/instana/cart -n $NS1
print_message "Ending Catalogue,User and Cart..........................!"
sleep 30
print_message "Starting Shipping.......................................!"
kubectl apply -f $NIHA/instana/shipping -n $NS1
print_message "Ending Shipping.........................................!"
sleep 20
print_message "Starting Payment........................................!"
kubectl apply -f $NIHA/instana/payment -n $NS1
print_message "Ending Payment..........................................!"
sleep 10
print_message "Starting dispatch........................................!"
kubectl apply -f $NIHA/instana/dispatch -n $NS1
print_message "Delete dispatch..........................................!"
sleep 10 
print_message "Starting web.............................................!"
kubectl apply -f $NIHA/instana/web -n $NS1
print_message "Ending web...............................................!"

print_message "Starting mysql ..........................................!"
kubectl apply -f $NIHA/expense/mysql -n $NS2
print_message "Ending mysql..............................................!"
sleep 30
print_message "Starting Backend..........................................!"
kubectl apply -f $NIHA/expense/backend -n $NS2
print_message "Ending Backend............................................!"
print_message "Starting frontend.........................................!"
kubectl apply -f $NIHA/expense/frontend -n $NS2
print_message "Ending frontend.........................................!"


