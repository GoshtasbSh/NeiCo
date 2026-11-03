from rest_framework import serializers
from .models import Order, OrderItem, Reward

class OrderItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderItem
        fields = ("id", "order", "name", "quantity", "price")

class RewardSerializer(serializers.ModelSerializer):
    class Meta:
        model = Reward
        fields = ("id", "user", "order", "points", "awarded_at")

class OrderSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True)

    class Meta:
        model = Order
        fields = ("id", "owner", "store", "status", "created_at", "items")
        read_only_fields = ("created_at", "owner")

    def create(self, validated_data):
        items_data = validated_data.pop('items')
        order = Order.objects.create(owner=self.context['request'].user, **validated_data)
        for item in items_data:
            OrderItem.objects.create(order=order, **item)
        return order