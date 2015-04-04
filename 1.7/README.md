# Docker 1.7 Nginx

The default configuration of nginx let's you add handlers for port 80 or 443
(when you provide an ssl certificate) to the server block by providing *.conf
files in /etc/nginx/handlers.

You can add additional configuration files as /etc/nginx/sites-enabled/*.conf,
to add other sites, or upstream blocks etc.

If you set the `NGINX_SKIP_DEFAULT_SITE` environment variable, the default sites
will be skipped and you will have to provide one or more configuration files in
/etc/nginx/sites-available/*.conf

If you end any file in /etc/nginx with a `.mo` extension, then you can use
mustache templating from environment variables as provided by the `mo` bash
mustache implementation.
