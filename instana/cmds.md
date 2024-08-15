nc -zv mysql 3306
kubectl exec -it <shipping-pod-name> -- env | grep DB_
nslookup mysql
