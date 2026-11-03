from rest_framework import serializers
from .models import Store
from .models import StoreItem

class StoreSerializer(serializers.ModelSerializer):
    class Meta:
        model = Store
        fields = '__all__'

class StoreItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = StoreItem
        fields = ['id', 'store', 'name', 'image', 'price', 'unit']