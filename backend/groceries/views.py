from rest_framework import viewsets, permissions
from rest_framework.permissions import IsAuthenticatedOrReadOnly
from .models import GroceryItem
from .serializers import GroceryItemSerializer
from rest_framework.permissions import AllowAny
from rest_framework.generics import ListAPIView

class GroceryItemViewSet(viewsets.ModelViewSet):
    """
    list/create/retrieve/update/delete grocery items.
    """
    queryset = GroceryItem.objects.all()
    serializer_class = GroceryItemSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # Only return items for the current user
        return GroceryItem.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class GroceryListView(ListAPIView):
    serializer_class = GroceryItemSerializer

    def get_queryset(self):
        return GroceryItem.objects.filter(user=self.request.user)