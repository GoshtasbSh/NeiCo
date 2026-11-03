from django.db import models
from django.conf import settings

class Chat(models.Model):
    name       = models.CharField(max_length=200, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

class Participant(models.Model):
    chat    = models.ForeignKey(Chat, related_name='participants', on_delete=models.CASCADE)
    user    = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    joined_at = models.DateTimeField(auto_now_add=True)

class Message(models.Model):
    chat      = models.ForeignKey(Chat, related_name='messages', on_delete=models.CASCADE)
    sender    = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    text      = models.TextField()
    sent_at   = models.DateTimeField(auto_now_add=True)