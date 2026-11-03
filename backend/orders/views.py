from django.db.models import Q
from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response

from .models import Order, OrderItem, Reward
from .serializers import OrderSerializer, OrderItemSerializer, RewardSerializer

class OrderViewSet(viewsets.ModelViewSet):
    queryset         = Order.objects.all()
    serializer_class = OrderSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # return both your own orders and everyone else's pending orders
        return self.queryset.filter(
            Q(owner=self.request.user) | Q(status='PENDING')
        )

    @action(detail=True, methods=["post"])
    def accept(self, request, pk=None):
        order = self.get_object()

        # mark accepted
        order.status = "ACCEPTED"
        order.save()

        # award points (e.g. 10 per item)
        points = sum(item.quantity for item in order.items.all()) * 10
        Reward.objects.create(
            user=request.user,
            order=order,
            points=points
        )

        return Response({
            "status": "accepted",
            "points_awarded": points
        })

class OrderItemViewSet(viewsets.ReadOnlyModelViewSet):
    queryset         = OrderItem.objects.all()
    serializer_class = OrderItemSerializer
    permission_classes = [permissions.IsAuthenticated]

class RewardViewSet(viewsets.ReadOnlyModelViewSet):
    queryset         = Reward.objects.all()
    serializer_class = RewardSerializer
    permission_classes = [permissions.IsAuthenticated]