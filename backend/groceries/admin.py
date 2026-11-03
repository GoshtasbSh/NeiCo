from django.contrib import admin
from .models import GroceryItem

@admin.register(GroceryItem)
class GroceryItemAdmin(admin.ModelAdmin):
    list_display = ('id', 'name', 'store', 'user', 'unit', 'price', 'created_at')
    list_filter = ('store', 'user')
    search_fields = ('name', 'store__name', 'user__username')