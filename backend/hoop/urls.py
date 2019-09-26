from django.urls import path, include
from rest_framework import routers
from hoop.views import *


router = routers.SimpleRouter()
router.register('courts', CourtViewSet)

urlpatterns = [
    path('', include(router.urls))
]