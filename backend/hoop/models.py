from django.db import models


# Create your models here.
class Court(models.Model):
    X3_3 = "3x3"
    X4_4 = "4x4"
    X5_5 = "5x5"

    TYPE_CHOICES = (
        (X3_3, '3x3'),
        (X4_4, '4x4'),
        (X5_5, '5x5')
    )

    name = models.CharField(max_length=100)
    latitude = models.FloatField()
    longitude = models.FloatField()
    type = models.CharField(max_length=3, choices=TYPE_CHOICES)
