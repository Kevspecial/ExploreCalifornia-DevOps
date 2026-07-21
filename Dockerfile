FROM nginx:1.27-alpine

LABEL maintainer="Kelvin Nwokike <knwokike@gmail.com>"
LABEL version="2.0"
LABEL description="Explore California static site served by nginx"

# Serve the site and use our hardened nginx config
COPY website /website
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

# Fail the container health check if nginx stops serving the homepage
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/index.htm || exit 1
