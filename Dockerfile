FROM nginx:latest
WORKDIR /usr/share/nginx/html
COPY welcome.html welcome.html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]