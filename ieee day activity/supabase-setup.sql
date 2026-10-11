-- Run this once in Supabase: SQL Editor -> New query -> paste -> Run
create table games(
  pin text primary key,
  state text not null default 'lobby',
  q int not null default -1,
  n int not null default 0,
  q_start timestamptz,
  created_at timestamptz not null default now());
create table players(
  id uuid primary key default gen_random_uuid(),
  pin text not null references games(pin) on delete cascade,
  name text not null check (char_length(name) between 1 and 16),
  score int not null default 0, streak int not null default 0, gain int not null default 0,
  ok boolean not null default false, answered boolean not null default false, rank int not null default 0);
create index on players(pin);
create table answers(
  pin text not null, q int not null,
  player_id uuid not null references players(id) on delete cascade,
  k int not null check (k between 0 and 3),
  created_at timestamptz not null default now(),
  primary key (pin, q, player_id));

alter table games enable row level security;
alter table players enable row level security;
alter table answers enable row level security;
create policy open_games on games for all to anon using (true) with check (true);
create policy open_players on players for all to anon using (true) with check (true);
create policy open_answers on answers for all to anon using (true) with check (true);

create or replace function start_question(p_pin text, p_q int) returns void language sql as $$
  update games set state='question', q=p_q, q_start=now(),
    n=(select count(*) from players where pin=p_pin) where pin=p_pin;
$$;

create or replace function score_question(p_pin text, p_q int, p_correct int, p_secs int)
returns json language plpgsql as $$
begin
  with s as (
    select p.id, (a.player_id is not null) as answered,
      coalesce(a.k = p_correct, false) as ok,
      case when coalesce(a.k = p_correct, false)
        then round(1000 * (1 - least(1, greatest(0, extract(epoch from (a.created_at - g.q_start))) / p_secs) / 2))::int
             + least(p.streak, 5) * 100
        else 0 end as gain
    from players p
    join games g on g.pin = p.pin
    left join answers a on a.player_id = p.id and a.q = p_q
    where p.pin = p_pin)
  update players p set score = p.score + s.gain, gain = s.gain, ok = s.ok, answered = s.answered,
    streak = case when s.ok then p.streak + 1 else 0 end
  from s where p.id = s.id;

  update players p set rank = r.rn
  from (select id, row_number() over (order by score desc, name) as rn from players where pin = p_pin) r
  where p.id = r.id;

  update games set state = 'result' where pin = p_pin;

  return (select json_agg(x.c order by x.k) from (
    select gs.k, count(a.k)::int as c from generate_series(0,3) gs(k)
    left join answers a on a.pin = p_pin and a.q = p_q and a.k = gs.k group by gs.k) x);
end $$;
