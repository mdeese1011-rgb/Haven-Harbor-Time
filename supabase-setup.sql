-- ════════════════════════════════════════
--  H+H Time Tracker — Supabase Setup SQL
--  Run this in: Supabase → SQL Editor → New Query
-- ════════════════════════════════════════

-- 1. PROJECTS TABLE
create table if not exists projects (
  id         uuid default gen_random_uuid() primary key,
  name       text not null,
  client     text,
  created_at timestamptz default now()
);

-- 2. TIME ENTRIES TABLE
create table if not exists time_entries (
  id            uuid default gen_random_uuid() primary key,
  user_id       uuid references auth.users(id) on delete cascade,
  designer_name text not null,
  date          text not null,
  project_name  text not null,
  client_name   text,
  category      text not null,
  bucket        text not null,
  bucket_class  text not null,
  hours         numeric(6,2) not null,
  notes         text,
  method        text default 'manual',
  created_at    timestamptz default now()
);

-- 3. SECURITY: Enable Row Level Security
alter table projects     enable row level security;
alter table time_entries enable row level security;

-- 4. PROJECTS POLICIES
--    Anyone logged in can read projects
create policy "Anyone can read projects"
  on projects for select
  using (auth.role() = 'authenticated');

--    Anyone logged in can insert projects
create policy "Anyone can insert projects"
  on projects for insert
  with check (auth.role() = 'authenticated');

-- 5. TIME ENTRIES POLICIES
--    Users can only read their own entries
create policy "Users read own entries"
  on time_entries for select
  using (auth.uid() = user_id);

--    Users can only insert their own entries
create policy "Users insert own entries"
  on time_entries for insert
  with check (auth.uid() = user_id);

--    Users can only delete their own entries
create policy "Users delete own entries"
  on time_entries for delete
  using (auth.uid() = user_id);

-- 6. MANAGER POLICY: Allow manager to read ALL entries
--    Replace 'manager@hhstudio.com' with your actual manager email
create policy "Manager reads all entries"
  on time_entries for select
  using (
    auth.uid() = user_id
    OR
    (select email from auth.users where id = auth.uid()) = 'manager@hhstudio.com'
  );

-- 7. SEED STARTER PROJECTS (optional — edit these)
insert into projects (name, client) values
  ('Smith Residence',  'Smith'),
  ('Johnson Condo',    'Johnson'),
  ('Levy Office',      'Levy')
on conflict do nothing;

-- ════════════════════════════════════════
--  DONE. Your database is ready.
-- ════════════════════════════════════════
