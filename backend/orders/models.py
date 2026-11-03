import uuid
from django.db import models
from django.conf import settings
from stores.models import Store

ORDER_STATUS = [
    ('DRAFT',    'Draft'),
    ('PENDING',  'Pending'),
    ('ACCEPTED', 'Accepted'),
    ('IGNORED',  'Ignored'),
]

class Order(models.Model):
    id         = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    owner      = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    store      = models.ForeignKey(Store, on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)
    status     = models.CharField(max_length=10, choices=ORDER_STATUS, default='PENDING')

class OrderItem(models.Model):
    order    = models.ForeignKey(Order, related_name='items', on_delete=models.CASCADE)
    name     = models.CharField(max_length=200)
    quantity = models.PositiveIntegerField()
    price    = models.DecimalField(max_digits=8, decimal_places=2)

class Reward(models.Model):
    user       = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    order      = models.ForeignKey(Order, on_delete=models.CASCADE)
    points     = models.IntegerField()
    awarded_at = models.DateTimeField(auto_now_add=True)