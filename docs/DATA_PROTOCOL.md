# Protocolo de dados — v0

O protocolo inicial deve ser simples e independente do algoritmo.

Exemplo de mensagem JSON enviada pelo sensor:

```json
{
  "sensor_id": "sensor-01",
  "timestamp_ms": 0,
  "sample_rate_hz": 100,
  "sequence": 1,
  "csi": [0.0]
}
```

## Regras

- `sensor_id` identifica apenas o equipamento, não uma pessoa.
- `timestamp_ms` permite sincronização temporal.
- `sequence` detecta perda de pacotes.
- `csi` representa a amostra bruta ou uma representação compactada definida pelo firmware.

O formato é provisório e será ajustado após a escolha do hardware.
