#!/usr/bin/env sh

set -e

PORT=$1
REPO_ROOT_DIR=`pwd`/repo-root

if [ "$1" = "" ]; then
    echo "Usage: install.sh <port>"
    exit 1
fi

virtualenv _virtualenv
_virtualenv/bin/pip install whack
_virtualenv/bin/whack install git+https://github.com/mwilliamson/whack-package-nginx.git _nginx
mkdir -p $REPO_ROOT_DIR

cat > nginx.conf << EOF
daemon off;

worker_processes  4;

events {
    worker_connections  1024;
}

http {
    include       _nginx/conf/mime.types;
    default_type  application/octet-stream;

    sendfile        on;
    
    keepalive_timeout  65;

    server {
        listen       $PORT;
        listen       [::]:$PORT default ipv6only=on;
        server_name  localhost;
    
        root   $REPO_ROOT_DIR;
    
        location / {
                expires 0;
                autoindex on;
        }
    }
}
EOF

cat > run << EOF
#!/usr/bin/env sh
_nginx/sbin/nginx -c `pwd`/nginx.conf
EOF
chmod +x run
