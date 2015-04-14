charset UTF-8;
index index.php index.html index.htm;

location / {
    try_files $uri $uri/ {{#MEMCACHED_ADDR}}@memcached{{/MEMCACHED_ADDR}}{{^MEMCACHED_ADDR}}@rewrites{{/MEMCACHED_ADDR}};
}

location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
    expires 24h;
    log_not_found off;
}

# redirect server error pages to the static page /50x.html
#
error_page 500 502 503 504 /50x.html;
location = /50x.html {
    root /usr/share/nginx/html;
}

{{#MEMCACHED_ADDR}}

# try to get result from memcached
location @memcached {
    default_type text/html;
    set $memcached_key data-$scheme://$host$request_uri;
    set $memcached_request 1;

    # exceptions
    # avoid cache serve of POST requests
    if ($request_method = POST) {
        set $memcached_request 0;
    }

    # avoid cache serve of wp-admin-like pages, starting with "wp-"
    if ($args) {
        set $memcached_request 0;
    }

    if ($http_cookie ~* "comment_author_|wordpressuser_|wp-postpass_|wordpress_logged_in_" ) {
        set $memcached_request 0;
    }

    if ($memcached_request = 1) {
        add_header X-Cache-Engine "WP-FFPC with memcache via nginx";
        memcached_pass memcached-servers;
        error_page 404 = @rewrites;
    }

    if ($memcached_request = 0) {
        rewrite ^ /index.php last;
    }
}

location @rewrites {
    add_header X-Cache-Engine "No cache";
    rewrite ^ /index.php last;
}

{{/MEMCACHED_ADDR}}
{{^MEMCACHED_ADDR}}

location @rewrites {
    rewrite ^ /index.php last;
}

{{/MEMCACHED_ADDR}}
