import asyncio
from app.core.database import engine
from sqlalchemy import text

async def check_db():
    async with engine.begin() as conn:
        # Check if roles table exists
        result = await conn.execute(text("SELECT name FROM sqlite_master WHERE type='table' AND name='roles'"))
        print('Roles table exists:', result.fetchone())
        
        # Check if users table exists
        result = await conn.execute(text("SELECT name FROM sqlite_master WHERE type='table' AND name='users'"))
        print('Users table exists:', result.fetchone())
        
        # Check if user_roles table exists
        result = await conn.execute(text("SELECT name FROM sqlite_master WHERE type='table' AND name='user_roles'"))
        print('User_roles table exists:', result.fetchone())
        
        # Check all tables
        result = await conn.execute(text("SELECT name FROM sqlite_master WHERE type='table'"))
        print('All tables:', [row[0] for row in result.fetchall()])

if __name__ == "__main__":
    asyncio.run(check_db())
