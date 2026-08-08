# ESP32 CSI Sensor

Esta pasta será o firmware dos nós sensores.

## Responsabilidades do sensor

- inicializar Wi-Fi em modo compatível com captura CSI;
- capturar amostras CSI;
- timestamp das amostras;
- identificar o sensor;
- enviar dados pela LAN para a engine;
- expor estado de calibração e qualidade do sinal.

## Hardware

O hardware exato será definido no MVP após validar qual família ESP32/firmware oferece o CSI necessário com estabilidade suficiente para o ambiente do evento.

**Não assumir que qualquer ESP32 ou qualquer telefone Android fornece CSI utilizável.**

## Próximo passo

Implementar um capturador CSI mínimo e validar uma sequência de dados em ambiente controlado antes de desenvolver o algoritmo de contagem.
