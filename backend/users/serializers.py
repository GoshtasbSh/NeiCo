# users/serializers.py

from rest_framework import serializers
from django.conf import settings

from .models import User

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = settings.AUTH_USER_MODEL  # or just User
        model = User
        fields = [
            "id",
            "username",
            "email",
            "first_name",
            "last_name",
            "credit",
            "avatar",
        ]
        read_only_fields = ["id", "credit"]