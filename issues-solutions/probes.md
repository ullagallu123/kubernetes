# Does liveness and rediness probes happend parallel
Yes, both **liveness** and **readiness** probes can run in parallel. Here's how they typically work:

### Liveness Probe:
- **Purpose:** The liveness probe checks whether the container is still running correctly. If the liveness probe fails, Kubernetes will restart the container.
- **Timing:** Liveness probes run independently of readiness probes. They follow their own schedule based on `initialDelaySeconds`, `periodSeconds`, `timeoutSeconds`, and `failureThreshold` settings.

### Readiness Probe:
- **Purpose:** The readiness probe checks whether the container is ready to serve requests. If the readiness probe fails, Kubernetes temporarily removes the container from service (i.e., it won't receive traffic).
- **Timing:** Like the liveness probe, the readiness probe runs on its own schedule, with `initialDelaySeconds`, `periodSeconds`, `timeoutSeconds`, and `failureThreshold` settings.

### Parallel Execution:
- Both probes run on their respective schedules and are executed independently. For example, if a container has both a liveness probe and a readiness probe configured, Kubernetes will perform each probe according to its specified timing settings.
  
- **Example:** If the readiness probe runs every 10 seconds and the liveness probe runs every 15 seconds, Kubernetes will check the container's readiness every 10 seconds and its liveness every 15 seconds, without one affecting the other.

### Scenarios:
- **Liveness Probe Failure:** If the liveness probe fails, the container is restarted, regardless of the readiness probe status.
- **Readiness Probe Failure:** If the readiness probe fails but the liveness probe succeeds, the container will stay running but will be temporarily removed from the service's endpoint list until it passes the readiness check again.

In essence, both probes operate independently but work together to ensure that the container is both healthy and ready to serve traffic.

# probes health checks

1. **`initialDelaySeconds: 10`**
   - This sets the initial delay before the readiness probe is performed for the first time. In this case, the probe will wait 10 seconds after the container starts before performing the first check.

2. **`periodSeconds: 10`**
   - This sets the interval between each readiness probe. The probe will be performed every 10 seconds.

3. **`timeoutSeconds: 5`**
   - This sets the maximum amount of time to wait for a response from the probe. If the probe doesn't get a response within 5 seconds, it is considered a failure.

4. **`failureThreshold: 3`**
   - This sets the number of consecutive failures needed to consider the container as not ready. If the probe fails 3 times in a row, Kubernetes will mark the container as not ready.

### Example Timeline:
- **0 seconds**: Container starts.
- **10 seconds**: The first readiness probe is performed.
- **10-15 seconds**: The probe waits for a response. If the probe doesn't respond within 5 seconds, it fails.
- **20 seconds**: The second probe is performed (if the first one failed).
- **30 seconds**: The third probe is performed (if the second one also failed).
- **40 seconds**: If all three probes fail, Kubernetes marks the container as not ready.

# Success Threashold in probes
In Kubernetes, there is no specific `successThreshold` for `readinessProbe` as there is for `livenessProbe`. The `readinessProbe` assumes a `successThreshold` of 1 by default, meaning the container is considered ready after just one successful probe. Here's a more detailed explanation:

- **`successThreshold`** (for `livenessProbe`): This optional field sets the number of consecutive successful checks required before the container is considered healthy. The default is `1`, meaning that a single successful probe is enough.

- **`readinessProbe`**: Unlike `livenessProbe`, the `readinessProbe` does not have a `successThreshold` field. Instead, it operates with an implicit `successThreshold` of `1`. This means that after the container passes the readiness check once, it is marked as "ready" to receive traffic.

So, for `readinessProbe`, as soon as it successfully responds to a probe, the container is considered ready. If it fails the probe, it must pass the probe again in the next check to be considered ready.

# probes are failed

The logs indicate that the `shipping` container in your Kubernetes pod is experiencing issues related to its health probes. Here's a breakdown:

1. **Readiness Probe Failure**:
   - The readiness probe is attempting to access the `/health` endpoint on port `8080`, but the connection is being refused. This suggests that the application inside the container might not be ready or listening on the specified port, which prevents the container from becoming "ready" to accept traffic.

2. **Liveness Probe Failure**:
   - The liveness probe is also failing for the same reason: the `/health` endpoint is not accessible. This failure indicates that the Kubernetes control plane thinks the container is unhealthy and restarts it to try to recover.

3. **Container Restarts**:
   - Due to the liveness probe failures, Kubernetes is restarting the container multiple times.

### Potential Causes and Solutions:

1. **Application Not Starting Properly**:
   - Ensure that the application inside the container is correctly configured and able to start up. Check the application logs to see if there are any errors preventing it from binding to port `8080`.

2. **Incorrect Port Configuration**:
   - Verify that the application is actually listening on port `8080`. If the application is using a different port, update the readiness and liveness probes to match the correct port.

3. **Delayed Startup**:
   - If the application takes longer to start, consider adjusting the `initialDelaySeconds`, `periodSeconds`, `failureThreshold`, and `timeoutSeconds` for the readiness and liveness probes to give the application more time to become ready.

4. **Network Issues**:
   - Ensure there are no network issues that could prevent the pod from accessing the specified IP and port.

5. **Configuration Error**:
   - Double-check the container's environment variables, command, and arguments to ensure that the application is starting with the correct configuration.
