#!/bin/sh
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


DATE="$(date -Iminutes)"
TUSD_DATA_DIR=${TUSD_DATA_DIR:-/srv/tusd-data}
TUSD_DATA_EXPIRE_MINUTES=${TUSD_DATA_EXPIRE_MINUTES:-1}

echo "${DATE} - Clean up tusd datadir: ${TUSD_DATA_DIR}. Remove files older than ${TUSD_DATA_EXPIRE_MINUTES} minutes." | tee -i -a /var/log/tusd-cleanup.log | tee -i /var/log/tusd-cleanup.latest.log
find ${TUSD_DATA_DIR} -type f -mmin +${TUSD_DATA_EXPIRE_MINUTES} -print0 | xargs -n 200 -r -0 rm || true
