-- Box to Box database setup.
-- Paste this whole file into Supabase > SQL Editor > New query, then click Run.
-- Safe to run again: it only replaces its own security rules, never your data.

-- Usernames, one per account.
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text not null check (username ~ '^[A-Za-z0-9_]{3,16}$'),
  created_at timestamptz not null default now()
);
create unique index if not exists profiles_username_unique on public.profiles (lower(username));

-- One row per player, per game, per matchday (the result is stored as it is in the app).
create table if not exists public.results (
  user_id uuid not null references auth.users (id) on delete cascade,
  game text not null check (game in ('mm','tt','c10','var')),
  day integer not null check (day > 0),
  data jsonb not null,
  created_at timestamptz not null default now(),
  primary key (user_id, game, day)
);

-- Friend requests. Accepted = friends.
create table if not exists public.friendships (
  requester uuid not null references auth.users (id) on delete cascade,
  addressee uuid not null references auth.users (id) on delete cascade,
  status text not null default 'pending' check (status in ('pending','accepted')),
  created_at timestamptz not null default now(),
  primary key (requester, addressee),
  check (requester <> addressee)
);
-- Only one request per pair, whichever direction.
create unique index if not exists friendships_pair on public.friendships (least(requester, addressee), greatest(requester, addressee));

-- True when the logged-in player and "other" are accepted friends.
create or replace function public.is_friend(other uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.friendships f
    where f.status = 'accepted'
      and ((f.requester = auth.uid() and f.addressee = other) or (f.addressee = auth.uid() and f.requester = other))
  );
$$;

alter table public.profiles enable row level security;
alter table public.results enable row level security;
alter table public.friendships enable row level security;

-- Profiles: logged-in players can look up usernames (to add friends); you only edit your own.
drop policy if exists "profiles readable by players" on public.profiles;
create policy "profiles readable by players" on public.profiles for select to authenticated using (true);
drop policy if exists "players create own profile" on public.profiles;
create policy "players create own profile" on public.profiles for insert to authenticated with check (auth.uid() = id);
drop policy if exists "players update own profile" on public.profiles;
create policy "players update own profile" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);

-- Results: you see yours and your accepted friends'; you only write your own.
drop policy if exists "read own and friends results" on public.results;
create policy "read own and friends results" on public.results for select to authenticated using (auth.uid() = user_id or public.is_friend(user_id));
drop policy if exists "players add own results" on public.results;
create policy "players add own results" on public.results for insert to authenticated with check (auth.uid() = user_id);
drop policy if exists "players update own results" on public.results;
create policy "players update own results" on public.results for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Friendships: both sides see the request; you can only send as yourself;
-- only the person asked can accept; either side can cancel, decline or unfriend.
drop policy if exists "see own friendships" on public.friendships;
create policy "see own friendships" on public.friendships for select to authenticated using (auth.uid() in (requester, addressee));
drop policy if exists "send requests" on public.friendships;
create policy "send requests" on public.friendships for insert to authenticated with check (auth.uid() = requester and status = 'pending');
drop policy if exists "accept requests" on public.friendships;
create policy "accept requests" on public.friendships for update to authenticated using (auth.uid() = addressee) with check (auth.uid() = addressee and status = 'accepted');
drop policy if exists "remove friendships" on public.friendships;
create policy "remove friendships" on public.friendships for delete to authenticated using (auth.uid() in (requester, addressee));
