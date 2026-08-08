# Protocolo CSI v1

## Frame

```json
{
  "sensor_id": "S01",
  "timestamp_ms": 1720000000000,
  "zone": "Pista",
  "amplitude": [12.1, 12.4, 11.9]
}
```

## Regras

- `sensor_id`: identificador local do sensor.
- `timestamp_ms`: timestamp do sensor.
- `zone`: zona fisica configurada.
- `amplitude`: amostras normalizadas usadas pelo MVP.

A versao final pode transportar amplitude/phase por subcarrier e metadados de canal quando o hardware estiver validado.

## Endpoint

`POST /api/v1/sensors/frame`

O backend deve rejeitar payloads grandes, timestamps impossiveis e sensores nao autorizados quando o modo de producao for habilitado.
