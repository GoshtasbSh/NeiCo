from django.db import models
from django.contrib.auth import get_user_model
from stores.models import Store

User = get_user_model()

class SurplusItem(models.Model):
    owner           = models.ForeignKey(User, on_delete=models.CASCADE, related_name="surplus_items")
    store           = models.ForeignKey(Store, on_delete=models.CASCADE, related_name="surplus_items")
    name            = models.CharField(max_length=200)
    image_url       = models.URLField(blank=True, null=True)
    quantity        = models.IntegerField()
    unit            = models.CharField(max_length=50, default="Each")
    price           = models.DecimalField(max_digits=10, decimal_places=2, default=0)
    expiration_date = models.DateField(blank=True, null=True)
    description     = models.TextField(blank=True)
    notes           = models.TextField(blank=True)
    created_at      = models.DateTimeField(auto_now_add=True)
    updated_at      = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.name} ({self.quantity} {self.unit})"

class Claim(models.Model):
    claimant   = models.ForeignKey(User, on_delete=models.CASCADE, related_name="claims")
    item       = models.ForeignKey(SurplusItem, on_delete=models.CASCADE, related_name="claims")
    quantity   = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("claimant", "item")

    def __str__(self):
        return f"{self.claimant.username} → {self.item.name} x{self.quantity}"