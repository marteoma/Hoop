from rest_framework import viewsets
from hoop.models import *
from hoop.serializers import *


# Create your views here.
class CourtViewSet(viewsets.ModelViewSet):
    serializer_class = CourtSerializer
    queryset = Court.objects.all()

