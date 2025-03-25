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

variable "namespace" {
  description = "kubernetes namespace where the LinkAhead instance is deployed"
}

variable "linkahead-port" {
  description = "Linkahead http port"
  default = 10080
}

variable "linkahead-image" {
  description = "The docker image tag of the linkahead build you want to be loaded."
  default = "indiscale/linkahead:0.16.1"
}

variable "mariadb-host" {
  description = "The host of the MariaDB database."
}

variable "mariadb-port" {
  description = "The port of the MariaDB database."
}
