from rest_framework import serializers
from .models import GroceryItem

class GroceryItemSerializer(serializers.ModelSerializer):
    # No need for custom id or price fields unless you need special formatting

    class Meta:
        model = GroceryItem
        fields = '__all__'
        read_only_fields = ['user']

    