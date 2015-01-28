charset UTF-8;
root {{NGINX_ROOT}};
index index.php index.html index.htm;

server_name {{NGINX_SERVER_NAME}};

location / {
    try_files $uri $uri/{{#MEMCACHED_ADDR}}@memcached{{/MEMCACHED_ADDR}};
}

location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
    expires 24h;
    log_not_found off;
}

# redirect server error pages to the static page /50x.html
#
error_page 500 502 503 504 /50x.html;
location = /50x.html {
    root {{NGINX_ROOT}};
}

# pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
#
location ~ (\.php) {
    try_files $uri =404;

    fastcgi_index                   index.php;
    fastcgi_connect_timeout         10;
    fastcgi_send_timeout            180;
    fastcgi_read_timeout            180;
    fastcgi_buffer_size             512k;
    fastcgi_buffers                 4 256k;
    fastcgi_busy_buffers_size       512k;
    fastcgi_temp_file_write_size    512k;
    fastcgi_intercept_errors        on;
    fastcgi_split_path_info         ^(.+\.php)(/.*)$;
    fastcgi_keep_conn               on;

    fastcgi_param	QUERY_STRING      $query_string;
    fastcgi_param	REQUEST_METHOD    $request_method;
    fastcgi_param	CONTENT_TYPE      $content_type;
    fastcgi_param	CONTENT_LENGTH    $content_length;
    fastcgi_param	SCRIPT_FILENAME   $document_root$fastcgi_script_name;
    fastcgi_param	SCRIPT_NAME       $fastcgi_script_name;
    fastcgi_param	REQUEST_URI       $request_uri;
    fastcgi_param	DOCUMENT_URI      $document_uri;
    fastcgi_param	DOCUMENT_ROOT     $document_root;
    fastcgi_param	SERVER_PROTOCOL   $server_protocol;
    fastcgi_param	GATEWAY_INTERFACE CGI/1.1;
    fastcgi_param	SERVER_SOFTWARE   nginx;
    fastcgi_param	REMOTE_ADDR       $remote_addr;
    fastcgi_param	REMOTE_PORT       $remote_port;
    fastcgi_param	SERVER_ADDR       $server_addr;
    fastcgi_param	SERVER_PORT       $server_port;
    fastcgi_param	SERVER_NAME       $server_name;
    fastcgi_param	PATH_INFO         $fastcgi_path_info;
    fastcgi_param	PATH_TRANSLATED   $document_root$fastcgi_path_info;
    fastcgi_param	REDIRECT_STATUS   200;

    # uncomment these for HTTPS usage
    fastcgi_param	HTTPS             $https if_not_empty;
    fastcgi_param	SSL_PROTOCOL      $ssl_protocol if_not_empty;
    fastcgi_param	SSL_CIPHER        $ssl_cipher if_not_empty;
    fastcgi_param	SSL_SESSION_ID    $ssl_session_id if_not_empty;
    fastcgi_param	SSL_CLIENT_VERIFY $ssl_client_verify if_not_empty;

    fastcgi_pass {{PHP_FPM_ADDR}}:{{PHP_FPM_PORT}};
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
