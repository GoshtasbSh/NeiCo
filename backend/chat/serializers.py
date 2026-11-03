from rest_framework import serializers
from .models import Chat, Participant, Message

class ParticipantSerializer(serializers.ModelSerializer):
    class Meta:
        model = Participant
        fields = "__all__"
        read_only_fields = ("joined_at",)

class MessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = Message
        fields = "__all__"
        read_only_fields = ("sent_at",)

class ChatSerializer(serializers.ModelSerializer):
    participants = ParticipantSerializer(many=True, read_only=True)
    messages     = MessageSerializer(many=True, read_only=True)

    class Meta:
        model = Chat
        fields = ("id", "name", "created_at", "participants", "messages")
        read_only_fields = ("created_at",)