from rest_framework import viewsets, permissions
from .models import SurplusItem, Claim
from .serializers import SurplusItemSerializer, ClaimSerializer

class SurplusItemViewSet(viewsets.ModelViewSet):
    """
    list / retrieve / create / update / delete surplus items.
    """
    queryset = SurplusItem.objects.all()
    serializer_class = SurplusItemSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)

class ClaimViewSet(viewsets.ModelViewSet):
    """
    list / retrieve / create claims on surplus items by the current user.
    """
    queryset = Claim.objects.all()
    serializer_class = ClaimSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        # only let users see their own claims
        return Claim.objects.filter(claimant=self.request.user)

    def perform_create(self, serializer):
        serializer.save(claimant=self.request.user)