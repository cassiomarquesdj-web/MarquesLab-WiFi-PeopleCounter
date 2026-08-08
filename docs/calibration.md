# Calibracao de evento

## Etapa A — ambiente vazio

1. Ligar todos os sensores.
2. Aguardar estabilizacao do canal.
3. Coletar baseline por pelo menos 5 minutos.
4. Registrar ruido e variacao por sensor/zona.

## Etapa B — uma pessoa

1. Uma pessoa atravessa cada zona em diferentes velocidades.
2. Repetir em varias direcoes.
3. Registrar inicio/fim do movimento.
4. Ajustar limiares de atividade.

## Etapa C — multiplas pessoas

Executar grupos conhecidos, por exemplo 1, 2, 5, 10, 20 e 50 pessoas, e comparar a estimativa do sistema com a contagem real.

## Etapa D — evento

Usar a entrada/saida como referencia de fluxo e os sensores CSI como estimativa de ocupacao interna. Calcular erro medio, erro maximo e estabilidade por zona.

A meta do MVP e produzir uma estimativa operacionalmente util, nao uma promessa de precisao universal.
