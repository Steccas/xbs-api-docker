FROM node:fermium-alpine

# Set environment variables
#ENV XBROWSERSYNC_API_VERSION 1.1.13

WORKDIR /usr/src/api

# Install dependencies
RUN apk update && apk add grep curl python3 make

# Download release and unpack
RUN XBROWSERSYNC_API_VERSION="$(curl --silent "https://api.github.com/repos/xbrowsersync/api/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')" \ 
	&& echo $XBROWSERSYNC_API_VERSION \
	&& wget -q -O release.tar.gz https://github.com/xBrowserSync/api/archive/$XBROWSERSYNC_API_VERSION.tar.gz \
	&& tar -C . -xzf release.tar.gz \
	&& rm release.tar.gz \
	&& XBROWSERSYNC_API_VERSION="${XBROWSERSYNC_API_VERSION:1}" \
	&& mv api-$XBROWSERSYNC_API_VERSION/* . \
	&& rm -rf api-$XBROWSERSYNC_API_VERSION/

# Copy necessary files
COPY healthcheck.js /usr/src/api/
COPY settings.json /usr/src/api/config/

# Install npm
RUN npm install --only=production

# Expose port and start api
EXPOSE 8080
CMD [ "node", "dist/api.js"]