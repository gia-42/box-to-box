-- Box to Box: puzzles from Rodada 2 on were reshuffled. Clear results saved for them before the change (run once in Supabase > SQL Editor). Rodada 1 is kept.
delete from public.results where day>=2 and coalesce((data->>'s')::int,0)<5;
