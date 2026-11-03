import os
import json
from django.core.management.base import BaseCommand
from stores.models import Store
from django.conf import settings

class Command(BaseCommand):
    help = 'Import stores from stores_name.json into the Store model.'

    def handle(self, *args, **options):
        # Path to the JSON file (now in backend directory)
        json_path = os.path.join(settings.BASE_DIR, 'stores_name.json')
        if not os.path.exists(json_path):
            self.stderr.write(self.style.ERROR(f'File not found: {json_path}'))
            return
        with open(json_path, 'r') as f:
            stores = json.load(f)
        Store.objects.all().delete()
        count = 0
        for store in stores:
            store_id = store.get('id')
            name = store.get('name')
            icon = store.get('icon', '')
            if name and store_id:
                obj, created = Store.objects.update_or_create(
                    id=store_id,
                    defaults={'name': name, 'icon': icon}
                )
                count += 1
        self.stdout.write(self.style.SUCCESS(f'Imported {count} stores.')) 