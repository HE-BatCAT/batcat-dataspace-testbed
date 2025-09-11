import json
from json.decoder import JSONDecodeError
from typing import Dict
from pydantic import BaseModel, Field, RootModel
from fastapi import HTTPException, status

import logging
logger = logging.getLogger(__name__)

from .settings import settings

class Client(BaseModel):
    client_id: str
    client_secret: str

class ClientDatabase:

    clients: Dict[str, Client] = None

    def _parse_clients_json(self, filename: str | None):
        if filename is None:
            return dict()
        logger.info(f"read clients data from {filename}.")
        try:
            clients_list_model = RootModel[list[Client]]
            with open(filename) as data_file:
                data_json = json.load(data_file)
            if data_json:
                clients_list = clients_list_model.model_validate(data_json)
                return { c.client_id: c for c in clients_list.root }
        except JSONDecodeError as e:
            logger.warn(f"JSONDecodeError: Could not decode {filename} as clients database. "
                        "Database will be empty.")
        except OSError as e:
            logger.warn(f"OSError: Could not read {filename} as clients database. "
                        "Database will be empty.")
        return dict()

    def __init__(self, filename: str | None = settings.registered_clients_json_file):
        self.clients = self._parse_clients_json(filename)
        if not self.clients:
            logger.warn(f"Clients database is empty and no client can generate tokens.")
        else:
            logger.info(f"Clients database contains {len(self.clients)} client(s).")


    def authenticate(self, username: str, password: str) -> str:
        if username in self.clients:
            client_credentials = self.clients[username]
            if client_credentials.client_secret == password:
                return client_credentials.client_id
        raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect username or password",
                headers={"WWW-Authenticate": "Basic"},
            )

CLIENT_DATABASE = ClientDatabase()

def authenticate(username: str, password: str) -> str:
    return CLIENT_DATABASE.authenticate(username, password)
