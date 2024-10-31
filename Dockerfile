FROM node:18-bullseye
WORKDIR /lza
COPY landing-zone-accelerator-on-aws .
COPY lza-validator.sh ./lza-validator.sh

RUN mkdir config
RUN VERSION=$(echo $release | tr -cd [0-9])
RUN cd source \
    && export NODE_OPTIONS=--max_old_space_size=8192 \
    && yarn install \
    && if [ "$VERSION" -lt 150 ]; then yarn lerna link; fi \
    && yarn build \
    && yarn cache clean

ENTRYPOINT ["/lza/lza-validator.sh"]
CMD ["/lza/config/"]
