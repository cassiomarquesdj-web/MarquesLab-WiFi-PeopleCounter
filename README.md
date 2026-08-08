# MarquesLab WiFi People Counter

Sistema experimental para estimativa de ocupacao e fluxo de pessoas em eventos usando Wi-Fi Sensing / CSI, sem camera e sem identificacao individual.

## Estado atual

**MVP em desenvolvimento.** O repositorio ja possui a base integrada de firmware, engine Python e APK Flutter.

### Componentes

```text
ESP32 CSI Sensors
      ↓
CSI / Signal Features
      ↓
Python Occupancy Engine
      ↓
HTTP API
      ↓
Flutter Android APK
      ↓
Dashboard de evento
```

## Estrutura

- `app/` — aplicativo Flutter Android.
- `backend/` — API e engine inicial de ocupacao.
- `firmware/esp32/` — firmware base para captura CSI.
- `ml/` — extracao de caracteristicas e classificacao inicial de atividade.
- `docs/` — arquitetura e especificacoes.
- `.github/workflows/` — CI para testes e build do APK.

## Dashboard

O APK ja possui:

- pessoas presentes;
- fluxo de entrada e saida;
- confianca da estimativa;
- ocupacao por Entrada, Pista e Camarote;
- quantidade de sensores ativos;
- modo demonstracao para validar a interface antes do hardware;
- cliente HTTP para conectar ao engine.

## Sensor

O firmware ESP32 ja possui o esqueleto de inicializacao e callback CSI. A proxima camada de hardware deve adicionar configuracao segura de Wi-Fi, identidade do sensor e envio dos frames normalizados ao backend.

## Engine

A API oferece:

- `GET /health`
- `POST /api/v1/sensors/frame`
- `GET /api/v1/occupancy`

O algoritmo atual e propositalmente uma baseline. A contagem real deve ser calibrada com dados coletados no ambiente do evento e comparada com contagem manual/fluxo de entrada.

## Build

O GitHub Actions gera automaticamente um APK release quando houver push na `main`. O artefato fica disponivel na execucao do workflow.

## Precisao

Wi-Fi CSI detecta alteracoes na propagacao do sinal; nao existe uma conversao universal de amplitude para numero de pessoas. O produto final deve usar multiplos sensores, calibracao, filtragem temporal e fusao espacial para chegar a uma estimativa util para eventos.

## Privacidade

O sistema foi desenhado para trabalhar com sinais agregados de presenca/movimento. Nao utiliza camera para identificar pessoas e nao precisa armazenar identidade individual.
