from fastapi import APIRouter

from game_factory.api.factory_routes import router as factory_router
from game_factory.api.routes import router as base_router

router = APIRouter()

router.include_router(base_router)
router.include_router(factory_router)
