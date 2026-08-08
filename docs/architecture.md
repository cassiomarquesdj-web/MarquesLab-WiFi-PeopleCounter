# Arquitetura

## Objetivo
Estimar ocupacao e fluxo de pessoas em eventos usando Wi-Fi Sensing/CSI, sem camera e sem identificar individuos.

## Pipeline

```text
[ESP32 CSI Sensors]
        |
        | frames CSI
        v
[Signal Engine]
        |
        | features + activity
        v
[Occupancy Fusion]
        |
        | people / zones / confidence
        +--------------------+
        |                    |
        v                    v
[HTTP API]              [event logs]
        |
        v
[Flutter APK]
```

## Principios
- A primeira versao trabalha com estimativa, nao com promessa de precisao absoluta.
- O sistema nao captura imagem nem audio.
- Nenhum identificador pessoal e necessario para o contador.
- A calibracao deve ser feita no local do evento.
- Multiplos sensores sao usados para reduzir zonas cegas.

## Evolucao
1. Validar movimento com um sensor.
2. Calibrar ambiente vazio.
3. Calibrar uma pessoa andando.
4. Treinar/ajustar estimativa para multiplas pessoas.
5. Adicionar sensores por zona.
6. Fazer fusao espacial e temporal.
7. Validar contra contagem manual e entrada/saida.
