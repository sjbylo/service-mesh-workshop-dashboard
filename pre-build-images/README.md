## Pre-build all images for all users

If you want your workshop participants to spend less time building images and more time focusing on Service Mesh, then use this script.

How to use this script:

```
$ oc whoami
cluster-admin

$ ./go.sh 30 5
```

The above would build images for 30 users (user1 to user30) and build 5 at a time (concurrently).

