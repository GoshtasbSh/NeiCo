import uuid
from django.db import models

class Store(models.Model):
    id = models.UUIDField(primary_key=True,
                          default=uuid.uuid4,
                          editable=False)
    name = models.CharField(max_length=200)
    icon = models.CharField(max_length=200, blank=True, null=True)  # store the filename, e.g., "walmart.png"

    def __str__(self):
        return self.name

class StoreItem(models.Model):
    store = models.ForeignKey(Store, on_delete=models.CASCADE, related_name='store_items')
    name = models.CharField(max_length=200)
    image = models.CharField(max_length=200, blank=True, null=True)
    price = models.DecimalField(max_digits=6, decimal_places=2, default=0.0)
    unit = models.CharField(max_length=50)
    # Add any other fields you need

    def __str__(self):
        return f"{self.name} ({self.store.name})"