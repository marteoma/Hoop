from django.contrib.auth.models import User
from django.db import models
from django.db.models.aggregates import Avg


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

    def __str__(self):
        return self.name

    class Meta:
        ordering = ('name', )


class Player(models.Model):
    P1 = "1"
    P2 = "2"
    P3 = "3"
    P4 = "4"
    P5 = "5"

    POSITION_CHOICES = (
        (P1, 'Point Guard'),
        (P2, 'Shooter Guard'),
        (P3, 'Small Forward'),
        (P4, 'Power Forward'),
        (P5, 'Centre'),
    )

    fullname = models.CharField(max_length=100)
    position = models.CharField(max_length=2, choices=POSITION_CHOICES)
    courts = models.ManyToManyField(Court, related_name='courts', through='LinkedPlayer')

    @property
    def score(self):
        return LinkedPlayer.objects.filter(player=self).aggregate(Avg('score'))['score__avg']

    def __str__(self):
        return self.fullname

    class Meta:
        ordering = ('fullname', )


class LinkedPlayer(models.Model):
    court = models.ForeignKey(Court, on_delete=models.CASCADE)
    player = models.ForeignKey(Player, on_delete=models.CASCADE)
    score = models.FloatField()
    date = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ('date', )
