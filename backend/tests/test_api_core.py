import os
from pathlib import Path

os.chdir(Path(__file__).resolve().parents[1])

from fastapi.testclient import TestClient

from app.main import app, Base, engine

Base.metadata.drop_all(engine)
Base.metadata.create_all(engine)

client = TestClient(app)


def test_health():
    response = client.get('/health')
    assert response.status_code == 200
    assert response.json()['status'] == 'ok'


def test_entry_crud_and_soft_delete():
    created = client.post('/v1/entries', json={
        'kind': 'hydration',
        'data': {'amount_ml': 500},
        'record_date': '2026-09-13',
    })
    assert created.status_code == 201
    item = created.json()
    assert item['data']['amount_ml'] == 500
    assert item['version'] == 1

    record_id = item['id']
    updated = client.patch(f'/v1/entries/{record_id}', json={'data': {'amount_ml': 750}})
    assert updated.status_code == 200
    assert updated.json()['data']['amount_ml'] == 750
    assert updated.json()['version'] == 2

    listed = client.get('/v1/entries', params={'kind': 'hydration', 'target_date': '2026-09-13'})
    assert len(listed.json()) == 1

    deleted = client.delete(f'/v1/entries/{record_id}')
    assert deleted.status_code == 200
    assert client.get(f'/v1/entries/{record_id}').status_code == 404


def test_dashboard_and_summary():
    client.post('/v1/entries', json={'kind': 'body', 'data': {'weight_kg': 72.5}, 'record_date': '2026-09-13'})
    client.post('/v1/entries', json={'kind': 'sleep', 'data': {'duration_minutes': 450}, 'record_date': '2026-09-13'})
    dashboard = client.get('/v1/dashboard', params={'target_date': '2026-09-13'}).json()
    assert dashboard['counts']['body'] == 1
    assert dashboard['counts']['sleep'] == 1

    summary = client.get('/v1/analytics/summary', params={'days': 30}).json()
    assert summary['records'] >= 2
    assert summary['active_dates'] >= 1
