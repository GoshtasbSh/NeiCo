from django.contrib.auth.models import AbstractUser
from django.db import models

class User(AbstractUser):
    """
    Extended user: adds credit and avatar URL.
    """
    credit = models.IntegerField(default=0)
    avatar = models.URLField(blank=True, null=True)

    def __str__(self):
        return self.username