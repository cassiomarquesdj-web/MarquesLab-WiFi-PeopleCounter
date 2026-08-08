from fastapi.testclient import TestClient

from backend.main import app

client = TestClient(app)


def test_health():
    response = client.get('/health')
    assert response.status_code == 200
    assert response.json()['status'] == 'ok'


def test_occupancy_empty():
    response = client.get('/api/v1/occupancy')
    assert response.status_code == 200
    body = response.json()
    assert 'people' in body
    assert 'zones' in body
