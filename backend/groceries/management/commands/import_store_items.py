import json
from django.core.management.base import BaseCommand
from stores.models import Store, StoreItem
from django.conf import settings
import os

class Command(BaseCommand):
    help = 'Import store items from items.json into StoreItem model.'

    def handle(self, *args, **options):
        json_path = os.path.join(settings.BASE_DIR, 'items.json')
        with open(json_path, 'r') as f:
            items = json.load(f)
        count = 0
        for item in items:
            store_id = item.get('storeId')
            try:
                store = Store.objects.get(id=store_id)
            except Store.DoesNotExist:
                self.stderr.write(f"Store not found: {store_id}")
                continue
            StoreItem.objects.get_or_create(
                store=store,
                name=item['name'],
                defaults={
                    'image': item.get('image', ''),
                    'price': item.get('price', 0.0),
                    'unit': item.get('unit', ''),
                }
            )
            count += 1
        self.stdout.write(self.style.SUCCESS(f'Imported {count} store items.'))
