from django.urls import path
from .views import StoreListView, StoreItemViewSet
from django.conf import settings
from django.conf.urls.static import static
import os
from rest_framework.routers import DefaultRouter

router = DefaultRouter()
router.register(r'store-items', StoreItemViewSet, basename='storeitem')

urlpatterns = [
    path('stores/', StoreListView.as_view(), name='store-list'),
] + static(settings.STATIC_URL, document_root=os.path.join(settings.BASE_DIR, '../SotreLogos')) + router.urls
