# Usa um servidor web leve
FROM nginx:alpine

# Copia o nosso arquivo HTML para a pasta padrão do Nginx
COPY index.html /usr/share/nginx/html/index.html

# Expõe a porta 80
EXPOSE 80

# Inicia o servidor
CMD ["nginx", "-g", "daemon off;"]