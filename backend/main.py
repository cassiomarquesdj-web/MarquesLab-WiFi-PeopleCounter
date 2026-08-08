from __future__ import annotations

from collections import defaultdict, deque
from datetime import datetime, timezone
from math import sqrt
from typing import Dict

from fastapi import FastAPI
from pydantic import BaseModel, Field

app = FastAPI(title='MarquesLab WiFi People Counter', version='0.2.0')

class SensorFrame(BaseModel):
    sensor_id: str
    timestamp_ms: int
    amplitude: list[float] = Field(default_factory=list)
    zone: str = 'Pista'
    rssi: float = -60

class OccupancyResponse(BaseModel):
    timestamp: datetime
    people: int
    entering_per_minute: int
    leaving_per_minute: int
    confidence: float
    signal_quality: float
    presence_detected: bool
    motion_detected: bool
    zones: Dict[str, int]
    heatmap: list[float]
    active_sensors: int

frames: dict[str, SensorFrame] = {}
baselines: dict[str, float] = {}
history: dict[str, deque[float]] = defaultdict(lambda: deque(maxlen=30))
state: dict[str, tuple[bool, bool]] = {}
zone_people: dict[str, int] = defaultdict(int)
zone_intensity: dict[str, float] = defaultdict(float)

ZONE_CENTER = {
    'Entrada': (1, 1),
    'Pista': (4, 3),
    'Camarote': (6, 4),
}

@app.get('/health')
def health():
    return {'status': 'ok', 'service': 'people-counter-engine', 'mode': 'CSI'}

@app.post('/api/v1/calibration/reset')
def reset_calibration():
    baselines.clear()
    history.clear()
    state.clear()
    return {'ok': True, 'message': 'Baseline CSI resetada. Deixe o ambiente vazio durante a próxima calibração.'}

@app.post('/api/v1/sensors/frame')
def ingest(frame: SensorFrame):
    frames[frame.sensor_id] = frame
    if not frame.amplitude:
        return {'accepted': False, 'reason': 'empty_csi'}

    energy = sum(abs(v) for v in frame.amplitude) / len(frame.amplitude)
    history[frame.sensor_id].append(energy)

    if frame.sensor_id not in baselines:
        baselines[frame.sensor_id] = energy

    baseline = baselines[frame.sensor_id]
    deviation = abs(energy - baseline) / max(abs(baseline), 1e-6)

    # Slow baseline tracking prevents the system from treating stable changes as motion.
    baselines[frame.sensor_id] = baseline * 0.995 + energy * 0.005

    presence = deviation >= 0.12
    motion = deviation >= 0.22
    state[frame.sensor_id] = (presence, motion)

    # A single CSI node can reliably report presence/motion, but not identity or an exact
    # person count. Multi-sensor fusion is used later for event-scale counting.
    zone_people[frame.zone] = 1 if presence else 0
    zone_intensity[frame.zone] = min(1.0, deviation * 2.2)

    return {
        'accepted': True,
        'sensor_id': frame.sensor_id,
        'presence_detected': presence,
        'motion_detected': motion,
        'deviation': round(deviation, 4),
    }

def build_heatmap() -> list[float]:
    grid = [0.0] * 48
    for zone, intensity in zone_intensity.items():
        cx, cy = ZONE_CENTER.get(zone, (4, 3))
        for y in range(6):
            for x in range(8):
                distance = sqrt((x - cx) ** 2 + (y - cy) ** 2)
                value = intensity * max(0.0, 1.0 - distance / 3.6)
                index = y * 8 + x
                grid[index] = max(grid[index], value)
    return [round(value, 3) for value in grid]

@app.get('/api/v1/occupancy', response_model=OccupancyResponse)
def occupancy():
    presences = [presence for presence, _ in state.values()]
    motions = [motion for _, motion in state.values()]
    presence_detected = any(presences)
    motion_detected = any(motions)

    zones = {z: int(zone_people.get(z, 0)) for z in ('Entrada', 'Pista', 'Camarote')}
    # Until multi-sensor fusion is calibrated, report one or zero detected occupants per zone.
    people = sum(zones.values())

    qualities = []
    for frame in frames.values():
        qualities.append(max(0.0, min(1.0, (frame.rssi + 95) / 55)))
    signal_quality = sum(qualities) / len(qualities) if qualities else 0.0

    sensor_confidence = min(0.95, 0.55 + len(frames) * 0.08) if frames else 0.0
    confidence = sensor_confidence if frames else 0.0

    return OccupancyResponse(
        timestamp=datetime.now(timezone.utc),
        people=people,
        entering_per_minute=0,
        leaving_per_minute=0,
        confidence=confidence,
        signal_quality=round(signal_quality, 3),
        presence_detected=presence_detected,
        motion_detected=motion_detected,
        zones=zones,
        heatmap=build_heatmap(),
        active_sensors=len(frames),
    )
