from typing import Callable
from fastapi import APIRouter, Request, Response
from fastapi.routing import APIRoute

class RawRequestRoute(APIRoute):
    """RawRequestRoute

    APIRouter for the RawRouter
    """
    def get_route_handler(self) -> Callable:
        async def route_handler(request: Request) -> Response:
            return await self.dependant.call(request)
        return route_handler

class RawRouter(APIRouter):
    """RawRouter

    This router will just pass the original Request object to the endpoint function and expect a plain
    Response object in return.
    """

    def __init__(self):
        super().__init__(route_class=RawRequestRoute)
