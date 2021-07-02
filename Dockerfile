FROM nginx:latest
COPY ./*.html /usr/share/nginx/html
RUN chmod +r /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]