# Adaptive Traffic Light Controller on FPGA

Revisão técnica de um projeto acadêmico desenvolvido para a placa Digilent
Nexys4 DDR. O circuito representa um cruzamento com duas vias e ajusta o tempo
verde a partir da demanda de carros e pedestres informada pelas 16 chaves da
placa.

> Este repositório é uma reconstrução verificável do projeto original. A versão
> arquivada continha documentação, pinagem e resultados do Vivado, mas também
> módulos vazios e conexões incompletas. A arquitetura foi preservada e o RTL
> foi refeito com clock único, clock-enable e testes autochecking.

## Arquitetura

```text
switches + botão ──> captura sincronizada da demanda
                              │
clock 100 MHz ──> tick 1 Hz ──┼──> FSM adaptativa de quatro fases
                              │              │
                              └──────────────┴──> LEDs de carros e pedestres
```

As fases são:

1. via A verde / via B vermelha;
2. via A amarela / via B vermelha;
3. via A vermelha / via B verde;
4. via A vermelha / via B amarela.

Para cada via, a demanda é `carros + pedestres`. O tempo verde parte de 33 s e
recebe a diferença entre as demandas das duas vias, limitado entre 15 s e 60 s.
O amarelo permanece fixo em 10 s.

## Estrutura

- `rtl/`: RTL SystemVerilog sintetizável;
- `tb/`: teste autochecking do controlador;
- `constraints/`: pinagem da Nexys4 DDR;
- `.github/workflows/`: regressão pública com Icarus Verilog.

## Simulação aberta

```bash
make test
```

## Implementação no Vivado

Adicione os arquivos de `rtl/`, selecione `semaphore_top` como top e use
`constraints/nexys4ddr.xdc`. A placa recebe:

- `SW[3:0]`: carros na via A;
- `SW[7:4]`: pedestres na via A;
- `SW[11:8]`: carros na via B;
- `SW[15:12]`: pedestres na via B;
- `BTNC`: captura uma nova leitura;
- `CPU_RESETN`: reset ativo em nível baixo.

## English summary

Synthesizable adaptive two-road traffic controller for the Nexys4 DDR FPGA.
The reconstruction replaces incomplete student sources with a single-clock,
clock-enable architecture, bounded adaptive timing and self-checking tests.
