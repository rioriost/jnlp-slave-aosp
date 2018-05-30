#branch="slave-builder:3.19-1"
#docker build --target builder \
#	-t rioacrforjenkins.azurecr.io/${branch} .
#docker push rioacrforjenkins.azurecr.io/${branch}

base="rioacrforjenkins.azurecr.io/${branch}"
branch="aosp:7.0.0_r1"
docker build \
	--cache-from rioacrforjenkins.azurecr.io/$base \
	--build-arg BASEBRANCH=$base \
	--build-arg TGTBRANCH=$branch \
	-t rioacrforjenkins.azurecr.io/$branch .
docker push rioacrforjenkins.azurecr.io/$branch

#base="rioacrforjenkins.azurecr.io/${branch}"
#branch="aosp:7.0.0_r3"
#docker build \
#	--cache-from rioacrforjenkins.azurecr.io/${base} \
#	--build-arg BASE_BRANCH=${base} \
#	--build-arg BRANCH=${branch} \
#	-t rioacrforjenkins.azurecr.io/${branch} .
#docker push rioacrforjenkins.azurecr.io/${branch}
