FROM node:22-alpine

ARG LZA_SOURCE_DIR=landing-zone-accelerator-on-aws
ARG release

WORKDIR /lza
COPY ${LZA_SOURCE_DIR} .
COPY lza-validator.sh ./lza-validator.sh

WORKDIR /lza/source
RUN mkdir config \
    && export NODE_OPTIONS="--max_old_space_size=8192" \
    && yarn install \
    && if [ "$(echo -e "$release\nv1.5.0" | tr -d '[:alpha:]' | sort -V | head -1)" != "1.5.0" ]; then yarn lerna link; fi \
    && yarn build \
    && yarn cache clean
WORKDIR /lza

ENTRYPOINT ["/lza/lza-validator.sh"]
CMD ["/lza/config/"]
