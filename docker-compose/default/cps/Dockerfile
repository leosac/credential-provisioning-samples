FROM leosac/leosac-credential-provisioning-server:latest

COPY openssl.cnf /etc/ssl/

COPY /data/certificates/ca/* /usr/local/share/ca-certificates/
RUN update-ca-certificates