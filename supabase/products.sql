-- =============================================================
-- Database NovaMart: categories, brands, products
-- Khớp với các model trong src/app/ecommerce/model/
--   category_product.ts → bảng public.categories
--   brands.ts           → bảng public.brands
--   product.ts          → bảng public.products
-- Chạy toàn bộ file này trong Supabase Dashboard → SQL Editor → Run
-- Có thể chạy lại nhiều lần mà không lỗi.
-- =============================================================


-- -------------------------------------------------------------
-- 1. Bảng danh mục (categories)
-- -------------------------------------------------------------
create table if not exists public.categories (
  id           bigint generated always as identity primary key,
  name         text        not null,
  slug         text        not null unique,
  parent_id    bigint      references public.categories (id) on delete set null,
  description  text,
  image        text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);


-- -------------------------------------------------------------
-- 2. Bảng thương hiệu (brands)
-- -------------------------------------------------------------
create table if not exists public.brands (
  id           bigint generated always as identity primary key,
  name         text        not null,
  slug         text        not null unique,
  logo         text,
  description  text,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);


-- -------------------------------------------------------------
-- 3. Bảng sản phẩm (products)
-- -------------------------------------------------------------
create table if not exists public.products (
  id              bigint generated always as identity primary key,
  title_prod      text        not null,
  code            text        not null unique,
  category_id     bigint,
  brand_id        bigint,
  price           numeric     not null default 0,
  discount        numeric     not null default 0,
  discount_unit   text        not null default 'PERCENT'
                  check (discount_unit in ('PERCENT', 'PRICE')),
  qty             int         not null default 0,
  specifications  text,
  description     text,
  img_1           text,
  img_2           text,
  img_3           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

-- Khóa ngoại products → categories / brands
-- (viết dạng này để chạy được cả khi bảng products đã tạo từ trước)
do $$
begin
  if not exists (select 1 from pg_constraint where conname = 'products_category_id_fkey') then
    alter table public.products
      add constraint products_category_id_fkey
      foreign key (category_id) references public.categories (id) on delete set null;
  end if;

  if not exists (select 1 from pg_constraint where conname = 'products_brand_id_fkey') then
    alter table public.products
      add constraint products_brand_id_fkey
      foreign key (brand_id) references public.brands (id) on delete set null;
  end if;
end $$;

create index if not exists products_category_id_idx on public.products (category_id);
create index if not exists products_brand_id_idx    on public.products (brand_id);


-- -------------------------------------------------------------
-- 4. Quyền truy cập: cho phép API (publishable / anon key) đọc dữ liệu
-- -------------------------------------------------------------
grant usage on schema public to anon, authenticated;
grant select on public.categories, public.brands, public.products to anon, authenticated;

alter table public.categories enable row level security;
alter table public.brands     enable row level security;
alter table public.products   enable row level security;

drop policy if exists "Public read categories" on public.categories;
create policy "Public read categories" on public.categories
  for select to anon, authenticated using (true);

drop policy if exists "Public read brands" on public.brands;
create policy "Public read brands" on public.brands
  for select to anon, authenticated using (true);

drop policy if exists "Public read products" on public.products;
create policy "Public read products" on public.products
  for select to anon, authenticated using (true);


-- -------------------------------------------------------------
-- 5. Dữ liệu mẫu
-- -------------------------------------------------------------
insert into public.categories (name, slug, description) values
  ('Âm thanh',   'am-thanh',   'Tai nghe, loa, thiết bị âm thanh'),
  ('Đồng hồ',    'dong-ho',    'Đồng hồ thông minh và phụ kiện'),
  ('Phụ kiện',   'phu-kien',   'Bàn phím, chuột, phụ kiện máy tính'),
  ('Nhiếp ảnh',  'nhiep-anh',  'Máy ảnh và phụ kiện chụp ảnh')
on conflict (slug) do nothing;

insert into public.brands (name, slug, description) values
  ('SoundWave', 'soundwave', 'Thương hiệu thiết bị âm thanh'),
  ('Pulse',     'pulse',     'Thương hiệu đồng hồ thông minh'),
  ('KeyNova',   'keynova',   'Thương hiệu bàn phím cơ'),
  ('RetroCam',  'retrocam',  'Thương hiệu máy ảnh lấy liền')
on conflict (slug) do nothing;

insert into public.products
  (title_prod, code, category_id, brand_id, price, discount, discount_unit, qty, description, img_1)
values
  ('Tai nghe chống ồn Studio Pro X', 'SP-001',
   (select id from public.categories where slug = 'am-thanh'),
   (select id from public.brands     where slug = 'soundwave'),
   2490000, 10, 'PERCENT', 42,
   'Tai nghe over-ear chống ồn chủ động, pin 40 giờ.',
   'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600&q=80'),
  ('Đồng hồ thông minh Pulse Fit 5', 'SP-002',
   (select id from public.categories where slug = 'dong-ho'),
   (select id from public.brands     where slug = 'pulse'),
   3850000, 300000, 'PRICE', 18,
   'Theo dõi sức khỏe, GPS, chống nước 5ATM.',
   'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&q=80'),
  ('Bàn phím cơ không dây KeyNova K8', 'SP-003',
   (select id from public.categories where slug = 'phu-kien'),
   (select id from public.brands     where slug = 'keynova'),
   1690000, 0, 'PERCENT', 5,
   'Switch hot-swap, kết nối Bluetooth / 2.4G / USB-C.',
   'https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=600&q=80'),
  ('Máy ảnh lấy liền RetroCam Mini', 'SP-004',
   (select id from public.categories where slug = 'nhiep-anh'),
   (select id from public.brands     where slug = 'retrocam'),
   2150000, 15, 'PERCENT', 27,
   'Máy ảnh in ảnh lấy liền phong cách retro.',
   'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=600&q=80')
on conflict (code) do update
  set category_id = excluded.category_id,
      brand_id    = excluded.brand_id;


-- -------------------------------------------------------------
-- 6. Báo cho API (PostgREST) tải lại danh sách bảng ngay
-- -------------------------------------------------------------
notify pgrst, 'reload schema';
