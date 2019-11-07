from rest_framework import serializers
from hoop.models import *


class CourtSerializer(serializers.ModelSerializer):
    class Meta:
        model = Court
        fields = '__all__'


class PlayerSerializer(serializers.ModelSerializer):
    score = serializers.FloatField(read_only=True)
    courts = CourtSerializer(read_only=True, many=True)

    class Meta:
        model = Player
        fields = ('id', 'position', 'fullname', 'score', 'courts')


class LinkedPlayerSerializer(serializers.ModelSerializer):
    class Meta:
        model = LinkedPlayer
        fields = ('id', 'court', 'player', 'score')
