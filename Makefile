DOCKER_RUN_ARGS=                                \
 --name=elk                                     \
 --privileged                                   \
 -d                                             \
 -h ELK	                                        \
 -p 80:80                                       \
 -p 9200:9200                                   \
 -p 9300:9300                                   \
 -p 5601:5601                                   \
 -v /var/lib/docker:/var/lib/docker

IMAGE=elk

all:
	ssh-keygen -q -b 1024 -t rsa -N "" -C "elk" -f id_rsa
	cp id_rsa* home/elk/.ssh/
#	cat ~/.ssh/id_rsa.pub > home/elk/.ssh/authorized_keys
	tar cvf home.tar home
	tar cvf etc.tar etc service
	docker build --rm -t elk .
	-docker kill elk
	-docker rm elk
	docker run $(DOCKER_RUN_ARGS) $(IMAGE) > /dev/null

clean:
	rm -fr home.tar etc.tar
	rm -fr id_rsa id_rsa.pub
#	-docker kill elk > /dev/null
#	-docker rm elk > /dev/null

.PHONY: all clean
