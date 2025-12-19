### Build
FROM quay.io/keycloak/keycloak:latest as builder
WORKDIR /opt/keycloak

ENV KC_DB=postgres
RUN /opt/keycloak/bin/kc.sh build --http-relative-path=/auth --http-management-relative-path=/auth --health-enabled=true

### Run
FROM quay.io/keycloak/keycloak:latest
COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENV KC_DB=postgres
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
