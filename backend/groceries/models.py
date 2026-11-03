from django.db import models
from django.conf import settings
from stores.models import Store
from django.contrib.auth import get_user_model

class GroceryItem(models.Model):
    """
    An item in a user's grocery basket.
    """
    user = models.ForeignKey(get_user_model(), on_delete=models.CASCADE)
    store = models.ForeignKey(Store, on_delete=models.CASCADE, related_name='items')
    name = models.CharField(max_length=200)
    image = models.CharField(max_length=200, blank=True, null=True)  # or use ImageField
    price = models.DecimalField(max_digits=6, decimal_places=2, default=0.0)
    quantity = models.FloatField()
    unit = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.name} ({self.store.name})"