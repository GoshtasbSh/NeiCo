from rest_framework import viewsets, permissions
from .models import BasketItem
from .serializers import BasketItemSerializer

class BasketItemViewSet(viewsets.ModelViewSet):
    """
    list   -> GET  /api/basket-items/        (all items in current user's basket)
    create -> POST /api/basket-items/        (add new item or update quantity)
    retrieve/update/destroy -> /api/basket-items/{pk}/
    """
    serializer_class = BasketItemSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # only this user's basket
        return BasketItem.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        # on POST, tie the new BasketItem to request.user
        serializer.save(user=self.request.user)