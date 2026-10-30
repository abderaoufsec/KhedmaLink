"""Base schema with UUID and datetime coercion for PostgreSQL compatibility."""

from datetime import datetime  # noqa: E402
from uuid import UUID  # noqa: E402
from pydantic import BaseModel, ConfigDict, model_validator  # noqa: E402


class BaseResponseSchema(BaseModel):
    """Base response schema that coerces UUID and datetime to str."""

    model_config = ConfigDict(from_attributes=True)

    @model_validator(mode="before")
    @classmethod
    def _coerce_types(cls, data):
        if isinstance(data, dict):
            return {
                k: str(v) if isinstance(v, (UUID, datetime)) else v
                for k, v in data.items()
            }
        # Handle ORM objects
        if hasattr(data, "__dict__"):
            result = {}
            for k, v in data.__dict__.items():
                if not k.startswith("_"):
                    result[k] = str(v) if isinstance(v, (UUID, datetime)) else v
            return result
        return data
