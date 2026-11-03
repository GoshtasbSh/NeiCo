from rest_framework.routers import DefaultRouter
from .views import GroceryItemViewSet
from django.urls import path

router = DefaultRouter()
router.register(r'grocery-list', GroceryItemViewSet, basename='grocery-list')

urlpatterns = router.urls
