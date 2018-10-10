# Deploying Istio with Minishift

This chapter explains deploying Istio with Minishift. This documentation is written for **minishift v1.25** with **openshift version 1.10**.


**Prerequisites:**

* [Minishift v1.25](https://docs.okd.io/latest/minishift/getting-started/installing.html) installed on your box. I have tested this with the following version of minishift running on my box

```
$ minishift version
minishift v1.25.0+90fb23e
```

* [OpenShift CLI](https://docs.openshift.org/latest/cli_reference/get_started_cli.html) is downloaded and installed on your workstation. I have tested this with the following version of OpenShift CLI running on my Mac.

```
$ oc version
oc v3.10.0+dd10d17
kubernetes v1.10.0+b81c8f8
features: Basic-Auth
```

### Create a Minishift Profile and Start Minishift

We will create a minishift profile named `servicemesh`.

Run the following commands to create a profile with name `servicemesh`, set the memory for your minishift vm to `8GB`, number of CPUs to `4`, enable image-caching in order not the download the images everytime, set openshift versionto `v3.10.0`. We will also enable the addons `admin-user` that creates adds a user with name `admin` and provides administrative privileges and also the `anyuid` addon.

```
minishift profile set servicemesh
minishift config set memory 8GB
minishift config set cpus 4
minishift config set image-caching true
minishift config set openshift-version v3.10.0
minishift addon enable admin-user
minishift addon enable anyuid 
```
> **Note** If you have previously created a profile with this name, either choose a different name or remove the existing profile by running the following commands
> 
```
minishift delete profile servicemesh
rm -rf ~/.minishift/profiles/servicemesh
```

Now start the minishift instance

```
 minishift start
```

Let us download the `istio addon` for minishift. 

> **Note:** You will have to figure out a way to download a specific directory `istio` from [https://github.com/minishift/minishift-addons](https://github.com/minishift/minishift-addons). In my case I am using [github-files-fetcher](https://github.com/Gyumeijie/github-files-fetcher).
> 
> **Other alternatives**	
>  
> * you can try git's [sparse checkout](https://github.community/t5/How-to-use-Git-and-GitHub/How-can-I-download-a-specific-folder-from-a-GitHub-repo/td-p/88)
> * you can clone all the addons by running `git clone https://github.com/minishift/minishift-addons`, but that will download a bunch of other addons as well

```
fetcher --url=https://github.com/minishift/minishift-addons/tree/master/add-ons/istio
```

Once fetched, you will see `istio` folder with the following contents

```
$ ls -r istio
istio_community_operator_template.yaml	installation.yaml
istio.addon.remove			README.adoc
istio.addon
```

Now let's install minishift istio addon, enable the addon and apply it to our current running minishift. 

```
minishift addon install ./istio
minishift addon enable istio
minishift addon apply istio
```

You will see the following output as the istio addon is applied to your minishift instance

```
-- Applying addon 'istio':
Prepare for install istio...
Installing istio-operator...
Installing Istio..
'minishift addons enable admin-user'
'minishift addons apply admin-user'
'minishift addons enable anyuid'
'minishift addons apply anyuid'
'oc adm policy add-scc-to-user anyuid -z default -n myproject'
'oc adm policy add-scc-to-user privileged -z default -n myproject'
Please wait for few seconds before all pods are up!
Watch the pods status via minishift console or oc get pods -w -n istio-system --as system:admin
```

As the output suggested let us watch the status of istio-system by running

```
oc get pods -w -n istio-system --as system:admin
```
This addon invokes an installer pod `openshift-ansible-istio-installer-job-xxxx` which installs istio on openshift and completes. This will take a few minutes. You should see the istio pods initializing until you see the final state as

```
NAME                                          READY     STATUS      RESTARTS   AGE
elasticsearch-0                               1/1       Running     0          4m
grafana-65db6b47c9-b999k                      1/1       Running     0          4m
istio-citadel-84fb7985bf-l98zc                1/1       Running     0          7m
istio-egressgateway-86f49899c9-4t4gx          1/1       Running     0          7m
istio-galley-655c4f9ccd-bmbc2                 1/1       Running     0          7m
istio-ingressgateway-8695db5498-sfxtg         1/1       Running     0          7m
istio-pilot-b969499c4-bkt9k                   2/2       Running     0          7m
istio-policy-5455899b66-x44v6                 2/2       Running     0          7m
istio-sidecar-injector-8975849b4-m5rdc        1/1       Running     0          7m
istio-statsd-prom-bridge-7f44bb5ddb-z6m89     1/1       Running     0          7m
istio-telemetry-584c9ff7f5-4s847              2/2       Running     0          7m
jaeger-agent-4jj4v                            1/1       Running     0          2m
jaeger-collector-7764fc77b6-drk4l             1/1       Running     1          2m
jaeger-query-5c7fb9878d-h9ztr                 1/1       Running     0          2m
kiali-5dd65695f7-vrd96                        1/1       Running     0          2m
openshift-ansible-istio-installer-job-5smn2   0/1       Completed   0          9m
prometheus-84bd4b9796-kgc9z                   1/1       Running     0          7m
```


Now you have an OpenShift cluster running on your box along with openshift istio framework. The openshift istio framework also includes monitoring using `prometheus` and `grafana`, request tracing using `jaeger`, visualization using `kiali` in addition to the key istio components such as `pilot`, `mixer`, `sidecar-injector`, and `citadel`.


### Download Istio Samples

While we are already running Istio on minishift now, let us do some extra steps to get the samples and istio cli downloaded to our box. 

You can download Istio binaries and samples corresponding to your OS from here [https://github.com/istio/istio/releases](https://github.com/istio/istio/releases) 

If you are using Mac or Linux you can run the following command that will extract the latest release automatically

```
curl -L https://git.io/getLatestIstio | sh -
```

I am testing with Istio version `1.0.2`. 

```
cd istio-1.0.2
```

Set the path to `istioctl` binary or copy to a location where it can run. As an example on Mac, I am copying istioctl to `/usr/local/bin` so that I can run this command. Verify running `istioctl version`.

```
$ cp bin/istioctl /usr/local/bin

$ which istioctl
/usr/local/bin/istioctl

$ istioctl version
Version: 1.0.2
GitRevision: d639408fded355fb906ef2a1f9e8ffddc24c3d64
User: root@66ce69d4a51e
Hub: gcr.io/istio-release
GolangVersion: go1.10.1
BuildStatus: Clean
```

### Verify Istio

Switch over to `istio-system` project and understand all the components that are deployed. Look at the service accounts, pods, and different types of custom resource definitions added by the previous step. You will find the 5 core components of Istio running as pods and their correspoding deployments i.e, ca, pilot, mixer, ingress and egress.


```
$ oc project istio-system

$ oc get sa
NAME                                     SECRETS   AGE
builder                                  2         7h
default                                  2         7h
deployer                                 2         7h
elasticsearch                            2         7h
grafana                                  2         7h
istio-citadel-service-account            2         7h
istio-egressgateway-service-account      2         7h
istio-galley-service-account             2         7h
istio-ingressgateway-service-account     2         7h
istio-mixer-service-account              2         7h
istio-pilot-service-account              2         7h
istio-sidecar-injector-service-account   2         7h
jaeger                                   2         7h
kiali-service-account                    2         7h
openshift-ansible                        2         7h
prometheus                               2         7h

$ oc get pods
NAME                            READY     STATUS    RESTARTS   AGE
istio-ca-2617747623-0ch0b       1/1       Running   0          15s
istio-egress-2389443630-l8706   1/1       Running   0          16s
istio-ingress-355016184-nd4gp   1/1       Running   0          16s
istio-mixer-3229407178-v3q3m    2/2       Running   0          19s
istio-pilot-589912157-7x7p7     1/1       Running   0          17s

$ oc get crd
NAME                                                          AGE
adapters.config.istio.io                                      7h
apikeys.config.istio.io                                       7h
attributemanifests.config.istio.io                            7h
authorizations.config.istio.io                                7h
bypasses.config.istio.io                                      7h
checknothings.config.istio.io                                 7h
circonuses.config.istio.io                                    7h
deniers.config.istio.io                                       7h
destinationrules.networking.istio.io                          7h
edges.config.istio.io                                         7h
envoyfilters.networking.istio.io                              7h
fluentds.config.istio.io                                      7h
gateways.networking.istio.io                                  7h
handlers.config.istio.io                                      7h
httpapispecbindings.config.istio.io                           7h
httpapispecs.config.istio.io                                  7h
installations.istio.openshift.com                             7h
instances.config.istio.io                                     7h
kubernetesenvs.config.istio.io                                7h
kuberneteses.config.istio.io                                  7h
listcheckers.config.istio.io                                  7h
listentries.config.istio.io                                   7h
logentries.config.istio.io                                    7h
memquotas.config.istio.io                                     7h
meshpolicies.authentication.istio.io                          7h
metrics.config.istio.io                                       7h
noops.config.istio.io                                         7h
opas.config.istio.io                                          7h
openshiftwebconsoleconfigs.webconsole.operator.openshift.io   7h
policies.authentication.istio.io                              7h
prometheuses.config.istio.io                                  7h
quotas.config.istio.io                                        7h
quotaspecbindings.config.istio.io                             7h
quotaspecs.config.istio.io                                    7h
rbacconfigs.rbac.istio.io                                     7h
rbacs.config.istio.io                                         7h
redisquotas.config.istio.io                                   7h
reportnothings.config.istio.io                                7h
rules.config.istio.io                                         7h
servicecontrolreports.config.istio.io                         7h
servicecontrols.config.istio.io                               7h
serviceentries.networking.istio.io                            7h
servicerolebindings.rbac.istio.io                             7h
serviceroles.rbac.istio.io                                    7h
signalfxs.config.istio.io                                     7h
solarwindses.config.istio.io                                  7h
stackdrivers.config.istio.io                                  7h
statsds.config.istio.io                                       7h
stdios.config.istio.io                                        7h
templates.config.istio.io                                     7h
tracespans.config.istio.io                                    7h
virtualservices.networking.istio.io                           7h

$ oc get attributemanifests
NAME         AGE
istioproxy   7h
kubernetes   7h


$ oc get metrics
NAME              AGE
requestcount      7h
requestduration   7h
requestsize       7h
responsesize      7h
tcpbytereceived   7h
tcpbytesent       7h


$ oc get prometheuses
NAME      AGE
handler   7h


$ oc get rules
NAME                     AGE
kubeattrgenrulerule      7h
promhttp                 7h
promtcp                  7h
stdio                    7h
stdiotcp                 7h
tcpkubeattrgenrulerule   7h

$ oc get logentries
NAME           AGE
accesslog      7h
tcpaccesslog   7h


$ oc get stdios
NAME      AGE
handler   7h

$ oc get deployments
NAME                       DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
grafana                    1         1         1            1           7h
istio-citadel              1         1         1            1           7h
istio-egressgateway        1         1         1            1           7h
istio-galley               1         1         1            1           7h
istio-ingressgateway       1         1         1            1           7h
istio-pilot                1         1         1            1           7h
istio-policy               1         1         1            1           7h
istio-sidecar-injector     1         1         1            1           7h
istio-statsd-prom-bridge   1         1         1            1           7h
istio-telemetry            1         1         1            1           7h
jaeger-collector           1         1         1            1           7h
jaeger-query               1         1         1            1           7h
kiali                      1         1         1            1           7h
prometheus                 1         1         1            1           7h
```

Note the services running here. 

```
$ oc get svc
NAME                       TYPE           CLUSTER-IP       EXTERNAL-IP                   PORT(S)                                                                                                                   AGE
elasticsearch              ClusterIP      172.30.221.120   <none>                        9200/TCP                                                                                                                  7h
elasticsearch-cluster      ClusterIP      172.30.146.4     <none>                        9300/TCP                                                                                                                  7h
grafana                    ClusterIP      172.30.98.124    <none>                        3000/TCP                                                                                                                  7h
istio-citadel              ClusterIP      172.30.7.128     <none>                        8060/TCP,9093/TCP                                                                                                         7h
istio-egressgateway        ClusterIP      172.30.42.76     <none>                        80/TCP,443/TCP                                                                                                            7h
istio-galley               ClusterIP      172.30.40.24     <none>                        443/TCP,9093/TCP                                                                                                          7h
istio-ingressgateway       LoadBalancer   172.30.57.84     172.29.203.39,172.29.203.39   80:31380/TCP,443:31390/TCP,31400:31400/TCP,15011:30316/TCP,8060:32290/TCP,853:31213/TCP,15030:30194/TCP,15031:31527/TCP   7h
istio-pilot                ClusterIP      172.30.7.142     <none>                        15010/TCP,15011/TCP,8080/TCP,9093/TCP                                                                                     7h
istio-policy               ClusterIP      172.30.57.36     <none>                        9091/TCP,15004/TCP,9093/TCP                                                                                               7h
istio-sidecar-injector     ClusterIP      172.30.76.218    <none>                        443/TCP                                                                                                                   7h
istio-statsd-prom-bridge   ClusterIP      172.30.56.73     <none>                        9102/TCP,9125/UDP                                                                                                         7h
istio-telemetry            ClusterIP      172.30.16.103    <none>                        9091/TCP,15004/TCP,9093/TCP,42422/TCP                                                                                     7h
jaeger-collector           ClusterIP      172.30.21.135    <none>                        14267/TCP,14268/TCP,9411/TCP                                                                                              7h
jaeger-query               LoadBalancer   172.30.102.230   172.29.59.125,172.29.59.125   80:30224/TCP                                                                                                              7h
kiali                      ClusterIP      172.30.178.25    <none>                        20001/TCP                                                                                                                 7h
prometheus                 ClusterIP      172.30.63.80     <none>                        9090/TCP                                                                                                                  7h
tracing                    LoadBalancer   172.30.226.196   172.29.56.4,172.29.56.4       80:31411/TCP                                                                                                              7h
zipkin                     ClusterIP      172.30.218.223   <none>                        9411/TCP                                                                                                                  7h
```

`istio-ingressgateway` is the entrypoint for all your traffic through Istio. The simplest way to get our routing to work on OpenShift is to expose this service as an openshift route so that the openshift router that captures traffic on ports 80/443 will send the traffic to this `istio-ingressgateway` service and rest of the control is with `istio-ingressway`. This has been done for us by the istio installer.

Let us check the exposes services a.k.a routes

```
$ oc get route
NAME                   HOST/PORT                                                PATH      SERVICES               PORT              TERMINATION   WILDCARD
grafana                grafana-istio-system.192.168.64.72.nip.io                          grafana                http                            None
istio-ingressgateway   istio-ingressgateway-istio-system.192.168.64.72.nip.io             istio-ingressgateway   http2                           None
jaeger-query           jaeger-query-istio-system.192.168.64.72.nip.io                     jaeger-query           jaeger-query      edge          None
kiali                  kiali-istio-system.192.168.64.72.nip.io                            kiali                  http-kiali        reencrypt     None
prometheus             prometheus-istio-system.192.168.64.72.nip.io                       prometheus             http-prometheus                 None
tracing                tracing-istio-system.192.168.64.72.nip.io                          tracing                tracing           edge          None

```

Now the url [istio-ingressgateway-istio-system.192.168.64.72.nip.io](istio-ingressgateway-istio-system.192.168.64.72.nip.io) is my ingress point. You also see a bunch of other routes for jaeeger, grafana, prometheus etc. All these are also exposed by the installer for you. You can reach the respective applications using those routes. 


Istio is now up and running.


