FROM nginx:latest
COPY . .
RUN chmod +r /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]