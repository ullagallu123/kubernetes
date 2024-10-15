# cordon node and drain the pods

kubectl drain i-07914383ae2618c77
node/i-07914383ae2618c77 already cordoned
error: unable to drain node "i-07914383ae2618c77" due to error: [cannot delete DaemonSet-managed Pods (use --ignore-daemonsets to ignore): kube-system/cilium-g4qhm, kube-system/ebs-csi-node-v8g2c, cannot delete Pods with local storage (use --delete-emptydir-data to override): kube-system/metrics-server-d5865ff47-bs9j6], continuing command...
There are pending nodes to be drained:
 i-07914383ae2618c77
cannot delete DaemonSet-managed Pods (use --ignore-daemonsets to ignore): kube-system/cilium-g4qhm, kube-system/ebs-csi-node-v8g2c
cannot delete Pods with local storage (use --delete-emptydir-data to override): kube-system/metrics-server-d5865ff47-bs9j6
ubuntu@SRK:~/kubernetes/instana$ kubectl drain i-07914383ae2618c77 --ignore-daemonsets
node/i-07914383ae2618c77 already cordoned
error: unable to drain node "i-07914383ae2618c77" due to error: cannot delete Pods with local storage (use --delete-emptydir-data to override): kube-system/metrics-server-d5865ff47-bs9j6, continuing command...
There are pending nodes to be drained:
 i-07914383ae2618c77
cannot delete Pods with local storage (use --delete-emptydir-data to override): kube-system/metrics-server-d5865ff47-bs9j6
ubuntu@SRK:~/kubernetes/instana$ kubectl drain i-07914383ae2618c77 --ignore-daemonsets  --delete-emptydir-data
node/i-07914383ae2618c77 already cordoned
Warning: ignoring DaemonSet-managed Pods: kube-system/cilium-g4qhm, kube-system/ebs-csi-node-v8g2c
evicting pod kube-system/metrics-server-d5865ff47-bs9j6
evicting pod kube-system/coredns-6b4469b66d-jphb9
evicting pod kube-system/coredns-6b4469b66d-ts2xb
evicting pod kube-system/coredns-autoscaler-84969b654b-zxwhr
evicting pod instana/catalogue-67575659d6-2n2vz
evicting pod instana/payment-878c6b6-6pwdw
error when evicting pods/"coredns-6b4469b66d-ts2xb" -n "kube-system" (will retry after 5s): Cannot evict pod as it would violate the pod's disruption budget.
pod/coredns-autoscaler-84969b654b-zxwhr evicted
pod/metrics-server-d5865ff47-bs9j6 evicted
evicting pod kube-system/coredns-6b4469b66d-ts2xb
error when evicting pods/"coredns-6b4469b66d-ts2xb" -n "kube-system" (will retry after 5s): Cannot evict pod as it would violate the pod's disruption budget.
pod/coredns-6b4469b66d-jphb9 evicted
evicting pod kube-system/coredns-6b4469b66d-ts2xb
pod/coredns-6b4469b66d-ts2xb evicted
pod/catalogue-67575659d6-2n2vz evicted
pod/payment-878c6b6-6pwdw evicted
node/i-07914383ae2618c77 drained

The `--delete-emptydir-data` option is needed when draining a Kubernetes node because some pods use `emptyDir` volumes for temporary storage. An `emptyDir` volume is created when a pod is assigned to a node and is deleted when the pod is removed. 

If a pod has an `emptyDir` volume, Kubernetes does not evict it by default to avoid losing the data stored in that volume. By using the `--delete-emptydir-data` flag, you tell Kubernetes to proceed with evicting these pods and allow the data in the `emptyDir` volumes to be deleted, which is acceptable in scenarios where the data is non-critical or temporary.

In your case, the `metrics-server` pod had an `emptyDir` volume, and without the `--delete-emptydir-data` option, Kubernetes prevented the eviction to avoid data loss.