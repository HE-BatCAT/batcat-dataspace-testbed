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
from uuid import uuid4
from authlib.jose import jwt, jwk, KeySet
from authlib.jose.errors import BadSignatureError
from fastapi import HTTPException, status
from .settings import settings
from .models import GrantType

class TokenService:

    def __init__(self):
        self._private_key = jwk.JsonWebKey.generate_key(kty="RSA", crv_or_size=1024, is_private=True)
        self._public_key = self._private_key.get_public_key()
        self._key_set = KeySet([self._private_key])


    def create_token(self, grant_type: GrantType, sub: str | None = None, scope: str | None = None):
        header = {'alg': 'RS256'}
        payload = {'iss': settings.issuer, 'sub': sub}
        if sub is None:
            payload["sub"] = uuid4().hex
        if scope is not None:
            payload["scope"] = scope

        s = jwt.encode(header, payload, self._private_key)
        return {"grant_type": grant_type, "scope": scope, "access_token": s}

    def get_key_set(self):
        return self._key_set.as_dict(is_private=False)

    def validate_token(self, token):
        try:
            d = jwt.decode(token, key=self._key_set)
            return d.validate()
        except:
            raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Invalid token",
                    headers={"WWW-Authenticate": "Bearer"},
                )



TOKEN_SERVICE = TokenService()
def create_token(grant_type: GrantType, scope: str | None = None) -> str:
    return TOKEN_SERVICE.create_token(grant_type=grant_type, scope=scope)

def get_key_set() -> dict:
    return TOKEN_SERVICE.get_key_set()

def validate_token(token: str):
    return TOKEN_SERVICE.validate_token(token)
