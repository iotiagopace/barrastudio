-- Adiciona suporte para editar as imagens fixas da home pelo painel.
-- Execute no SQL Editor do Supabase se o schema.sql ja foi aplicado antes desta funcionalidade.

create table if not exists public.site_settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

drop trigger if exists site_settings_set_updated_at on public.site_settings;
create trigger site_settings_set_updated_at
before update on public.site_settings
for each row execute function public.set_updated_at();

alter table public.site_settings enable row level security;

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

insert into public.site_settings (key, value)
values (
  'home_images',
  '{
    "hero_main": "assets/barra-page-02.jpg",
    "hero_side": "assets/barra-page-07.jpg",
    "about": "assets/barra-page-03.jpg",
    "area_residential": "assets/barra-page-12.jpg",
    "area_commercial": "assets/barra-page-18.jpg",
    "area_restaurants": "assets/barra-page-17.jpg",
    "area_health": "assets/barra-page-08.jpg",
    "team_rafaela": "assets/barra-page-09.jpg",
    "team_thais": "assets/barra-page-10.jpg"
  }'::jsonb
)
on conflict (key) do nothing;
