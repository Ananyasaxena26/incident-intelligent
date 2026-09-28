-- Incident Intelligence demo database setup.
-- Run this in Supabase Dashboard -> SQL Editor before starting the app.

create extension if not exists pgcrypto;

create table if not exists public.incidents (
  id uuid primary key default gen_random_uuid(),
  incident_id text not null unique,
  title text not null,
  description text not null default '',
  severity text not null check (severity in ('critical', 'high', 'medium', 'low')),
  status text not null default 'open' check (status in ('open', 'investigating', 'resolved', 'closed')),
  location text not null default 'Unknown',
  organization_id uuid,
  reporter_id uuid,
  assignee_id uuid,
  timestamp timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  resolved_at timestamptz,
  deleted_at timestamptz
);

create index if not exists incidents_created_at_idx
  on public.incidents (created_at desc);

create index if not exists incidents_updated_at_idx
  on public.incidents (updated_at desc);

-- Demo-only policies. Replace these with authenticated, organization-scoped
-- policies before using the application with real incident data.
alter table public.incidents enable row level security;

drop policy if exists "demo read incidents" on public.incidents;
drop policy if exists "demo insert incidents" on public.incidents;
drop policy if exists "demo update incidents" on public.incidents;

create policy "demo read incidents"
  on public.incidents for select
  using (true);

create policy "demo insert incidents"
  on public.incidents for insert
  with check (true);

create policy "demo update incidents"
  on public.incidents for update
  using (true)
  with check (true);

-- Optional seed data. The on-conflict clause makes this safe to run again.
insert into public.incidents
  (incident_id, title, description, severity, status, location, timestamp)
values
  ('INC-20260925-090001', 'Database connection timeouts',
   'Several API requests are timing out while connecting to the primary database.',
   'critical', 'investigating', 'Data Center A', now() - interval '2 hours'),
  ('INC-20260925-090002', 'Network switch packet loss',
   'Intermittent packet loss is affecting services in the north wing.',
   'high', 'open', 'North Wing', now() - interval '1 hour'),
  ('INC-20260925-090003', 'Backup completed successfully',
   'The scheduled storage backup completed without errors.',
   'low', 'resolved', 'Data Center B', now() - interval '30 minutes')
on conflict (incident_id) do nothing;
