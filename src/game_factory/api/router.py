from fastapi import APIRouter

from game_factory.api.base_routes import router as base_router
from game_factory.api.queue_routes import router as queue_router
from game_factory.api.evolution_routes import router as evolution_router
from game_factory.api.studio_routes import router as studio_router
from game_factory.api.cluster_routes import router as cluster_router
from game_factory.api.metrics_route import router as metrics_router
from game_factory.control.control_api import router as control_router

router = APIRouter()

router.include_router(base_router)
router.include_router(queue_router)
router.include_router(evolution_router)
router.include_router(studio_router)
router.include_router(cluster_router)
router.include_router(metrics_router)
router.include_router(control_router)
