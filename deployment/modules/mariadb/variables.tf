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

variable "database-port" {
  default = 3306
}

variable "init-sql-configs" {
  description = "Name of config maps with init sql scripts"
  default     = []
}

variable "namespace" {
  description = "kubernetes namespace where the Mariadb instance is deployed"
}
