# Sincronização Timing → Google Calendar

Na tela da agenda, toque no **ícone no canto superior direito → Conectar**. Autorize no
navegador e volte ao Timing. A conexão é independente do método de login no
Timing: usuários de email e Apple também podem conectar um calendário Google.
Após conectar, a agenda existente e os próximos horários são enviados ao
calendário principal dessa conta. Edições e exclusões no Timing atualizam os
eventos correspondentes. O menu permite sincronizar, reconectar ou desconectar.
Desconectar interrompe os próximos envios e elimina a credencial armazenada;
os eventos já criados permanecem no Google.

Cada dia da semana é uma série semanal. O início é a primeira ocorrência a
partir da data inicial; a data final é inclusiva. Sem horário, o evento ocupa
o dia inteiro. Sem horário final, dura uma hora. Os horários usam o fuso do
calendário Google, mostrado na interface, incluindo mudanças de horário de verão.
Não há importação de eventos ou edições feitas no Google para o Timing.

## Ativação no ambiente

1. Aplique `backend/schema/12_google_calendar.sql` no projeto Supabase (também
   incluído no arquivo consolidado `backend/supabase-setup.sql`). As tabelas de
   credenciais e estados OAuth têm RLS e só permitem acesso pelo service role.
2. No Google Cloud, habilite **Google Calendar API** e configure a tela de
   consentimento OAuth. Crie um cliente OAuth do tipo **Web application**.
   Pode ser um cliente separado do usado para login Supabase.
3. Cadastre este URI de redirecionamento autorizado, substituindo PROJECT_REF:
   `https://PROJECT_REF.supabase.co/functions/v1/google-calendar`.
4. Configure os segredos da função via dashboard Supabase ou `supabase secrets
   set`: `GOOGLE_CALENDAR_CLIENT_ID`, `GOOGLE_CALENDAR_CLIENT_SECRET`,
   `GOOGLE_CALENDAR_TOKEN_KEY` (32 bytes aleatórios em base64; por exemplo,
   `openssl rand -base64 32`). Não inclua estes valores em commits, builds,
   logs ou `dart-define`. A chave cifra refresh tokens com AES-GCM e vincula a
   cifra ao usuário. Guarde-a: trocar a chave exige reconectar as contas.
   `SUPABASE_URL`, `SUPABASE_ANON_KEY` e `SUPABASE_SERVICE_ROLE_KEY` são
   disponibilizados automaticamente nas Edge Functions do Supabase.
5. Publique usando `supabase functions deploy google-calendar --workdir backend
   --project-ref PROJECT_REF --no-verify-jwt`. O callback OAuth precisa ser
   público: cada POST valida o usuário com Supabase Auth, e cada GET exige um
   estado aleatório, de uso único, válido por dez minutos. A configuração está
   em `backend/supabase/config.toml`.
   Em builds Flutter web, configure também `GOOGLE_CALENDAR_RETURN_URL` como
   a URL HTTPS fixa da aplicação. No Android/iOS, o callback padrão abre o
   Timing via `helpout://calendar-callback`.
6. Para testes com OAuth em modo Testing, adicione a conta como test user no
   Google Cloud. Para produção, publique a configuração de consentimento e
   conclua a verificação dos escopos solicitados pelo Google, quando aplicável.

Escopos: `calendar.events.owned` para gerenciar eventos no calendário principal
que pertence à conta e `calendar.calendars.readonly` para ler seu ID e fuso.
Credenciais do Google ficam exclusivamente no backend. O app guarda somente o
estado de conexão, separado por usuário.

Falhas não desfazem o salvamento local. A fila existente tenta novamente quando
há conexão, na abertura/retorno ao app e durante a reconciliação periódica.
A sincronização do Google aguarda alterações pendentes do Timing chegarem ao
Supabase. IDs determinísticos e checkpoints por evento evitam duplicações em
retries, e uma lease no banco serializa os envios entre dispositivos. Não há
worker independente enquanto o app está fechado: os envios pendentes continuam
quando ele retorna. Um refresh token revogado exige reconexão.

## Erro 404 ao conectar

Se `POST /functions/v1/google-calendar` retornar `404` com
`{"code":"NOT_FOUND","message":"Requested function was not found"}`, a função
não está disponível no projeto configurado no app. Confira se `supabaseUrl`
do arquivo de ambiente aponta para o projeto correto e conclua os passos de
ativação acima, incluindo schema, segredos e publicação da função. O login
Google do Supabase não publica essa integração automaticamente.

O app informa a indisponibilidade e preserva os horários e a fila de
sincronização. Reconectar a conta não substitui a publicação da função.

## Verificação

- `flutter test test/core/services/google_calendar/google_calendar_service_test.dart`
- `deno test --allow-env backend/supabase/functions/google-calendar`
- `cd backend/tests && pnpm install && pnpm test:calendar`
- `deno check backend/supabase/functions/google-calendar/index.ts`
- Validação real: conectar, criar horários em vários dias com término definido,
  editar, excluir, salvar offline e reconectar; conferir o calendário principal.
  Desconectar e confirmar que novas alterações não são enviadas. Verificar uma
  conta Timing diferente e confirmar que ela não herda a conexão.

Referências: [Google Calendar events](https://developers.google.com/workspace/calendar/api/v3/reference/events/insert)
e [OAuth offline access](https://developers.google.com/identity/protocols/oauth2/web-server#offline).
