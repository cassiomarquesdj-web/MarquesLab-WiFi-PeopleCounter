# MarquesLab WiFi People Counter

Sistema experimental de estimativa de ocupação e fluxo de pessoas usando Wi-Fi Sensing / CSI.

> Objetivo: estimar presença e movimento em ambientes de eventos sem utilizar câmeras para identificar pessoas.

## Visão do projeto

O sistema será dividido em três camadas:

1. **Sensores Wi-Fi / CSI** — dispositivos no ambiente coletam variações do canal causadas por movimento e presença.
2. **Engine de processamento** — filtra sinais, extrai características e estima atividade/ocupação.
3. **APK Android** — painel em Flutter para monitorar sensores, zonas, ocupação estimada e fluxo.

## MVP — Fase 1

- [ ] Firmware inicial para sensor compatível com CSI
- [ ] Coleta e transmissão de amostras
- [ ] Backend/engine para receber dados
- [ ] Detecção de movimento
- [ ] Calibração do ambiente
- [ ] Painel Flutter básico
- [ ] Estimativa de ocupação por zona
- [ ] Histórico de pico e fluxo

## Arquitetura inicial

```text
[Sensor CSI 01] ─┐
[Sensor CSI 02] ─┼──> [WiFi / LAN] ──> [People Counter Engine] ──> [APK Flutter]
[Sensor CSI N ] ─┘                                      │
                                                       └──> métricas
```

## Importante sobre precisão

O sistema começa como **estimador de movimento/presença**. Não deve assumir que uma variação de Wi-Fi equivale automaticamente a uma pessoa. A contagem de público será construída depois de calibração e validação com dados reais do ambiente.

## Privacidade

O projeto não tem como objetivo identificar indivíduos. Os dados devem ser tratados como sinais agregados de presença/movimento.

## Próximo passo

Implementar o protótipo do sensor CSI e o pipeline de dados antes de tentar gerar uma contagem absoluta de pessoas.
