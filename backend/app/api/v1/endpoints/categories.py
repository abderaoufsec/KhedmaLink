"""
Category API endpoints
Handles CRUD operations for service categories
"""

from typing import List
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.models.provider import Category
from app.core.schemas.provider import CategoryCreate, CategoryUpdate, CategoryResponse
from app.core.security.dependencies import require_admin

# Create router for category endpoints
router = APIRouter()


# =============================================================================
# PUBLIC ENDPOINTS
# =============================================================================


@router.get("", response_model=List[CategoryResponse], status_code=status.HTTP_200_OK)
async def list_categories(
    skip: int = 0,
    limit: int = 100,
    active_only: bool = True,
    db: AsyncSession = Depends(get_db),
):
    """
    List all categories

    - **skip**: Number of categories to skip (pagination)
    - **limit**: Maximum number of categories to return
    - **active_only**: If True, only return active categories

    Returns a list of categories sorted by sort_order
    """
    # Build query with filters
    query = select(Category)

    if active_only:
        query = query.where(Category.is_active == True)

    # Apply sorting and pagination
    query = query.order_by(Category.sort_order).offset(skip).limit(limit)

    # Execute query
    result = await db.execute(query)
    categories = result.scalars().all()

    return categories


@router.get(
    "/{category_id}", response_model=CategoryResponse, status_code=status.HTTP_200_OK
)
async def get_category(
    category_id: str,
    db: AsyncSession = Depends(get_db),
):
    """
    Get a specific category by ID

    - **category_id**: UUID of the category

    Returns category details or 404 if not found
    """
    # Query for category
    query = select(Category).where(Category.id == category_id)
    result = await db.execute(query)
    category = result.scalar_one_or_none()

    # Check if category exists
    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Category not found"
        )

    return category


# =============================================================================
# ADMIN ENDPOINTS
# =============================================================================


@router.post("", response_model=CategoryResponse, status_code=status.HTTP_201_CREATED)
async def create_category(
    category_data: CategoryCreate,
    db: AsyncSession = Depends(get_db),
    current_admin=Depends(require_admin),
):
    """
    Create a new category (Admin only)

    - **category_data**: Category creation data

    Creates a new service category and returns the created category
    """
    # Create new category instance
    new_category = Category(**category_data.model_dump())

    # Add to database
    db.add(new_category)
    await db.commit()
    await db.refresh(new_category)

    return new_category


@router.put(
    "/{category_id}", response_model=CategoryResponse, status_code=status.HTTP_200_OK
)
async def update_category(
    category_id: str,
    category_data: CategoryUpdate,
    db: AsyncSession = Depends(get_db),
    current_admin=Depends(require_admin),
):
    """
    Update a category (Admin only)

    - **category_id**: UUID of the category to update
    - **category_data**: Category update data

    Updates the category and returns the updated category
    """
    # Query for existing category
    query = select(Category).where(Category.id == category_id)
    result = await db.execute(query)
    category = result.scalar_one_or_none()

    # Check if category exists
    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Category not found"
        )

    # Update category fields
    update_data = category_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(category, field, value)

    # Commit changes
    await db.commit()
    await db.refresh(category)

    return category


@router.delete("/{category_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_category(
    category_id: str,
    db: AsyncSession = Depends(get_db),
    current_admin=Depends(require_admin),
):
    """
    Delete a category (Admin only)

    - **category_id**: UUID of the category to delete

    Deletes the category permanently
    """
    # Query for existing category
    query = select(Category).where(Category.id == category_id)
    result = await db.execute(query)
    category = result.scalar_one_or_none()

    # Check if category exists
    if not category:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Category not found"
        )

    # Delete category
    await db.delete(category)
    await db.commit()

    return None
