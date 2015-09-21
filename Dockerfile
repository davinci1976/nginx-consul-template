FROM nginx


#Install Curl
RUN apt-get update -qq && apt-get -y install curl

#Download and Install Consul Template
ENV CT_URL https://github.com/hashicorp/consul-template/releases/download/v0.10.0/consul-template_0.10.0_linux_amd64.tar.gz
RUN curl -L $CT_URL | tar -C /usr/local/bin --strip-components 1 -zxf -

#Setup Consul Template Files
RUN mkdir /etc/consul-templates
ENV CT_FILE /etc/consul-templates/nginx.conf

#Setup Nginx File
ENV NX_FILE /etc/nginx/conf.d/app.conf

#Default Variables
ENV CONSUL consul:8500
ENV SERVICE consul-8500
ENV REVERSE "" 
ENV METHOD "least_conn;"
ENV PROTOCOL "http"
# Command will
# 1. Write Consul Template File
# 2. Start Nginx
# 3. Start Consul Template

CMD echo "" > /etc/nginx/conf.d/app.conf;

CMD echo "upstream app {                 \n\
  $METHOD                                \n\
  {{range service \"$SERVICE\"}}         \n\
  server  {{.Address}}:{{.Port}};        \n\
  {{else}}server 127.0.0.1:65535;{{end}} \n\
}                                        \n\
server {                                 \n\
  location /$REVERSE {                   \n\
    proxy_pass $PROTOCOL://app;          \n\
    rewrite  ^/$REVERSE(.*)  /\$1 break; \n\
    proxy_set_header   Host \$host;      \n\
  }                                      \n\
}" > $CT_FILE; \
/usr/sbin/nginx -c /etc/nginx/nginx.conf \
& CONSUL_TEMPLATE_LOG=debug consul-template \
  -consul=$CONSUL \
  -template "$CT_FILE:$NX_FILE:/usr/sbin/nginx -s reload";
