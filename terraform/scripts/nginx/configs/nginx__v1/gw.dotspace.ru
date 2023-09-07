server {
    listen 80 default_server;

    root /var/www/gw.dotspace.ru/html;
    index index.html;

    # server_name gw.dotspace.ru www.gw.dotspace.ru;
    server_name gw.dotspace.ru;

    location / {
        try_files $uri $uri/ =404;
    }

    ## If HTTP Get request is
    ## http://gw.dotspace.ru/cicd
    ## redirect request to
    ## https://jenkins.dotspace.ru
    location /cicd {
        rewrite ^/cicd(.*)$ https://jenkins.dotspace.ru/$1 redirect;
    }

}
