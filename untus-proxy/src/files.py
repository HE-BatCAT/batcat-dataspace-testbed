import os
from typing import Annotated
from fastapi import File, HTTPException, Response
from http.client import HTTPConnection
import logging
from .settings import settings
from .raw_router import RawRouter

TUS_HOST=settings.tus_host
TUS_PORT=settings.tus_port
TUS_BASE_PATH=settings.tus_base_path

logger = logging.getLogger(__name__)
router = RawRouter()
logger.info(f"Proxy to tus: {TUS_HOST}:{TUS_PORT}")

def _handle_response(response):
    response.read() # empty the stream for next request.
    if response.status >= 400:
        raise HTTPException(status_code=502, detail=f"tusd responded {response.status}: {response.reason}")

@router.post("/files/{upload_id}", response_model=Annotated[bytes, File(content_type="*/*")])
async def proxy_to_tus(request):
    """proxy_to_tus

    This endpoint will read the HTTP Request body and forward the stream to the tus server using the tus
    upload protocol.

    This is for clients who do not support the tus protocol.
    """
    logger.info(f"Proxy to tus: {TUS_HOST}:{TUS_PORT}/{request.url.path}")
    upstream = HTTPConnection(TUS_HOST, TUS_PORT)
    offset = 0

    async for chunk in request.stream():
        upstream.request("PATCH", request.url.path, body=chunk, headers={
                "Tus-Resumable": "1.0.0",
                "Content-Type": "application/offset+octet-stream",
                "Upload-Offset": offset
            })
        _handle_response(upstream.getresponse())
        offset += len(chunk)

    upstream.request("PATCH", request.url.path, body="", headers={
            "Tus-Resumable": "1.0.0",
            "Content-Type": "application/offset+octet-stream",
            "Upload-Offset": offset,
            "Upload-Length": offset
        })
    _handle_response(upstream.getresponse())
    return Response(status_code=202)
