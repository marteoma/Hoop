from rest_framework import serializers
from hoop.models import *


class CourtSerializer(serializers.ModelSerializer):
    class Meta:
        model = Court
        fields = '__all__'
