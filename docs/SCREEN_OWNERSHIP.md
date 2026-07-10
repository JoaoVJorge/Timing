# Screen Ownership

Este documento define o papel principal de cada aba do HelpOut. Use essas regras antes de adicionar atalhos, cards ou novas features em uma tela.

## Regra Geral

```text
Home = o que fazer agora
Perfil = como estou evoluindo
Grupos = como estou comparado aos outros
Config = como personalizo e gerencio o app
```

Cada rota deve ter um dono principal. Evite repetir a mesma acao com a mesma hierarquia em varias abas.

## Home

Responsabilidade: acao imediata.

Pode conter:

- saudacao;
- continuar timer;
- progresso de hoje;
- categorias/atividades;
- metas diarias;
- proximo horario;
- atalhos rapidos para criar ou iniciar atividade.

Nao deve conter:

- estatisticas totais;
- evolucao historica;
- conquistas;
- dados longos de perfil.

## Perfil

Responsabilidade: evolucao pessoal.

Pode conter:

- identidade publica curta;
- botao Editar;
- progresso acumulado;
- destaques;
- principal atividade;
- leituras principais;
- evolucao e marcos.

Nao deve conter:

- agenda como CTA principal;
- lista operacional de categorias;
- atalhos para iniciar estudo, metas ou agenda;
- os mesmos blocos de resumo da Home.

## Grupos

Responsabilidade: comparacao social.

Pode conter:

- grupo selecionado;
- periodo do ranking;
- explicacao da metrica;
- posicao do usuario;
- ranking;
- criar grupo.

Nao deve conter:

- atalhos para estudar;
- agenda;
- preferencias;
- dados detalhados de perfil pessoal.

## Config

Responsabilidade: conta, preferencias e suporte.

Pode conter:

- conta;
- tema;
- cor de destaque;
- notificacoes;
- idioma;
- FAQ;
- sobre;
- logout.

Nao deve conter:

- progresso;
- estatisticas;
- agenda;
- ranking;
- atalhos de uso diario.

## Donos de Rotas

| Rota/acao | Dono principal |
|---|---|
| Iniciar estudo ou atividade | Home |
| Abrir categoria | Home |
| Metas diarias | Home |
| Agenda e adicionar horario | Home / Agenda |
| Editar perfil visual | Perfil |
| Ver evolucao | Perfil |
| Ranking | Grupos |
| Criar grupo | Grupos |
| Tema, idioma e notificacoes | Config |
| Conta e logout | Config |

## Regra de Cards

- Card de acao pode navegar para um fluxo operacional.
- Card de estatistica deve informar.
- Se um card de estatistica for clicavel, ele deve abrir detalhes analiticos, nao iniciar um fluxo operacional.
