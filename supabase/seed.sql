-- Demo seed data aligned with the in-app mocked restaurant.

INSERT INTO public.subscription_plans
  (name, price_monthly, price_yearly, max_branches, max_staff, features)
VALUES
  ('Starter', 4999, 49999, 1, 5, '{"loyalty": false, "ai": false, "campaigns": false}'),
  ('Growth', 9999, 99999, 3, 15, '{"loyalty": true, "ai": false, "campaigns": true}'),
  ('Enterprise', 24999, 249999, 50, 100, '{"loyalty": true, "ai": true, "campaigns": true}')
ON CONFLICT (name) DO UPDATE SET
  price_monthly = EXCLUDED.price_monthly,
  price_yearly = EXCLUDED.price_yearly,
  max_branches = EXCLUDED.max_branches,
  max_staff = EXCLUDED.max_staff,
  features = EXCLUDED.features;

INSERT INTO public.tenants (name, slug, owner_email, subscription_plan_id, subscription_status)
VALUES (
  'Demo Foods',
  'demo-foods',
  'owner@demofood.com',
  (SELECT id FROM public.subscription_plans WHERE name = 'Growth'),
  'active'
)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  owner_email = EXCLUDED.owner_email,
  subscription_plan_id = EXCLUDED.subscription_plan_id,
  subscription_status = EXCLUDED.subscription_status;

INSERT INTO public.restaurants
  (tenant_id, name, slug, description, cuisine_type, primary_color, secondary_color, currency, banner_url, is_verified)
VALUES (
  (SELECT id FROM public.tenants WHERE slug = 'demo-foods'),
  'Demo Burger',
  'demo-burger',
  'White-label burger restaurant used by RestaurantOS AI.',
  ARRAY['burgers','fast-food'],
  '#FF6B35',
  '#F7F3EC',
  'PKR',
  'https://images.unsplash.com/photo-1550547660-d9450f859349?auto=format&fit=crop&w=1600&q=80',
  TRUE
)
ON CONFLICT (tenant_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  cuisine_type = EXCLUDED.cuisine_type,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  banner_url = EXCLUDED.banner_url;

INSERT INTO public.branches
  (tenant_id, restaurant_id, name, address, city, latitude, longitude, opening_hours,
   is_delivery_available, is_pickup_available, is_dinein_available, delivery_fee,
   estimated_delivery_min, estimated_delivery_max, min_order_amount)
VALUES (
  (SELECT id FROM public.tenants WHERE slug = 'demo-foods'),
  (SELECT id FROM public.restaurants WHERE slug = 'demo-burger'),
  'Demo Burger - Gulshan',
  'Block 5, Gulshan-e-Iqbal',
  'Karachi',
  24.9275,
  67.0960,
  '{
    "monday": {"open": "09:00", "close": "23:59", "is_closed": false},
    "tuesday": {"open": "09:00", "close": "23:59", "is_closed": false},
    "wednesday": {"open": "09:00", "close": "23:59", "is_closed": false},
    "thursday": {"open": "09:00", "close": "23:59", "is_closed": false},
    "friday": {"open": "09:00", "close": "00:30", "is_closed": false},
    "saturday": {"open": "10:00", "close": "00:30", "is_closed": false},
    "sunday": {"open": "10:00", "close": "23:00", "is_closed": false}
  }',
  TRUE,
  TRUE,
  TRUE,
  99,
  25,
  40,
  500
)
ON CONFLICT (restaurant_id, name) DO UPDATE SET
  address = EXCLUDED.address,
  opening_hours = EXCLUDED.opening_hours,
  is_delivery_available = EXCLUDED.is_delivery_available,
  is_pickup_available = EXCLUDED.is_pickup_available,
  is_dinein_available = EXCLUDED.is_dinein_available,
  delivery_fee = EXCLUDED.delivery_fee,
  estimated_delivery_min = EXCLUDED.estimated_delivery_min,
  estimated_delivery_max = EXCLUDED.estimated_delivery_max;

