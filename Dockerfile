FROM ocaml/opam:alpine

LABEL org.opencontainers.image.source=https://github.com/slegrand45/shupdofi
LABEL org.opencontainers.image.description="Shupdofi"
LABEL org.opencontainers.image.licenses="AGPL-3.0"

COPY . .

RUN set -x && \
    sudo apk update && sudo apk upgrade && \
    sudo apk add gmp-dev && sudo apk add zlib-dev && \
    opam install . --deps-only && \
    eval $(opam env) && \
    dune build --profile release && \
    sudo cp ./_build/default/bin/srv/shupdofi.exe /usr/bin/shupdofi.exe && \
    sudo mkdir -p /var/www/shupdofi && \
    sudo cp -r ./www/* /var/www/shupdofi/ && \
    sudo adduser --disabled-password app && \
    sudo chown app:app /usr/bin/shupdofi.exe && \
    sudo chown -R app:app /var/www/shupdofi/ && \
    sudo rm -Rf /home/opam

WORKDIR /home/app
USER app
ENTRYPOINT ["/usr/bin/shupdofi.exe", "-c", "/etc/shupdofi-config.toml"]
