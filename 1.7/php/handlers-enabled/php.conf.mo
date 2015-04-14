# Pass the PHP scripts to FastCGI server
#
location ~ (\.php) {
    try_files $uri =404;

    {{#PHP_FPM_CLIENT_MAX_BODY_SIZE}}
    client_max_body_size {{PHP_FPM_CLIENT_MAX_BODY_SIZE}};
    {{/PHP_FPM_CLIENT_MAX_BODY_SIZE}}

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
