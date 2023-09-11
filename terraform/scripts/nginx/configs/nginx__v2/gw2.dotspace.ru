server {

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

    ## Configuring SSL with "Lets Encrypt"
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/gw2.dotspace.ru/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/gw2.dotspace.ru/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

server {
    if ($host = gw2.dotspace.ru) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    listen 80 default_server;
    server_name gw2.dotspace.ru;
    return 404; # managed by Certbot
}
