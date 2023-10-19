FROM node:lts-alpine3.17
WORKDIR /lza
COPY landing-zone-accelerator-on-aws .
COPY lza-validator.sh ./lza-validator.sh

RUN mkdir config
RUN apk add git
RUN cd source \
    && export NODE_OPTIONS=--max_old_space_size=8192 \
    && yarn install \
    && yarn build \
    && yarn cache clean

ENTRYPOINT ["/lza/lza-validator.sh"]
CMD ["/lza/config/"]
