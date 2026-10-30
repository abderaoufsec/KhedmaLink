"""Custom types for PostgreSQL compatibility."""

from datetime import datetime  # noqa: E402

from pydantic import BeforeValidator  # noqa: E402
from typing import Annotated  # noqa: E402


def _str_uuid(v):
    if v is None:
        return v
    return str(v)


def _str_datetime(v):
    if v is None:
        return v
    if isinstance(v, datetime):
        return v.isoformat()
    return str(v)


StrUUID = Annotated[str, BeforeValidator(_str_uuid)]
StrDatetime = Annotated[str, BeforeValidator(_str_datetime)]
