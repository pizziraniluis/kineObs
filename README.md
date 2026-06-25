# # 📚 KineObs — Obsidian → Kindle Pipeline

Automação para estudante universitário: toda vez que um resumo ou cheat sheet
é salvo na vault do Obsidian, ele é convertido para EPUB e enviado
automaticamente para o Kindle via e-mail.

## Stack

- **Obsidian Remote** (`sytone/obsidian-remote`) — vault acessível pelo browser
- **Pandoc** — conversão Markdown → EPUB3
- **msmtp** — envio do EPUB para `@kindle.com`
- **Polling bash** — detecta mudanças nos arquivos `.md` a cada 5s
- **Docker Compose** — orquestra tudo junto
- **GitHub Codespaces** — ambiente de desenvolvimento

## Estrutura

kineObs/

├── docker-compose.yml

├── .env.example              ← copie para .env e preencha

├── obsidian-data/

│   ├── config/               ← configurações do Obsidian

│   └── vaults/

│       └── Faculdade/

│           ├── Resumos/      ← pasta monitorada ✅

│           └── CheatSheets/  ← pasta monitorada ✅

├── kindle-sender/

│   ├── Dockerfile

│   ├── watch.sh              ← loop de polling a cada 5s

│   ├── convert-and-send.sh   ← pandoc + msmtp

│   ├── msmtprc.example       ← copie para msmtprc e preencha

│   └── msmtprc               ← ⚠️ ignorado pelo git (credenciais)

└── workspace/                ← volume do container opencode

## Como usar

### 1. Configurar credenciais

```bash
cp .env.example .env
cp kindle-sender/msmtprc.example kindle-sender/msmtprc
```

Edite `.env`:
KINDLE_EMAIL=seu_usuario@kindle.com

FROM_EMAIL=seu_email@gmail.com

Edite `kindle-sender/msmtprc` com seu Gmail e senha de app Google.

### 2. Subir os containers

```bash
docker compose up -d
docker logs -f kineobs-kindle-sender
```

### 3. Criar uma nota para enviar ao Kindle

Adicione `kindle: true` no frontmatter da nota:

```markdown
---
title: "Anatomia - Cabeça e Pescoço"
kindle: true
---

# Conteúdo do resumo...
```

Salve em `Resumos/` ou `CheatSheets/` — em até 10s o EPUB chega no Kindle.

## Pré-requisitos externos

- **Senha de app Google**: myaccount.google.com/apppasswords
- **E-mail aprovado na Amazon**: Amazon → Conta → Conteúdo e dispositivos
  → Preferências → Configurações de documento pessoal → Lista de e-mails aprovados

## Status do projeto

### ✅ Concluído
- [x] Estrutura de pastas e arquivos
- [x] Dockerfile com Pandoc + msmtp
- [x] Script de conversão MD → EPUB
- [x] Envio via msmtp para @kindle.com
- [x] Credenciais configuradas (.env + msmtprc)
- [x] Build do container funcionando
- [x] Obsidian Remote rodando no Codespaces

### 🚧 Próximo passo (onde paramos)
- [ ] **Corrigir detecção de mudanças** — inotify não funciona em bind mounts
      do Codespaces; implementamos polling bash a cada 5s como alternativa,
      mas o rebuild com a correção ainda não foi testado até o final
- [ ] Testar envio end-to-end: nota salva → EPUB gerado → chega no Kindle
- [ ] Autorizar `luispizzirani.ed@gmail.com` na lista da Amazon (confirmar)

### 🔜 Futuro
- [ ] Suporte a imagens nos EPUBs
- [ ] CSS customizado para melhor formatação no Kindle
- [ ] Notificação de confirmação após envio
- [ ] Syncthing para sincronizar vault com iPhone