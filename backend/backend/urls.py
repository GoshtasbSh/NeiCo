"""
URL configuration for backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from rest_framework import routers
from django.views.generic import RedirectView
# import your ViewSets (we'll create these next)
from users.views import UserViewSet
from groceries.views import GroceryItemViewSet
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)
from stores.views import StoreViewSet
from home.views import BasketItemViewSet
from orders.views import OrderViewSet, OrderItemViewSet, RewardViewSet
from marketplace.views import SurplusItemViewSet, ClaimViewSet
from chat.views import ChatViewSet, ParticipantViewSet, MessageViewSet
from rest_framework.authtoken.views import obtain_auth_token

router = routers.DefaultRouter()
router.register(r'users',         UserViewSet)
router.register(r'stores',        StoreViewSet)
router.register(r'grocery-items', GroceryItemViewSet, basename='groceryitem')
router.register(r'basket-items', BasketItemViewSet, basename='basketitem')
router.register(r'orders',        OrderViewSet)
router.register(r'order-items',   OrderItemViewSet)
router.register(r'rewards',       RewardViewSet)
router.register(r'surplus-items', SurplusItemViewSet)
router.register(r'claims',        ClaimViewSet)
router.register(r'chats',         ChatViewSet)
router.register(r'messages',      MessageViewSet)

urlpatterns = [
    path('', RedirectView.as_view(url='/api/', permanent=False)),
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
    
    # JWT token endpoints (optional now, but handy later):
    
    # JWT token endpoints
    path('api/token/',  TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('api/token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('api/', include('stores.urls')),
    path('api-token-auth/', obtain_auth_token),
]



