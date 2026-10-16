from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env")

    database_url: str
    frontend_origin: str = "http://localhost:5173"
    session_minutes: int = 30
    cookie_secure: bool = False


settings = Settings()