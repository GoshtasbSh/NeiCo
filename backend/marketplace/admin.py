from django.contrib import admin
from .models import SurplusItem, Claim

@admin.register(SurplusItem)
class SurplusItemAdmin(admin.ModelAdmin):
    list_display = ("id", "owner", "name", "quantity", "unit", "store", "created_at")
    list_filter = ("store", "owner")
    search_fields = ("name",)

@admin.register(Claim)
class ClaimAdmin(admin.ModelAdmin):
    list_display = ("id", "item", "claimant", "created_at")
    list_filter = ("claimant", "item")