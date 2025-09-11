from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    tus_port: int = 4000
    tus_host: str = "localhost"
    tus_base_path: str = "/files"
    log_level: str = "INFO"

settings = Settings()
