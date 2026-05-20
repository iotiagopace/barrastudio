-- Barra Studio Criativo CMS
-- Execute este arquivo no SQL Editor do Supabase.

create extension if not exists pgcrypto;

create table if not exists public.cms_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create or replace function public.is_cms_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.cms_admins
    where user_id = auth.uid()
  );
$$;

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  slug text not null unique,
  category text,
  project_type text,
  project_status text,
  status text not null default 'draft' check (status in ('published', 'draft')),
  is_featured boolean not null default false,
  total_area text,
  location text,
  year text,
  client_profile text,
  scope text,
  concept text,
  materials text,
  needs_program text,
  challenges_solutions text,
  team text,
  cover_image_url text,
  gallery_images jsonb not null default '[]'::jsonb,
  before_image_url text,
  after_image_url text,
  youtube_videos jsonb not null default '[]'::jsonb,
  display_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.site_settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create index if not exists projects_public_idx
  on public.projects (status, is_featured desc, display_order asc, created_at desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists projects_set_updated_at on public.projects;
create trigger projects_set_updated_at
before update on public.projects
for each row execute function public.set_updated_at();

drop trigger if exists site_settings_set_updated_at on public.site_settings;
create trigger site_settings_set_updated_at
before update on public.site_settings
for each row execute function public.set_updated_at();

alter table public.projects enable row level security;
alter table public.cms_admins enable row level security;
alter table public.site_settings enable row level security;

drop policy if exists "Public can read published projects" on public.projects;
create policy "Public can read published projects"
on public.projects for select
to anon, authenticated
using (status = 'published' or public.is_cms_admin());

drop policy if exists "Admins can insert projects" on public.projects;
create policy "Admins can insert projects"
on public.projects for insert
to authenticated
with check (public.is_cms_admin());

drop policy if exists "Admins can update projects" on public.projects;
create policy "Admins can update projects"
on public.projects for update
to authenticated
using (public.is_cms_admin())
with check (public.is_cms_admin());

drop policy if exists "Admins can delete projects" on public.projects;
create policy "Admins can delete projects"
on public.projects for delete
to authenticated
using (public.is_cms_admin());

drop policy if exists "Admins can read admin list" on public.cms_admins;
create policy "Admins can read admin list"
on public.cms_admins for select
to authenticated
using (public.is_cms_admin());

drop policy if exists "Public can read public site settings" on public.site_settings;
create policy "Public can read public site settings"
on public.site_settings for select
to anon, authenticated
using (key = 'home_images' or public.is_cms_admin());

drop policy if exists "Admins can insert site settings" on public.site_settings;
create policy "Admins can insert site settings"
on public.site_settings for insert
to authenticated
with check (public.is_cms_admin());

drop policy if exists "Admins can update site settings" on public.site_settings;
create policy "Admins can update site settings"
on public.site_settings for update
to authenticated
using (public.is_cms_admin())
with check (public.is_cms_admin());

drop policy if exists "Admins can delete site settings" on public.site_settings;
create policy "Admins can delete site settings"
on public.site_settings for delete
to authenticated
using (public.is_cms_admin());

-- Storage: crie um bucket publico chamado project-images antes de aplicar estas policies,
-- ou execute:
insert into storage.buckets (id, name, public)
values ('project-images', 'project-images', true)
on conflict (id) do update set public = excluded.public;

drop policy if exists "Public can read project images" on storage.objects;
create policy "Public can read project images"
on storage.objects for select
to anon, authenticated
using (bucket_id = 'project-images');

drop policy if exists "Admins can upload project images" on storage.objects;
create policy "Admins can upload project images"
on storage.objects for insert
to authenticated
with check (bucket_id = 'project-images' and public.is_cms_admin());

drop policy if exists "Admins can update project images" on storage.objects;
create policy "Admins can update project images"
on storage.objects for update
to authenticated
using (bucket_id = 'project-images' and public.is_cms_admin())
with check (bucket_id = 'project-images' and public.is_cms_admin());

drop policy if exists "Admins can delete project images" on storage.objects;
create policy "Admins can delete project images"
on storage.objects for delete
to authenticated
using (bucket_id = 'project-images' and public.is_cms_admin());

-- Depois de criar o usuario admin no Supabase Auth, substitua pelo UUID dele:
-- insert into public.cms_admins (user_id) values ('UUID_DO_USUARIO_ADMIN');
