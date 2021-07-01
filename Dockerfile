FROM nginx:1.20.1
COPY static-html-directory ./html*/usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]