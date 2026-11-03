from django.contrib import admin
from .models import BasketItem

@admin.register(BasketItem)
class BasketItemAdmin(admin.ModelAdmin):
    list_display = ("id", "user", "groceryitem", "quantity", "added_at")
    list_filter = ("user",)
    search_fields = ("groceryitem__name",)