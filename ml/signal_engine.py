from __future__ import annotations

from dataclasses import dataclass
import math

@dataclass
class SignalFeatures:
    mean: float
    variance: float
    energy: float
    movement_score: float


def extract_features(samples: list[float]) -> SignalFeatures:
    if not samples:
        return SignalFeatures(0.0, 0.0, 0.0, 0.0)
    mean = sum(samples) / len(samples)
    variance = sum((x - mean) ** 2 for x in samples) / len(samples)
    energy = sum(x * x for x in samples) / len(samples)
    movement = min(1.0, math.sqrt(variance) / (abs(mean) + 1e-6))
    return SignalFeatures(mean, variance, energy, movement)


def estimate_activity(features: SignalFeatures) -> str:
    if features.movement_score < 0.08:
        return 'still'
    if features.movement_score < 0.30:
        return 'low'
    if features.movement_score < 0.65:
        return 'medium'
    return 'high'
