---
name: commit
description: Cria um commit com uma mensagem descritiva e faz push para o remoto. Use quando o usuário pedir para commitar, salvar o trabalho, ou invocar /commit. Pode ser invocado via /commit ou /commit <descrição do que foi feito>. Se uma descrição for passada, use-a como base para a mensagem do commit.
---

# Commit e push

Commita **todas** as mudanças da working tree, agrupadas por contexto em commits separados, e publica no remoto.

## Princípio: agrupar por contexto

Não junte tudo num único commit nem deixe arquivos de fora. Analise as mudanças e **agrupe os arquivos que compartilham o mesmo contexto no mesmo commit**, gerando um commit por grupo.

Exemplos de contexto:
- Arquivos de tradução/localização (ex.: `app_en.arb`, `app_localizations*.dart`) → um commit de linguagem.
- Arquivos de uma mesma feature/tela (ex.: os widgets de um bottom sheet) → um commit da feature.
- Uma correção de bug isolada → seu próprio commit.

O objetivo é que, ao final, **não sobre nenhuma mudança sem commitar** e cada commit conte uma história coerente.

## Argumento opcional

O usuário pode invocar com uma descrição:
- `/commit` — sem contexto, derive a mensagem a partir das mudanças (`git diff`/`git status`) e da conversa atual.
- `/commit corrige scroll do chat` — use a descrição como base para a mensagem do commit.

## Passos

1. Verifique o branch atual:
   ```bash
   git rev-parse --abbrev-ref HEAD
   ```
   Se estiver em `main` ou `master`, **pare e avise o usuário** — nunca commitar direto na main. Sugira criar uma branch com `/branch` antes.

2. Veja tudo que mudou:
   ```bash
   git status --porcelain
   git diff --stat
   ```

3. Agrupe **todos** os arquivos modificados/novos por contexto (veja o princípio acima). Liste mentalmente os grupos antes de começar. Nada pode ficar de fora.

4. Para **cada grupo**, faça o stage apenas dos arquivos daquele contexto e crie o commit:
   ```bash
   git add <arquivos-do-grupo>
   git commit -m "<tipo>: <descrição curta>" -m "<corpo opcional explicando o porquê>"
   ```
   Repita para cada grupo, um commit por contexto.

   Tipos permitidos (apenas estes três):
   - `feat:` — nova funcionalidade, adição, config, dependência
   - `fix:` — correção de bug ou comportamento errado
   - `wip:` — trabalho em progresso ou checkpoint parcial

5. Ao terminar os commits, confirme que a working tree está limpa:
   ```bash
   git status --porcelain
   ```
   Se ainda sobrar algo, volte ao passo 3.

6. Faça push para o remoto. Se a branch ainda não tem upstream, defina-o:
   ```bash
   git push
   ```
   ou, se for o primeiro push da branch:
   ```bash
   git push -u origin <nome-da-branch>
   ```

7. Confirme ao usuário listando **todos** os commits criados: **"Commitado e enviado: `<hash> <tipo>: ...`"** (uma linha por commit).

## Regras

- Mensagem de commit sempre em inglês.
- Apenas os prefixos `feat:`, `fix:` ou `wip:`. Nunca `chore:`, `refactor:`, `docs:` ou qualquer outro.
- Nunca adicionar o trailer `Co-Authored-By`.
- Nunca commitar direto na `main`/`master`.
- Commitar **tudo** que estiver na working tree — não deixar mudanças de fora.
- Nunca juntar contextos diferentes no mesmo commit; um commit por grupo de contexto.
