"""
Security package for KhedmaLink backend
Contains security utilities and authentication helpers
"""

from .security import (
    verify_password,
    get_password_hash,
    create_access_token,
    decode_access_token,
    verify_token,
    create_refresh_token,
    verify_refresh_token,
)
from .dependencies import (
    get_current_user,
    get_current_active_user,
    get_current_verified_user,
    require_role,
    require_any_role,
    require_customer,
    require_provider,
    require_admin,
    require_super_admin,
    require_provider_or_admin,
    require_admin_or_super_admin,
)
from .ownership import check_ownership, require_ownership, check_ownership_or_admin

__all__ = [
    "verify_password",
    "get_password_hash",
    "create_access_token",
    "decode_access_token",
    "verify_token",
    "create_refresh_token",
    "verify_refresh_token",
    "get_current_user",
    "get_current_active_user",
    "get_current_verified_user",
    "require_role",
    "require_any_role",
    "require_customer",
    "require_provider",
    "require_admin",
    "require_super_admin",
    "require_provider_or_admin",
    "require_admin_or_super_admin",
    "check_ownership",
    "require_ownership",
    "check_ownership_or_admin",
]
