# volumes

 If pv size was 1GB and Claim was 5GB it gives error like  Cannot bind to requested volume "test-pv": requested PV is too small
 pv=1GB pvc=5GB[Cannot bind to requested volume "test-pv": requested PV is too small]
 volume and instance both are same az other wise 
 Nodes does not have ebs volume permissions u're unable to claim the volume 

 First I create volumes
 creating pv from the volume
 claim the volume using pvc
 using volume claim inside pod

 After that I remove the volume related policies from instance role

 Agian After I create pv and pvc successfully

 but pod creation was not because of lack of permissions

 Assigend those permissions to instance role

Again i tried pod creation it won't show any error on pod decribing
    Successfully assigned default/app to ip-192-168-79-44.ap-south-1.compute.internal
 but pod was in container creation state  after 2 to 3 mins pod come in to Running state


To define the reclaim policy for PersistentVolumes (PVs) and PersistentVolumeClaims (PVCs) in Kubernetes, you specify the `persistentVolumeReclaimPolicy` field in the PV definition. The reclaim policy determines what happens to the associated storage resource (PV) when the PVC bound to it is deleted. Here’s how you define it:


 - **PV Reclaim Policies**:
   - **Retain**: PV persists even after PVC deletion. Manual intervention required to reclaim.
   - **Recycle**: Kubernetes deletes data on the PV when PVC is deleted.
   - **Delete**: Kubernetes deletes PV immediately when PVC is deleted.

By defining these parameters correctly in your PV and PVC definitions, you control how Kubernetes manages storage resources throughout their lifecycle.


* give attch volume permissions to iam role attached worker nodes

* Install ebd csi driver
https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/install.md

