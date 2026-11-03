from rest_framework import serializers
from .models import BasketItem
from groceries.models import GroceryItem

# 1a) Serializer for GroceryItem — matches your Swift `Item` struct
class GroceryItemSerializer(serializers.ModelSerializer):
    storeId    = serializers.UUIDField(source='store.id')
    imageName  = serializers.CharField(source='image_name')
    price      = serializers.DecimalField(source='price', max_digits=10, decimal_places=2)

    class Meta:
        model = GroceryItem
        fields = ['id', 'storeId', 'name', 'imageName', 'price']


# 1b) Serializer for BasketItem — nesting the GroceryItem data + quantity
class BasketItemSerializer(serializers.ModelSerializer):
    item     = GroceryItemSerializer(source='groceryitem', read_only=True)
    quantity = serializers.IntegerField()

    class Meta:
        model = BasketItem
        # id here will be the BasketItem PK (you can omit it if you prefer using groceryitem.id)
        fields = ['id', 'item', 'quantity']