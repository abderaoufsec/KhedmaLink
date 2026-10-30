"""Custom UUID type that handles string conversion for PostgreSQL."""

import uuid  # noqa: E402
from sqlalchemy import TypeDecorator  # noqa: E402
from sqlalchemy.dialects.postgresql import UUID as PGUUID  # noqa: E402


class FlexibleUUID(TypeDecorator):
    """UUID type that accepts both str and UUID objects."""

    impl = PGUUID
    cache_ok = True

    def process_bind_param(self, value, dialect):
        if value is None:
            return None
        if isinstance(value, str):
            return uuid.UUID(value)
        return value

    def process_result_value(self, value, dialect):
        if value is None:
            return None
        return str(value)
