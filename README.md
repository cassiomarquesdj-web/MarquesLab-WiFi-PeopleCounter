# MarquesLab WiFi People Counter

Sistema experimental de **Wi-Fi Sensing / CSI** para transformar alterações do canal de rádio em uma visualização de presença e movimento. O objetivo é criar um monitor invisível, sem câmera, útil tanto para eventos quanto para segurança residencial.

## O que estamos construindo

```text
Wi-Fi / ESP32 CSI
       ↓
Amplitude + fase + RSSI
       ↓
Baseline + filtragem + detecção
       ↓
Mapa de intensidade CSI
       ↓
Fusão de múltiplos sensores
       ↓
Flutter Android
       ↓
Presença / movimento / ocupação / alertas
```

A interface usa uma **paleta térmica** para representar a intensidade das alterações do sinal. Isso não é uma câmera térmica: são dados de rádio processados pelo algoritmo.

## Segurança residencial

O APK possui um modo **Proteção Ativa** para uso como sensor invisível de presença/movimento. Quando armado, o sistema pode indicar:

- ambiente livre;
- presença detectada;
- movimento detectado;
- qualidade do sinal;
- intensidade por região;
- alerta de movimento.

Para uma casa, o desenho recomendado é ter pelo menos dois pontos de rádio, permitindo observar alterações no caminho do sinal em mais de uma direção.

## Evento

Para contagem de público, a arquitetura usa múltiplos sensores. Um único sensor consegue indicar presença/movimento, mas **não deve ser tratado como contador exato de pessoas**. A contagem de dezenas ou centenas de pessoas exige calibração e fusão espacial de vários sensores.

## Componentes

- `app/` — APK Flutter Android.
- `backend/` — API FastAPI e engine CSI.
- `firmware/esp32/` — captura CSI no ESP32.
- `ml/` — espaço para modelos treinados.
- `docs/` — arquitetura e testes.
- `.github/workflows/` — CI e build do APK.

## Hardware recomendado

A família ESP32 suporta CSI. Para novos protótipos, ESP32-C5/C6 são opções especialmente interessantes para CSI; antena externa tende a facilitar testes por oferecer melhor diretividade. A documentação oficial da Espressif também fornece exemplos de recepção CSI, detecção humana e radar. cite-placeholder

## API

- `GET /health`
- `POST /api/v1/calibration/reset`
- `POST /api/v1/sensors/frame`
- `GET /api/v1/occupancy`

## Calibração

A primeira etapa real é sempre **calibrar o ambiente vazio**. O baseline representa o canal sem pessoa. Depois, o engine mede a diferença em relação ao baseline e aplica filtragem temporal/histerese para reduzir falsos positivos.

## Limitações importantes

CSI pode detectar alterações causadas por pessoas, inclusive em ambientes onde não existe linha de visão direta, mas desempenho através de paredes depende fortemente de paredes, distância, frequência, antenas, posição dos sensores, tráfego Wi-Fi e ambiente. Não tratamos o mapa como uma imagem fotográfica nem prometemos visão perfeita através de qualquer parede.

## Privacidade

O projeto não precisa de câmera nem identificação individual. Os dados enviados ao engine são características do sinal e estados agregados de presença/movimento.
