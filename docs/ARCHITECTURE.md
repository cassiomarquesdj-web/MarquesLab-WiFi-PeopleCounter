# Arquitetura

## Objetivo

Construir um sistema de estimativa de ocupação para eventos a partir de Wi-Fi Sensing / CSI, sem câmeras e sem identificação individual.

## Componentes

### 1. Sensor

Hardware compatível com coleta de Channel State Information (CSI), inicialmente tratado como nó de aquisição.

Responsabilidades:

- coletar amostras CSI;
- adicionar timestamp e ID do sensor;
- transmitir amostras pela rede local;
- permitir calibração e diagnóstico.

### 2. People Counter Engine

Pipeline inicial:

```text
CSI bruto
  -> validação
  -> remoção de ruído
  -> normalização
  -> extração de características
  -> detecção de movimento
  -> estimativa de atividade
  -> fusão entre sensores
  -> ocupação estimada
```

O algoritmo deve separar **atividade/movimento** de **número absoluto de pessoas**. A segunda etapa depende de calibração e dados de referência.

### 3. APK Flutter

O aplicativo será o painel operacional do evento.

Primeiras telas:

- Dashboard
- Sensores
- Zonas
- Calibração
- Histórico
- Configurações

Métricas planejadas:

- ocupação estimada;
- entradas estimadas por minuto;
- saídas estimadas por minuto;
- fluxo líquido;
- pico de ocupação;
- atividade por zona;
- qualidade/confiança do sinal.

## Modelo de zonas

Um evento poderá possuir várias zonas, por exemplo:

```text
ENTRADA
PISTA
CAMAROTE
BAR
ÁREA EXTERNA
```

Cada zona pode ter um ou mais sensores. A engine fará a fusão dos sinais para evitar contar a mesma movimentação várias vezes.

## Privacidade

Não coletar nomes, rostos, áudio ou identificadores pessoais. O projeto deve trabalhar com sinais físicos agregados de presença/movimento.

## Limitação técnica

Um smartphone Android comum não deve ser tratado como sensor CSI universal. O MVP utilizará hardware compatível como sensor e o APK funcionará como painel/cliente da engine.
