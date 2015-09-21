# nginx-consul-template
a simple dockerized loadbalancer for consul infrastructure 

Run Consul

    docker run -it -h node \  
        -p 8500:8500 \
        -p 53:53/udp \
        progrium/consul \
        -server \
        -bootstrap \
        -advertise $DOCKER_IP

Run Registrator

    docker run -it \  
        -v /var/run/docker.sock:/tmp/docker.sock \
        -h $DOCKER_IP progrium/registrator \
        consul://$DOCKER_IP:8500  

Run the loadbalancer

    docker run \  
        -e "CONSUL=$DOCKER_IP:8500" \
        -e "SERVICE=myservice-name" \
        -e "PROTOCOL=http" \
        -e "REVERSE=service-name/" \
        -e "METHOD=least_conn;"\
        -p 80:80 davinci1976/nginx-consul-template

Run your service `myservice-name`

    docker run -it \  
        -e "SERVICE_NAME=simple" \
        -p 8001:80 python/server

# Thanks to
Graham Jenson
    https://www.airpair.com/scalable-architecture-with-docker-consul-and-nginx

