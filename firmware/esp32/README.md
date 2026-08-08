# ESP32 CSI Sensor

Firmware do nó sensor. O objetivo é transformar alterações do canal Wi-Fi em frames CSI para o engine de ocupação.

## MVP
- ESP32 compatível com CSI via ESP-IDF.
- Wi-Fi STA conectado à mesma LAN do backend.
- Captura CSI habilitada.
- Publicação HTTP periódica.
- Identidade estável por `SENSOR_ID`.

## Fluxo
ESP32 → CSI callback → normalização → HTTP POST → backend → engine → APK.

Credenciais e endereço do backend devem ser configurados localmente; nunca commitá-los.
