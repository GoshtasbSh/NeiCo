from django.db import models
from django.conf import settings
from groceries.models import GroceryItem

class BasketItem(models.Model):
    user        = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    groceryitem = models.ForeignKey(GroceryItem, on_delete=models.CASCADE)
    quantity    = models.PositiveIntegerField(default=1)
    added_at    = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("user", "groceryitem")
        ordering = ["-added_at"]

    def __str__(self):
        return f"{self.user.username} – {self.groceryitem.name} (x{self.quantity})"