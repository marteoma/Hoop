from django.contrib import admin

from hoop.models import *


@admin.register(Player)
class PlayerAdmin(admin.ModelAdmin):
    list_display = ('user', 'position', 'score')


@admin.register(Court)
class CourtAdmin(admin.ModelAdmin):
    list_display = ('name', 'latitude', 'longitude', 'type')
