server {
    listen 80 default_server;

    root /var/www/gw2.dotspace.ru/html;
    index index.html;

    # server_name gw2.dotspace.ru www.gw2.dotspace.ru;
    server_name gw2.dotspace.ru;

    location / {
        try_files $uri $uri/ =404;
    }

    ## If HTTP Get request is
    ## http://gw2.dotspace.ru/cicd
    ## redirect request to
    ## https://jenkins.dotspace.ru
    location /cicd {
        rewrite ^/cicd(.*)$ https://jenkins.dotspace.ru/$1 redirect;
    }

}
