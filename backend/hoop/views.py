from rest_framework import viewsets

from hoop.serializers import *


class CourtViewSet(viewsets.ModelViewSet):
    serializer_class = CourtSerializer
    queryset = Court.objects.all()


class PlayerViewSet(viewsets.ModelViewSet):
    serializer_class = PlayerSerializer
    queryset = Player.objects.all()


class LinkedPlayerViewSet(viewsets.ModelViewSet):
    serializer_class = LinkedPlayerSerializer
    queryset = LinkedPlayer.objects.all()
