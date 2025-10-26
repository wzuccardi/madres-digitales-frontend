# ========================================
# Dockerfile Frontend - Producción
# Madres Digitales - Multi-stage con Nginx Alpine
# ========================================

# Etapa 1: Flutter Build
FROM ghcr.io/cirruslabs/flutter:3.19.6-stable AS builder

# Variables de entorno para build optimizado
ENV FLUTTER_WEB_USE_SKIA=true
ENV FLUTTER_WEB_CANVASKIT=true
ENV FLUTTER_WEB_AUTO_DETECT=false

WORKDIR /app

# Copiar solo archivos de dependencias
COPY pubspec.yaml pubspec.lock ./

# Descargar dependencias (con cache)
RUN flutter pub get --no-version-check

# Copiar código fuente
COPY . .

# Compilar para web con optimizaciones
RUN flutter build web \
    --release \
    --web-renderer canvaskit \
    --no-tree-shake-icons \
    --csp \
    --no-pub

# Etapa 2: Nginx Optimizado
FROM nginx:1.25-alpine AS runtime

# Instalar herramientas adicionales mínimas
RUN apk add --no-cache \
    curl \
    ca-certificates \
    && rm -rf /var/cache/apk/* \
    && addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# Eliminar configuración por defecto y archivos no necesarios
RUN rm -rf /etc/nginx/conf.d/default.conf \
    /usr/share/nginx/html/* \
    /var/cache/nginx/* \
    /var/log/nginx/*

# Copiar configuración Nginx optimizada
COPY docker/nginx/default.conf /etc/nginx/conf.d/default.conf

# Copiar build optimizado
COPY --from=builder /app/build/web /usr/share/nginx/html

# Optimizar assets estáticos
RUN find /usr/share/nginx/html -name "*.js" -exec gzip -k {} \; && \
    find /usr/share/nginx/html -name "*.css" -exec gzip -k {} \; && \
    find /usr/share/nginx/html -name "*.svg" -exec gzip -k {} \;

# Establecer permisos correctos
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html && \
    mkdir -p /var/cache/nginx /var/log/nginx && \
    chown -R nginx:nginx /var/cache/nginx /var/log/nginx

# Cambiar a usuario no-root
USER nginx

# Exponer puerto
EXPOSE 8080

# Health check optimizado
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Iniciar Nginx con configuración optimizada
CMD ["nginx", "-g", "daemon off;"]