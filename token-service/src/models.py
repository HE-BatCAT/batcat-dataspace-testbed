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
from pydantic import BaseModel, Field, RootModel
from pydantic.json_schema import SkipJsonSchema
from enum import Enum

class GrantType(str, Enum):
    client_credentials = "client_credentials"

class ClientCredentialsGrantRequest(BaseModel):
    grant_type: GrantType = Field()
    scope: str | SkipJsonSchema[None] = None
    sub: str | None = None

    model_config = {
        "extra": "forbid",
        "json_schema_extra": {
            "examples": [
                {
                    "grant_type": GrantType.client_credentials,
                    "scope": "provider_push_http"
                }
            ]
        }
    }

class ClientCredentialsGrantResponse(BaseModel):
    access_token: str = Field(default=None)
    token_type: str = Field(default="bearer")
    expires_in: int = Field(default=360)
    grant_type: GrantType = Field(default=GrantType.client_credentials)
    scope: str | SkipJsonSchema[None] = None
