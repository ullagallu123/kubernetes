## ERROR
Warning  FailedScheduling  4m50s  default-scheduler  0/6 nodes are available: 6 Insufficient cpu. preemption: 0/6 nodes are available: 6 No preemption victims found for incoming pod

 The warning message you're seeing indicates that Kubernetes is unable to schedule your pod because there are not enough resources available on any of the nodes in your cluster. Here's a breakdown of the message:

### Message Explanation:
- **`FailedScheduling`**: This indicates that the Kubernetes scheduler was unable to schedule the pod.
- **`0/6 nodes are available: 6 Insufficient cpu`**: This means that none of the 6 nodes in your cluster have enough CPU resources to accommodate the pod's CPU requests.
- **`preemption: 0/6 nodes are available: 6 No preemption victims found for incoming pod`**: Preemption is a process where Kubernetes evicts lower-priority pods to free up resources for higher-priority ones. In this case, the scheduler couldn't find any lower-priority pods to evict on the nodes, so it couldn't free up the necessary CPU resources for your pod.

### Possible Solutions:
1. **Reduce Pod Resource Requests**:
   - Check the CPU requests for your pod in the deployment or stateful set configuration. You may need to lower the `requests.cpu` value so that the pod requires fewer CPU resources.

2. **Increase Node Resources**:
   - If possible, increase the CPU resources on your existing nodes, either by resizing the instances (if you're using cloud-based infrastructure) or by adding more powerful nodes to your cluster.

3. **Add More Nodes to the Cluster**:
   - If your current nodes are fully utilized, consider adding more nodes to the cluster. This can provide additional resources for scheduling new pods.

4. **Pod Prioritization and Preemption**:
   - If you have pods with lower priority, you can assign a higher priority to the incoming pod using `priorityClassName`. This can trigger preemption, where lower-priority pods are evicted to make room for higher-priority ones.

5. **Cluster Autoscaler**:
   - If you're running your cluster in a cloud environment, you might consider enabling a cluster autoscaler. This tool automatically adds or removes nodes based on the resource demands of your cluster.

6. **Check Resource Quotas and Limits**:
   - Ensure that there aren't any resource quotas or limits set in the namespace that might be restricting the available CPU for new pods.

### Next Steps:
- Review the CPU requests and limits in your pod's configuration.
- Assess the available CPU resources on your nodes using commands like `kubectl describe nodes`.
- Take action based on the solutions mentioned above to resolve the scheduling issue.

---
To define priority on pods in Kubernetes, you can use a **PriorityClass**. This allows you to specify the importance of certain pods over others, which helps the scheduler decide which pods should be scheduled first and which pods can be preempted (i.e., evicted) if resources are scarce.

### Steps to Define Priority on Pods

1. **Create a PriorityClass**:
   - You first need to create a `PriorityClass` resource that defines the priority value and associated metadata.

2. **Assign the PriorityClass to Your Pods**:
   - After creating a `PriorityClass`, you can assign it to your pods by specifying the `priorityClassName` field in your pod or deployment configuration.

### Example: Creating a PriorityClass

Here’s an example of how to create a `PriorityClass`:

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: false
description: "This priority class is for important pods."
```

- **`name`**: The name of the PriorityClass, which you will use in your pods.
- **`value`**: The integer value representing the priority. Higher values indicate higher priority.
- **`globalDefault`**: If set to `true`, this PriorityClass will be used as the default for all pods that don’t specify a `priorityClassName`. Only one `PriorityClass` can be the global default.
- **`description`**: A description of what this PriorityClass is used for.

### Example: Assigning PriorityClass to a Pod

Once you have defined a `PriorityClass`, you can assign it to your pods like this:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: high-priority-pod
spec:
  priorityClassName: high-priority
  containers:
  - name: nginx
    image: nginx
```

### Applying to Deployments or StatefulSets

For deployments or stateful sets, you can similarly specify the `priorityClassName`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: high-priority-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      priorityClassName: high-priority
      containers:
      - name: nginx
        image: nginx
```

### Points to Consider
- **Preemption**: If a high-priority pod cannot be scheduled due to resource constraints, Kubernetes may preempt (evict) lower-priority pods to free up resources.
- **Negative Priority**: You can also define a `PriorityClass` with a negative value, which would indicate lower priority than other pods.

By defining and using `PriorityClass`, you can ensure that your critical workloads are prioritized over less important ones, especially in resource-constrained environments.