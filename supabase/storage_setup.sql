-- Run this in the Supabase SQL Editor for Her Little World.
-- Private bucket: authenticated users may read photos and manifest.
-- Uploads are performed by the project owner in the Supabase Dashboard.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'her-little-world-photos',
  'her-little-world-photos',
  false,
  10485760,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
set public = false,
    file_size_limit = 10485760,
    allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Authenticated users can read Her Little World photos"
on storage.objects;

create policy "Authenticated users can read Her Little World photos"
on storage.objects
for select
to authenticated
using (bucket_id = 'her-little-world-photos');
