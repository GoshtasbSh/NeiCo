from rest_framework import viewsets, permissions
from .models import Store, StoreItem
from .serializers import StoreSerializer, StoreItemSerializer
from rest_framework import generics

class StoreViewSet(viewsets.ModelViewSet):
    queryset = Store.objects.all()
    serializer_class = StoreSerializer

class StoreListView(generics.ListAPIView):
    queryset = Store.objects.all()
    serializer_class = StoreSerializer

class StoreItemViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = StoreItem.objects.all()
    serializer_class = StoreItemSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        queryset = super().get_queryset()
        store_id = self.request.query_params.get('store')
        if store_id:
            queryset = queryset.filter(store__id=store_id)
        return queryset