INSERT INTO public.categories (tenant_id, restaurant_id, name, sort_order)
VALUES
  ((SELECT id FROM public.tenants WHERE slug = 'demo-foods'), (SELECT id FROM public.restaurants WHERE slug = 'demo-burger'), 'Burgers', 1),
  ((SELECT id FROM public.tenants WHERE slug = 'demo-foods'), (SELECT id FROM public.restaurants WHERE slug = 'demo-burger'), 'Drinks', 2),
  ((SELECT id FROM public.tenants WHERE slug = 'demo-foods'), (SELECT id FROM public.restaurants WHERE slug = 'demo-burger'), 'Sides', 3),
  ((SELECT id FROM public.tenants WHERE slug = 'demo-foods'), (SELECT id FROM public.restaurants WHERE slug = 'demo-burger'), 'Combos', 4)
ON CONFLICT (tenant_id, restaurant_id, name) DO UPDATE SET
  sort_order = EXCLUDED.sort_order;

INSERT INTO public.menu_items
  (tenant_id, restaurant_id, branch_id, category_id, name, description, base_price,
   discounted_price, preparation_time_min, image_url, is_best_seller, is_featured,
   is_new, is_vegetarian, is_spicy, spice_level, calories, total_orders, average_rating)
VALUES
  ((SELECT id FROM public.tenants WHERE slug = 'demo-foods'), (SELECT id FROM public.restaurants WHERE slug = 'demo-burger'), (SELECT id FROM public.branches WHERE name = 'Demo Burger - Gulshan'), (SELECT id FROM public.categories WHERE name = 'Burgers'), 'Classic Smash Burger', 'Smashed beef patty, cheddar, house sauce, pickles, seeded bun.', 599, 549, 12, 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=900&q=80', TRUE, TRUE, FALSE, FALSE, FALSE, 0, 640, 284, 4.9),
  ((SELECT id FROM public.tenants WHERE slug = 'demo-foods'), (SELECT id FROM public.restaurants WHERE slug = 'demo-burger'), (SELECT id FROM public.branches WHERE name = 'Demo Burger - Gulshan'), (SELECT id FROM public.categories WHERE name = 'Burgers'), 'Double Cheese Burger', 'Two patties, double cheddar, caramelized onion, smoky mayo.', 749, NULL, 15, 'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?auto=format&fit=crop&w=900&q=80', FALSE, FALSE, FALSE, FALSE, FALSE, 0, 790, 192, 4.7),
  ((SELECT id FROM public.tenants WHERE slug = 'demo-foods'), (SELECT id FROM public.restaurants WHERE slug = 'demo-burger'), (SELECT id FROM public.branches WHERE name = 'Demo Burger - Gulshan'), (SELECT id FROM public.categories WHERE name = 'Burgers'), 'Spicy Zinger Stack', 'Crispy chicken, jalapeno relish, lettuce, chili garlic glaze.', 699, NULL, 14, 'https://images.unsplash.com/photo-1615297928064-24977384d0da?auto=format&fit=crop&w=900&q=80', TRUE, FALSE, FALSE, FALSE, TRUE, 3, 720, 241, 4.8),
  ((SELECT id FROM public.tenants WHERE slug = 'demo-foods'), (SELECT id FROM public.restaurants WHERE slug = 'demo-burger'), (SELECT id FROM public.branches WHERE name = 'Demo Burger - Gulshan'), (SELECT id FROM public.categories WHERE name = 'Burgers'), 'Garden Crunch Burger', 'Crispy vegetable patty, herbed yogurt, tomato, fresh greens.', 529, NULL, 11, 'https://images.unsplash.com/photo-1520072959219-c595dc870360?auto=format&fit=crop&w=900&q=80', FALSE, FALSE, TRUE, TRUE, FALSE, 0, 510, 76, 4.5),
  ((SELECT id FROM public.tenants WHERE slug = 'demo-foods'), (SELECT id FROM public.restaurants WHERE slug = 'demo-burger'), (SELECT id FROM public.branches WHERE name = 'Demo Burger - Gulshan'), (SELECT id FROM public.categories WHERE name = 'Combos'), 'Loaded Duo Combo', 'Two smash burgers, large fries, onion rings, and two drinks.', 1599, 1399, 18, 'https://images.unsplash.com/photo-1610614819513-58e34989848b?auto=format&fit=crop&w=900&q=80', FALSE, TRUE, FALSE, FALSE, FALSE, 0, NULL, 118, 4.6),
  ((SELECT id FROM public.tenants WHERE slug = 'demo-foods'), (SELECT id FROM public.restaurants WHERE slug = 'demo-burger'), (SELECT id FROM public.branches WHERE name = 'Demo Burger - Gulshan'), (SELECT id FROM public.categories WHERE name = 'Sides'), 'Crispy Fries', 'Skin-on fries tossed with sea salt and parsley.', 199, NULL, 8, 'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?auto=format&fit=crop&w=900&q=80', TRUE, FALSE, FALSE, TRUE, FALSE, 0, 330, 331, 4.8),
  ((SELECT id FROM public.tenants WHERE slug = 'demo-foods'), (SELECT id FROM public.restaurants WHERE slug = 'demo-burger'), (SELECT id FROM public.branches WHERE name = 'Demo Burger - Gulshan'), (SELECT id FROM public.categories WHERE name = 'Sides'), 'Onion Rings', 'Golden rings with smoked paprika dip.', 249, NULL, 10, 'https://images.unsplash.com/photo-1639024471283-03518883512d?auto=format&fit=crop&w=900&q=80', FALSE, FALSE, FALSE, TRUE, FALSE, 0, 370, 121, 4.4),
  ((SELECT id FROM public.tenants WHERE slug = 'demo-foods'), (SELECT id FROM public.restaurants WHERE slug = 'demo-burger'), (SELECT id FROM public.branches WHERE name = 'Demo Burger - Gulshan'), (SELECT id FROM public.categories WHERE name = 'Drinks'), 'Thick Shake', 'Vanilla bean shake with caramel drizzle.', 299, NULL, 5, 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=900&q=80', FALSE, FALSE, FALSE, TRUE, FALSE, 0, 420, 166, 4.6)
ON CONFLICT (tenant_id, restaurant_id, name) DO UPDATE SET
  description = EXCLUDED.description,
  base_price = EXCLUDED.base_price,
  discounted_price = EXCLUDED.discounted_price,
  preparation_time_min = EXCLUDED.preparation_time_min,
  image_url = EXCLUDED.image_url,
  is_best_seller = EXCLUDED.is_best_seller,
  is_featured = EXCLUDED.is_featured,
  is_new = EXCLUDED.is_new,
  is_vegetarian = EXCLUDED.is_vegetarian,
  is_spicy = EXCLUDED.is_spicy,
  total_orders = EXCLUDED.total_orders,
  average_rating = EXCLUDED.average_rating;

INSERT INTO public.coupons
  (tenant_id, restaurant_id, code, discount_type, discount_value,
   min_order_amount, max_discount_amount, max_uses, per_user_limit, valid_from, valid_until)
VALUES
  ((SELECT id FROM public.tenants WHERE slug = 'demo-foods'), (SELECT id FROM public.restaurants WHERE slug = 'demo-burger'), 'WELCOME20', 'percentage', 20, 500, 500, 100, 1, NOW(), NOW() + INTERVAL '30 days'),
  ((SELECT id FROM public.tenants WHERE slug = 'demo-foods'), (SELECT id FROM public.restaurants WHERE slug = 'demo-burger'), 'COMBO150', 'fixed', 150, 1200, 150, 100, 1, NOW(), NOW() + INTERVAL '30 days')
ON CONFLICT (tenant_id, restaurant_id, code) DO UPDATE SET
  discount_type = EXCLUDED.discount_type,
  discount_value = EXCLUDED.discount_value,
  min_order_amount = EXCLUDED.min_order_amount,
  max_discount_amount = EXCLUDED.max_discount_amount,
  valid_until = EXCLUDED.valid_until,
  is_active = TRUE;
