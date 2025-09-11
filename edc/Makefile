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

image: jar
	./gradlew connector:dockerize

jar: connector/build/libs/connector.jar

connector/build/libs/connector.jar:
	./gradlew connector:build

clean:
	rm build -r || true
	rm connector/build -r || true
