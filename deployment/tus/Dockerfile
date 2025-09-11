#  Copyright (c) 2025 IndiScale GmbH <info@indiscale.com>
#
#       This program is free software: you can redistribute it and/or modify
#       it under the terms of the GNU Affero General Public License as
#       published by the Free Software Foundation, either version 3 of the
#       License, or (at your option) any later version.
#
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU Affero General Public License for more details.
#
#       You should have received a copy of the GNU Affero General Public License
#       along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#  Contributors:
#       IndiScale GmbH - initial API and implementation
ARG TUSD_VERSION=v2.8.0
FROM tusproject/tusd:${TUSD_VERSION}

ENV TUSD_DATA_DIR=/srv/tusd-data
## remove files after 12h
ENV TUSD_DATA_EXPIRE_MINUTES=720

USER root
## run every 15min
COPY --chmod=0700 cleanup/cleanup.sh /etc/periodic/15min/
RUN crond -b

USER tusd
