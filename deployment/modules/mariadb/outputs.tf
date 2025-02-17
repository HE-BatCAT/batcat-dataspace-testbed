#
#  Copyright (c) 2024 Metaform Systems, Inc.
#
#  This program and the accompanying materials are made available under the
#  terms of the Apache License, Version 2.0 which is available at
#  https://www.apache.org/licenses/LICENSE-2.0
#
#  SPDX-License-Identifier: Apache-2.0
#
#  Contributors:
#       Metaform Systems, Inc. - initial API and implementation
#

output "database-port" {
  value = var.database-port
}

output "database-url" {
  value = local.db-url
}

output "database-host" {
  value = local.db-host
}

output "database-ip" {
  value = local.db-ip
}
