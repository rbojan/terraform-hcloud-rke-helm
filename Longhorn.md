# Longhorn

## Install

````

https://github.com/rancher/longhorn

kubectl apply -f https://raw.githubusercontent.com/rancher/longhorn/master/deploy/longhorn.yaml

TODO: change service

- name: http
  port: 80
  protocol: TCP
  targetPort: 8000

kubectl create -f https://raw.githubusercontent.com/rancher/longhorn/master/examples/storageclass.yaml
````

## Test

````
kubectl create -f https://raw.githubusercontent.com/rancher/longhorn/master/examples/pvc.yaml

terraform destroy -target RESOURCE_TYPE.NAME -target RESOURCE_TYPE2.NAME
````
