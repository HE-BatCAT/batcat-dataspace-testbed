import os
import logging
from fastapi import FastAPI
from .settings import settings

logging.basicConfig(level=settings.log_level)

from .files import router as fileupload


app = FastAPI()
app.include_router(fileupload)
