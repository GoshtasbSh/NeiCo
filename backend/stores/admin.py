from django.contrib import admin
from .models import Store, StoreItem

@admin.register(Store)
class StoreAdmin(admin.ModelAdmin):
    list_display = ("id", "name")
    search_fields = ("name",)

admin.site.register(StoreItem)