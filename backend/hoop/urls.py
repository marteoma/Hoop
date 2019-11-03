from django.urls import path, include
from rest_framework import routers
from hoop.views import *
from rest_framework_jwt.views import obtain_jwt_token, refresh_jwt_token, verify_jwt_token

router = routers.DefaultRouter()
router.register('courts', CourtViewSet)
router.register('players', PlayerViewSet)
router.register('linked', LinkedPlayerViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('api-token-auth/', obtain_jwt_token),
    path('api-token-refresh/', refresh_jwt_token),
    path('api-token-verify/', verify_jwt_token),
]
