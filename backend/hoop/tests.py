from django.test import TestCase
from hoop.models import Court


class CourtTest(TestCase):
    def setUp(self):
        Court.objects.create(name="Test Court 3x3", latitude=72.165165, longitude=123.561588, type=Court.X3_3)

    def test_can_create_good_court(self):
        new_court = Court.objects.create(name="Test Court 4x4", latitude=72.165165,
                                         longitude=123.561588, type=Court.X4_4)
        assert new_court.name == "Test Court 4x4"
        assert new_court.latitude == 72.165165
        assert new_court.longitude == 123.561588
        assert new_court.type == Court.X4_4

    def test_invalid_float_court_fails(self):
        def create_bad_court():
            new_court = Court.objects.create(name="Test Court 4x4", latitude="b",
                                             longitude="a", type=Court.X4_4)
        self.assertRaises(ValueError, create_bad_court)
