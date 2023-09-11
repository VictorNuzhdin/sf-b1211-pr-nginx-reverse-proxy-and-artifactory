upstream tomcat {
    #server 127.0.0.1:8080 fail_timeout=0;
    server 10.0.10.11:8080 fail_timeout=0;
}

server {

    root /var/www/gw2.dotspace.ru/html;
    index index.html;

    # server_name gw2.dotspace.ru www.gw2.dotspace.ru;
    server_name gw2.dotspace.ru;

    location / {
        try_files $uri $uri/ =404;
    }

    ## Redirects #1 to external Jenkins server
    ## *if HTTP Get request is
    ##  http://gw2.dotspace.ru/cicd
    ##  redirect request to
    ##  https://jenkins.dotspace.ru
    ## *1.0
    location /cicd {
        rewrite ^/cicd(.*)$ https://jenkins.dotspace.ru/$1 redirect;
    }

    ## Redirects #2 to internal network Tomcat server
    ## *2.0
    location /tomcat {
        include proxy_params;
        proxy_pass http://tomcat/;
    }
    ## *2.1
    location /manager/ {
        rewrite ^/manager/(.*)$ https://gw2.dotspace.ru/tomcat/manager/$1 redirect;
    }
    ## *2.2
    location /host-manager/ {
        rewrite ^/host-manager/(.*)$ https://gw2.dotspace.ru/tomcat/host-manager/$1 redirect;
    }
    ## *2.3
    location /examples/ {
        rewrite ^/examples/(.*)$ https://gw2.dotspace.ru/tomcat/examples/$1 redirect;
    }
    ## *2.4
    location /docs/ {
        rewrite ^/docs/(.*)$ https://gw2.dotspace.ru/tomcat/docs/$1 redirect;
    }

    ## Redirects #4 to internal Tomcat Java webapp
    ## *3.0
    location /apps/app1/ {
        ##..v1
        #include proxy_params;
        #proxy_pass http://tomcat/examples/servlets/HelloWorldExample;
        #
        ##..v2 
        proxy_pass http://10.0.10.11:8080/examples/servlets/servlet/HelloWorldExample;
        #
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Port $server_port;
    }


    ## HTTPS/SSL Configuration with "Lets Encrypt" and "certbot"
    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/gw2.dotspace.ru/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/gw2.dotspace.ru/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    ## Logging Configuration
    access_log    /var/log/nginx/gw2_dotspace_ru.access.log;
    error_log     /var/log/nginx/gw2_dotspace_ru.error.log;
}

server {
    if ($host = gw2.dotspace.ru) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    listen 80 default_server;
    server_name gw2.dotspace.ru;
    return 404; # managed by Certbot
}
