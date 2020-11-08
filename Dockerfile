FROM nginx:latest
COPY default.conf /etc/nginx/conf.d/
COPY index.html /var/www/html/
RUN chown -R nginx /var/www/html 


