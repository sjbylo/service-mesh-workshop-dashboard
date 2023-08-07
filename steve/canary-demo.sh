#!/bin/bash -ex
# This script helps to demo canary release using a Host header.

# log into the cluster 
oc login -u user1 -p openshift --insecure-skip-tls-verify     

# Set up the below VS in the workshop ... see below. 
oc replace -f - <<END
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: userprofile
  namespace: user1
spec:
  hosts:
  - userprofile
  http:
  - match:
    - headers:
        user:
          exact: steve
    route:
    - destination:
        host: userprofile
        subset: v3
  - route:
    - destination:
        host: userprofile
        subset: v1
---
apiVersion: networking.istio.io/v1beta1
kind: DestinationRule
metadata:
  name: userprofile
  namespace: user1
spec:
  host: userprofile
  subsets:
  - labels:
      version: "1.0"
    name: v1
  - labels:
      version: "2.0"
    name: v2
  - labels:
      version: "3.0"
    name: v3
END

GW=`oc get route istio-ingressgateway -n user1-istio --template='{{ .spec.host }}'`

oc set env dc app-ui NODE_ENV=dev DEBUG='*'.   # set debug mode in the app-ui so we can see the user ID used

oc rollout status dc app-ui
sleep 1

pod=`oc get po -l app=app-ui -oname`

curl -o /dev/null  $GW/profile    # get a profile 

while ! oc logs $pod | grep -qi /users/      # fetch user id (used below)
do
	sleep 1
done

# Fetch user id
URL=$(oc logs $pod | grep -i /users/| tail -1 | awk '{print $NF}')

# example => http://userprofile:8080/users/575ddb6a-8d2f-4baf-9e7e-4d0184d69259


# Verify it's working
oc rsh $pod curl -H"user: steve" $URL | grep -o '"styleId":"."' | grep styleId.*3
oc rsh $pod curl -H"user: jane" $URL | grep -o '"styleId":"."' | grep styleId.*1

set +xe

clear
echo 
echo #############################
echo 

while true
do
	echo "Send reaquest as 'steve'"
	echo "oc rsh $pod curl -H\"user: steve\" $URL | grep -o '\"styleId\":\".\"'"
	read yn
	oc rsh $pod curl -H"user: steve" $URL | grep -o '"styleId":"."'
	echo 

	echo "Send reaquest as 'jane'"
	echo "oc rsh $pod curl -H\"user: jane\" $URL | grep -o '\"styleId\":\".\"'"
	read yn
	oc rsh $pod curl -H"user: jane" $URL | grep -o '"styleId":"."'
	echo 
done

