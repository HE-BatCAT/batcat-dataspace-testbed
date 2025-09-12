#  Copyright (c) 2025 IndiScale GmbH <info@indiscale.com>
#
#  This program and the accompanying materials are made available under the
#  terms of the Apache License, Version 2.0 which is available at
#  https://www.apache.org/licenses/LICENSE-2.0
#
#  SPDX-License-Identifier: Apache-2.0
#
#  Contributors:
#       IndiScale GmbH - initial API and implementation
FROM eclipse-temurin:21.0.2_13-jre-alpine

ARG JVM_ARGS=""
ARG JAR

RUN apk --no-cache add curl envsubst

WORKDIR /app


COPY ${JAR} edc-connector.jar

ENV EDC_FS_CONFIG="/app/configuration.properties"
ENV LOG_LEVEL=debug
ENV EDC_VAULT_SECRETS=""

ENV ENV_JVM_ARGS=$JVM_ARGS
CMD ["sh", "-c", "envsubst < \"${EDC_FS_CONFIG}\" > /app/configuration.properties.real && exec java -Dedc.fs.config=/app/configuration.properties.real -Dedc.vault.secrets=\"${EDC_VAULT_SECRETS}\" -Djava.util.logging.config.file=/app/logging.properties -Djava.security.egd=file:/dev/urandom -jar edc-connector.jar --log-level=\"${LOG_LEVEL}\""]
