# Atividades pessoais vinculadas a grupos

Cada atividade compartilhada define a meta do grupo. Cada integrante escolhe
uma ou várias atividades pessoais compatíveis para contribuir: por exemplo,
Superior + Inferior para Academia. Nome, notas, meta, aparência e histórico
pessoais continuam independentes das configurações do grupo.

## Fluxos

- Criação: usar atividades existentes (seleção múltipla) ou criar uma atividade.
  A primeira selecionada preenche a sugestão da meta compartilhada; selecionar
  outras não substitui os valores já editados. O resumo lista a seleção.
- Convite/código: após a entrada, abre a seleção individual. Não se cria uma
  cópia antes dessa escolha. Se a pessoa fechar a tela, pode configurar depois.
- Menu do grupo: **Minhas atividades vinculadas**, disponível a qualquer
  integrante, permite alterar a seleção. Desmarcar todas pausa contribuições.
- As opções são da própria pessoa e da categoria/unidade compatível. Leitura
  exibe um lembrete para respeitar o livro definido pelo grupo, quando houver.
- Criar uma atividade copia os valores iniciais do grupo para uma atividade
  pessoal; mudanças futuras no grupo não sobrescrevem essa atividade.

## Contagem e histórico

`group_activity_links` guarda integrante, atividade compartilhada, fonte pessoal
 e períodos `[started_at, ended_at)`, definidos pelo servidor. Uma fonte que
permanece selecionada mantém seu início. Desvincular encerra o período; vincular
novamente abre outro. O intervalo sem vínculo não conta, mesmo após sincronização
de registros offline. O ranking usa `EXISTS` para contar cada registro uma vez
por grupo, inclusive quando houver mais de uma atividade compartilhada.

Metas diárias possuem histórico por data, sem horário. Antes de vincular, o app
sincroniza alterações pendentes; o servidor exclui as datas já concluídas e
registra novas marcações em `group_goal_contributions`. A mesma data conta uma
vez. Desmarcar enquanto vinculada desfaz a contribuição; períodos encerrados
preservam suas contribuições. A data local é enviada pelo app e validada pelo
servidor. As regras anteriores de reset do grupo continuam valendo.

Sair/ser removido encerra os vínculos sem excluir fontes ou histórico pessoal.
Reentrar exige nova seleção. Excluir voluntariamente uma atividade pessoal ou
seu histórico continua seguindo as regras pessoais de exclusão do app.

## Banco e implantação

Aplicar **backend/supabase-setup.sql** antes de distribuir o novo aplicativo.
O arquivo é gerado a partir de `backend/schema/*.sql`. Não basta atualizar
somente o Flutter. Esta alteração no repositório não publica o banco remoto.

A seção 05 migra as cópias existentes em seu próprio lugar: mantém IDs e
histórico, cria os vínculos iniciais e libera os metadados pessoais. Executar o
setup novamente não duplica vínculos. Campos antigos enviados por caches são
normalizados para impedir que a atividade volte a pertencer ao grupo.

As alterações de seleção exigem conexão e passam por RPC com validação de
integrante, propriedade e categoria. Os períodos e contribuições não aceitam
escrita direta do cliente. As opções de outros integrantes não são expostas.

## Validação

Testes Flutter: criação com múltiplas fontes, mudança de categoria, seleção e
retentativa de erro na tela, preservação de cache ao sair e migração local.

Testes reais de SQL em PostgreSQL via PGlite, sem acesso a projeto Supabase:

```sh
cd backend/tests
npm install
npm test
```

O teste aplica o schema (exceto Storage), simula o identificador autenticado e
exercita RPCs, RLS, migração de grupos existentes, nova implantação idempotente,
criação, entrada, saída, múltiplas fontes, intervalos, páginas, metas diárias e
reset. O mock de autenticação e os dados ficam somente no banco de teste.
