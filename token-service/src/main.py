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
from typing import Annotated

from fastapi import FastAPI, Form, Depends, HTTPException, status, Response
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
from fastapi.security import HTTPBasic, HTTPBasicCredentials, HTTPAuthorizationCredentials, HTTPBearer

from .models import ClientCredentialsGrantResponse, ClientCredentialsGrantRequest
from .clients import authenticate as authenticate_client
from .token_service import create_token, get_key_set, validate_token
from .settings import settings

app = FastAPI()


BASIC_AUTH = HTTPBasic()
BEARER_AUTH = HTTPBearer()

@app.get(settings.path_keys)
async def get_jwk_keys():
    keys = get_key_set()
    content = jsonable_encoder(keys)
    return JSONResponse(status_code=status.HTTP_200_OK,
                        content=content)

@app.get(settings.path_token, status_code=status.HTTP_204_NO_CONTENT)
async def validate(credentials: Annotated[HTTPAuthorizationCredentials, Depends(BEARER_AUTH)]) -> None:
    validate_token(credentials.credentials)

@app.post(settings.path_token, response_model=ClientCredentialsGrantResponse,
          response_model_exclude_none=True)
async def obtain_token(data: Annotated[ClientCredentialsGrantRequest, Form()],
                       authorization: Annotated[HTTPBasicCredentials, Depends(BASIC_AUTH)]) -> ClientCredentialsGrantResponse:

    client_id = authenticate_client(**authorization.dict())
    if client_id:
        return create_token(**{"grant_type": data.grant_type, "scope": data.scope})
    return None
