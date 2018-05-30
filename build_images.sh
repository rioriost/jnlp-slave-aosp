docker build --target builder -t rioacrforjenkins.azurecr.io/slave-builder:3.19-1 .
docker build --cache-from rioacrforjenkins.azurecr.io/slave-builder:3.19-1 -t rioacrforjenkins.azurecr.io/android-7.0.0_r1 .
