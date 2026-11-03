from django.contrib import admin
from .models import Chat, Message, Participant

@admin.register(Chat)
class ChatAdmin(admin.ModelAdmin):
    list_display = ("id", "name", "created_at")
    search_fields = ("name",)

@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ("id", "chat", "sender", "sent_at")
    list_filter = ("chat",)
    search_fields = ("sender__username", "text")

@admin.register(Participant)
class ParticipantAdmin(admin.ModelAdmin):
    list_display = ("id", "chat", "user", "joined_at")
    list_filter = ("chat", "user")