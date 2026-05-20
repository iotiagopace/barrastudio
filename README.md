# Barra Studio Criativo — Site institucional com CMS Supabase

Arquivos principais:

- `index.html`: site institucional e portfólio público.
- `admin.html`: painel CMS para criar, editar, publicar, rascunhar e remover projetos.
- `supabase-config.js`: configuração pública do Supabase usada no frontend.
- `supabase/schema.sql`: tabela, bucket e políticas RLS.
- `supabase/add-home-images-settings.sql`: migração para habilitar edição das imagens fixas da home.
- `assets/`: imagens institucionais do site.

## Configuração do Supabase

1. Crie um projeto no Supabase.
2. No SQL Editor, execute o arquivo `supabase/schema.sql`.
3. Em Authentication, crie um usuário admin com e-mail e senha.
4. Copie o UUID desse usuário em Authentication > Users.
5. Execute no SQL Editor:

```sql
insert into public.cms_admins (user_id)
values ('UUID_DO_USUARIO_ADMIN');
```

6. Edite `supabase-config.js`:

```js
window.BARRA_SUPABASE = {
  url: "https://SEU-PROJETO.supabase.co",
  anonKey: "SUA_SUPABASE_ANON_KEY",
  imageBucket: "project-images"
};
```

`SUPABASE_URL` é a Project URL. `SUPABASE_ANON_KEY` é a anon public key em Project Settings > API.

## Segurança

O painel está publicado no frontend, então a segurança não depende de esconder código. A proteção fica no Supabase:

- Visitantes anônimos só conseguem ler projetos com `status = 'published'`.
- Projetos em `draft` só aparecem para usuários cadastrados em `cms_admins`.
- Criar, editar e excluir projetos exige Supabase Auth e cadastro em `cms_admins`.
- Upload, alteração e exclusão de imagens no bucket `project-images` também exigem admin.
- Recomenda-se deixar o cadastro público de usuários desativado no Supabase Auth.

## Uso do painel

- URL: `/admin.html`
- Login: e-mail e senha do usuário criado no Supabase Auth.

O painel permite cadastrar:

- título, categoria, tipo, área, localização, ano e perfil do cliente;
- status público: publicado ou rascunho;
- status técnico do projeto, como concluído ou em execução;
- destaque, ordem de exibição, escopo, conceito, materiais, programa, desafios e equipe;
- imagem de capa/galeria, antes/depois e vídeos do YouTube.
- imagens fixas da home, preservando o layout e trocando apenas os arquivos exibidos.

## Site público

O `index.html` busca os projetos online no Supabase, sempre ordenando por:

1. projetos em destaque;
2. `display_order`;
3. data de criação.

Se o Supabase ainda não estiver configurado, o site mantém os projetos estáticos de exemplo para não ficar vazio durante o setup.

WhatsApp configurado: 55 17 99757-3824.  
Instagram: @studiocriativo.barra.
