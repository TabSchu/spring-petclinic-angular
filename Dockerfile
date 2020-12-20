FROM node:14.15.1-alpine as build

WORKDIR /workspace/
ADD package.json /workspace/
RUN npm install

COPY . /workspace/
RUN $(npm bin)/ng build --prod


FROM nginx:1.19.5-alpine AS runtime

RUN apk update
RUN apk add --update nodejs npm

# Installs latest Chromium package
#RUN  echo @edge http://nl.alpinelinux.org/alpine/edge/community >> /etc/apk/repositories && \
#    echo @edge http://nl.alpinelinux.org/alpine/edge/main >> /etc/apk/repositories && \
#    apk add --no-cache bash chromium@edge nss@edge
# This line is to tell karma-chrome-launcher where
# chromium was downloaded and installed to.
#ENV CHROME_BIN /usr/bin/chromium-browser

COPY  --from=build /workspace/dist/ /usr/share/nginx/html/
#COPY --from=build /workspace/ /spring-petclinic-angular/


#RUN cd /spring-petclinic-angular/ && \
#       npm install

#
RUN chmod a+rwx /var/cache/nginx /var/run /var/log/nginx
#RUN sed -i.bak 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf
#RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf
#
#EXPOSE 8080
#USER nginx
#HEALTHCHECK CMD [ "service", "nginx", "status" ]
      #CMD ["npm", "start"]


COPY ./default.conf.template /etc/nginx/conf.d/default.conf.template
COPY ./nginx.conf /etc/nginx/nginx.conf
CMD /bin/ash -c "envsubst '\$PORT' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf" && nginx -g 'daemon off;'
