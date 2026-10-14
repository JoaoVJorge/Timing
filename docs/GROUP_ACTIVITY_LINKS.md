# Atividades vinculadas a grupos

Um grupo não tem atividade própria. Ele tem um **tema**, e cada integrante
escolhe quais das suas atividades pessoais desse tema contam para ele: por
exemplo, todas as leituras para o grupo Leitura, ou Superior + Inferior para
um grupo de Exercícios. Nome, notas, meta, aparência e histórico pessoais nunca
passam para o grupo.

| Tema do grupo | O que pode ser vinculado | Métrica do ranking |
| --- | --- | --- |
| Estudos, Exercícios, Hobbies | atividades da mesma categoria, quantas quiser | tempo |
| Leitura | atividades de leitura, quantas quiser | páginas |
| Metas diárias | **uma** meta por pessoa | dias concluídos |

## Fluxos

- Criação: nome, descrição e tema. Escolhido o tema, a pessoa já pode marcar
  as atividades próprias que se encaixam nele. É opcional; não existe etapa de
  atividade nem "criar atividade" para o grupo.
- Convite/código: após a entrada, abre a seleção individual. Se a pessoa fechar
  a tela, pode configurar depois.
- Menu do grupo: **Atividades vinculadas**, disponível a qualquer integrante,
  permite alterar a seleção. Desmarcar todas pausa as contribuições.
- As opções são sempre as da própria pessoa. Para vincular algo que ainda não
  existe, cria-se a atividade (ou a meta) normalmente na tela inicial.
- Editar grupo altera nome, descrição e cor. O tema não muda depois de criado,
  porque os vínculos de todos dependem dele.
- A mesma atividade pode estar vinculada a vários grupos do mesmo tema.

## Contagem e histórico

`group_activity_links` guarda grupo, integrante, fonte pessoal e períodos
`[started_at, ended_at)`, definidos pelo servidor. Uma fonte que permanece
selecionada mantém seu início. Desvincular encerra o período; vincular
novamente abre outro. O intervalo sem vínculo não conta, mesmo após
sincronização de registros offline. O ranking usa `EXISTS` para contar cada
registro uma vez por grupo.

Metas diárias possuem histórico por data, sem horário. Antes de vincular, o app
sincroniza alterações pendentes; o servidor exclui as datas já concluídas e
registra novas marcações em `group_goal_contributions`. A mesma data conta uma
vez. Desmarcar enquanto vinculada desfaz a contribuição; períodos encerrados
preservam suas contribuições. A data local é enviada pelo app e validada pelo
servidor.

Resetar o grupo grava `groups.score_reset_at`: o ranking passa a contar dali em
diante e o histórico pessoal de cada um continua intacto.

Sair/ser removido encerra os vínculos sem tocar em atividades ou histórico
pessoal. Reentrar exige nova seleção.

## Banco e implantação

Aplicar **backend/supabase-setup.sql** junto com a distribuição do novo
aplicativo. O arquivo é gerado a partir de `backend/schema/*.sql`. Não basta
atualizar somente o Flutter, e esta alteração no repositório não publica o
banco remoto.

A seção 05 converte instalações existentes no próprio lugar e pode ser
executada mais de uma vez:

- os vínculos passam da atividade compartilhada para o grupo, com os mesmos
  períodos e contribuições;
- a cor e a data do último reset da atividade compartilhada vão para o grupo;
- cópias antigas entregues pelo grupo viram vínculos para a mesma linha pessoal;
- num grupo de metas, cada pessoa fica com o vínculo mais antigo ativo; os
  demais são encerrados, mantendo o que já contaram;
- `group_activities` e os RPCs `group_activity_progress` e
  `update_group_with_activity` deixam de existir.

Versões anteriores do aplicativo dependem dessas estruturas e deixam de
carregar grupos depois da implantação. As colunas `group_id` e
`group_activity_id` de `user_subjects` e `daily_goals` continuam existindo,
sempre nulas, apenas para que essas versões sigam sincronizando os dados
pessoais.

As alterações de seleção exigem conexão e passam por RPC com validação de
integrante, propriedade e tema. Os períodos e contribuições não aceitam escrita
direta do cliente. Ninguém lê as atividades ou os registros de outro
integrante: só os totais do ranking saem do servidor.

## Validação

Testes Flutter: criação em três etapas com fontes do tema, meta única, seleção
e retentativa de erro na tela de vínculos, edição do grupo e ranking.

Testes reais de SQL em PostgreSQL via PGlite, sem acesso a projeto Supabase:

```sh
cd backend/tests
npm install
npm test
```

O teste aplica o schema (exceto Storage), simula o identificador autenticado e
exercita a conversão de uma instalação anterior, nova implantação idempotente,
RPCs, RLS, criação, entrada, saída, múltiplas fontes, meta única, intervalos,
páginas, edição e reset. O mock de autenticação e os dados ficam somente no
banco de teste.
