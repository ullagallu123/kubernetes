Warning  FailedScheduling  3m50s  default-scheduler  0/2 nodes are available: 2 Insufficient cpu. preemption: 0/2 nodes are available: 2 No preemption victims found for incoming pod.

indicates that your pod could not be scheduled because there isn't enough available CPU resource on any of the nodes in your cluster, even though you believe there should be enough CPU.

due to the limits and requests definition 