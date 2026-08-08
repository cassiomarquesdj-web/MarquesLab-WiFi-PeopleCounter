from __future__ import annotations

from collections import defaultdict
from datetime import datetime, timezone
from typing import Dict

from fastapi import FastAPI
from pydantic import BaseModel, Field

app = FastAPI(title='MarquesLab WiFi People Counter', version='0.1.0')

class SensorFrame(BaseModel):
    sensor_id: str
    timestamp_ms: int
    amplitude: list[float] = Field(default_factory=list)
    zone: str = 'Pista'

class OccupancyResponse(BaseModel):
    timestamp: datetime
    people: int
    entering_per_minute: int
    leaving_per_minute: int
    confidence: float
    zones: Dict[str, int]
    active_sensors: int

frames: dict[str, SensorFrame] = {}
zone_people: dict[str, int] = defaultdict(int)

@app.get('/health')
def health():
    return {'status': 'ok', 'service': 'people-counter-engine'}

@app.post('/api/v1/sensors/frame')
def ingest(frame: SensorFrame):
    frames[frame.sensor_id] = frame
    # MVP: a real model will replace this heuristic after CSI calibration.
    signal_energy = sum(abs(v) for v in frame.amplitude) / max(len(frame.amplitude), 1)
    zone_people[frame.zone] = max(0, min(500, round(signal_energy * 10)))
    return {'accepted': True, 'sensor_id': frame.sensor_id}

@app.get('/api/v1/occupancy', response_model=OccupancyResponse)
def occupancy():
    zones = {z: int(zone_people.get(z, 0)) for z in ('Entrada', 'Pista', 'Camarote')}
    people = sum(zones.values())
    confidence = 0.0 if not frames else min(0.99, 0.55 + len(frames) * 0.12)
    return OccupancyResponse(
        timestamp=datetime.now(timezone.utc),
        people=people,
        entering_per_minute=0,
        leaving_per_minute=0,
        confidence=confidence,
        zones=zones,
        active_sensors=len(frames),
    )
