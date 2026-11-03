from rest_framework import serializers
from .models import SurplusItem, Claim

class SurplusItemSerializer(serializers.ModelSerializer):
    owner = serializers.ReadOnlyField(source="owner.username")
    store = serializers.ReadOnlyField(source="store.name")

    class Meta:
        model = SurplusItem
        fields = [
            "id", "owner", "store", "name", "image_url",
            "quantity", "unit", "price",
            "expiration_date", "description", "notes",
            "created_at", "updated_at",
        ]

class ClaimSerializer(serializers.ModelSerializer):
    claimant = serializers.ReadOnlyField(source="claimant.username")
    item_name = serializers.ReadOnlyField(source="item.name")

    class Meta:
        model = Claim
        fields = ["id", "claimant", "item", "item_name", "quantity", "created_at"]