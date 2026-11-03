# NeiCo — Neighbors Shopping Together

NeiCo is a neighbor-to-neighbor shopping app. Instead of paying a gig shopper, you ask a neighbor who is already going to the same store. Neighbors can also split bulk packs, share buy-one-get-one extras, and combine small online orders to reach a free-shipping minimum.

NeiCo ran as a free TestFlight MVP with 10 users from May to November 2025. It was not funded, so development stopped after the pilot. The code is published here as a portfolio project.

**Built by [Goshtasb Shahriari Mehr](https://github.com/GoshtasbSh)** — sole developer: product design, iOS client, back-end API and data model.

---

## The problem

Grocery delivery apps charge the full delivery fee because the shopper makes a trip only for you. Warehouse stores sell in quantities a single person cannot use, so food and money go to waste. Online stores charge shipping on small orders, which pushes people to buy things they do not need.

## What the app does

| Feature | How it works |
|---|---|
| **Neighbor orders on a map** | Open orders from nearby neighbors appear as map pins. Filter by store and sort by distance or order size, then accept an order and add it to your own basket for the trip. |
| **Surplus marketplace** | Post the part of a bulk pack (Costco, Sam's Club) or a BOGO deal you will not use. Posts carry quantity, unit, price and an optional expiration date; nearby neighbors see how far away each item is and claim a share. |
| **Shared basket** | Your own items and the neighbor orders you accepted sit in one basket for the trip. |
| **Chat** | Buyer and shopper message each other to arrange pickup and hand-off. |
| **Star-coin rewards** | Neighbors who shop for others earn credit points tied to each order. |

## Architecture

```
iOS client (SwiftUI, MapKit, CoreLocation)
        │  REST + JWT
        ▼
Django 4.2 + Django REST Framework
        │
        ▼
PostgreSQL
```

**iOS client** — SwiftUI with an MVVM layout (`Models/`, `ViewModels/`, `Views/`, `Services/`). `APIClient` signs in against the Django API and loads stores, store items and the user's grocery list over REST with a bearer token; adding, updating and removing list items write back to the API. MapKit renders neighbor orders as annotations; CoreLocation supplies the user's position, and orders are ranked by great-circle distance in miles.

**Back end** — a Django REST API with seven apps:

| App | Models |
|---|---|
| `users` | custom `User` with reward credit and avatar |
| `stores` | stores, logos and per-store item catalog (`StoreItem`) |
| `groceries` | grocery catalog |
| `home` | per-user basket items |
| `orders` | `Order` (draft → pending → accepted / ignored), `OrderItem`, `Reward` |
| `marketplace` | `SurplusItem`, `Claim` |
| `chat` | `Chat`, `Participant`, `Message` |

Authentication uses JWT (`djangorestframework-simplejwt`) and DRF token auth; every resource is exposed through DRF viewsets under `/api/`. Management commands (`import_stores`, `import_items`, `import_store_items`) seed the catalog from the JSON files in `backend/`.

## Run it locally

**Back end**

```bash
cd backend
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env            # then set your own values and export them
createdb neico_dev               # PostgreSQL must be running
python manage.py migrate
python manage.py import_stores
python manage.py import_items
python manage.py import_store_items
python manage.py createsuperuser   # e.g. user "demo", password "neico-demo-2025" for the app's demo button
python manage.py runserver
```

The browsable API is at `http://127.0.0.1:8000/api/`; tokens come from `/api/token/` and `/api/token/refresh/`.

**iOS app**

Open `NeiCo/NeiCo.xcodeproj` in Xcode 16.3 or later (iOS 18.4 deployment target) and run on an iOS simulator. Start the back end first: sign-in, the Home tab and the grocery list call `http://127.0.0.1:8000/api/`. The neighbor-orders map and the marketplace still read bundled sample data (`NeiCo/*.json`).

## Repository layout

```
NeiCo/        SwiftUI iOS client (Xcode project, models, view models, views, sample data)
backend/      Django REST API (seven apps + project settings)
ItemImage/    product images used in the sample data
SotreLogos/   store logos and app icons
```

## Status

Discontinued after the May–November 2025 MVP pilot (10 users, no outside funding). Issues and pull requests are not monitored.
