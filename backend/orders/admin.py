from django.contrib import admin
from .models import Order, OrderItem, Reward

@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ("id", "owner", "store", "status", "created_at")
    list_filter = ("status", "store")
    search_fields = ("owner__username",)

@admin.register(OrderItem)
class OrderItemAdmin(admin.ModelAdmin):
    list_display = ("id", "order", "name", "quantity", "price")
    list_filter = ("order__status",)
    search_fields = ("name",)

@admin.register(Reward)
class RewardAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "order", "points", "awarded_at")
    list_filter = ("user",)