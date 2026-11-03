import os
import json
from django.core.management.base import BaseCommand
from groceries.models import GroceryItem
from stores.models import Store
from django.conf import settings

class Command(BaseCommand):
    help = 'Import grocery items from items.json into the GroceryItem model.'

    def handle(self, *args, **options):
        json_path = os.path.join(settings.BASE_DIR, 'items.json')
        if not os.path.exists(json_path):
            self.stderr.write(self.style.ERROR(f'File not found: {json_path}'))
            return
        with open(json_path, 'r') as f:
            items = json.load(f)
        GroceryItem.objects.all().delete()  # Optional: clear existing items
        count = 0
        for item in items:
            store_id = item.get('storeId')
            try:
                store = Store.objects.get(id=store_id)
            except Store.DoesNotExist:
                self.stderr.write(self.style.ERROR(f'Store not found: {store_id}'))
                continue
            GroceryItem.objects.create(
                store=store,
                name=item.get('name'),
                image=item.get('imageName', ''),
                price=item.get('price', 0.0),
                quantity=item.get('quantity', 1),
                unit=item.get('unit', ''),
            )
            count += 1
        self.stdout.write(self.style.SUCCESS(f'Imported {count} items.'))
