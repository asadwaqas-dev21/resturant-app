-- RestaurantOS AI Supabase schema
-- Run in a Supabase SQL editor or migration after creating the project.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TABLE public.subscription_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  price_monthly NUMERIC(10,2) NOT NULL,
  price_yearly NUMERIC(10,2) NOT NULL,
  max_branches INTEGER DEFAULT 1,
  max_staff INTEGER DEFAULT 5,
  features JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.tenants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  owner_email TEXT NOT NULL,
  subscription_plan_id UUID REFERENCES public.subscription_plans(id),
  subscription_status TEXT DEFAULT 'trial'
    CHECK (subscription_status IN ('trial', 'active', 'suspended', 'cancelled')),
  trial_ends_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.restaurants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  slug TEXT NOT NULL,
  description TEXT,
  cuisine_type TEXT[],
  logo_url TEXT,
  banner_url TEXT,
  primary_color TEXT DEFAULT '#FF6B35',
  secondary_color TEXT DEFAULT '#FFF8F5',
  currency TEXT DEFAULT 'PKR',
  timezone TEXT DEFAULT 'Asia/Karachi',
  is_active BOOLEAN DEFAULT TRUE,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  UNIQUE(tenant_id, slug)
);

CREATE TABLE public.branches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  city TEXT NOT NULL,
  country TEXT DEFAULT 'Pakistan',
  latitude NUMERIC(10,7),
  longitude NUMERIC(10,7),
  phone TEXT,
  email TEXT,
  opening_hours JSONB DEFAULT '{}',
  is_delivery_available BOOLEAN DEFAULT TRUE,
  is_pickup_available BOOLEAN DEFAULT TRUE,
  is_dinein_available BOOLEAN DEFAULT FALSE,
  delivery_radius_km NUMERIC(5,2) DEFAULT 10,
  min_order_amount NUMERIC(10,2) DEFAULT 0,
  delivery_fee NUMERIC(10,2) DEFAULT 0,
  estimated_delivery_min INTEGER DEFAULT 30,
  estimated_delivery_max INTEGER DEFAULT 45,
  is_active BOOLEAN DEFAULT TRUE,
  is_open BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  UNIQUE(restaurant_id, name)
);

CREATE TABLE public.users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  auth_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  tenant_id UUID REFERENCES public.tenants(id),
  restaurant_id UUID REFERENCES public.restaurants(id),
  branch_id UUID REFERENCES public.branches(id),
  full_name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  avatar_url TEXT,
  role TEXT NOT NULL DEFAULT 'customer'
    CHECK (role IN (
      'super_admin','restaurant_owner','manager','cashier',
      'kitchen_staff','delivery_manager','rider','marketing_staff','customer'
    )),
  is_active BOOLEAN DEFAULT TRUE,
  fcm_token TEXT,
  preferred_language TEXT DEFAULT 'en',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

CREATE TABLE public.customers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  total_orders INTEGER DEFAULT 0,
  total_spent NUMERIC(12,2) DEFAULT 0,
  loyalty_points INTEGER DEFAULT 0,
  wallet_balance NUMERIC(10,2) DEFAULT 0,
  referral_code TEXT UNIQUE,
  referred_by UUID REFERENCES public.customers(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, restaurant_id)
);

CREATE TABLE public.addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  label TEXT DEFAULT 'Home' CHECK (label IN ('Home','Work','Other')),
  full_address TEXT NOT NULL,
  city TEXT NOT NULL,
  area TEXT,
  latitude NUMERIC(10,7),
  longitude NUMERIC(10,7),
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  branch_id UUID REFERENCES public.branches(id),
  name TEXT NOT NULL,
  name_ur TEXT,
  name_ar TEXT,
  image_url TEXT,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(tenant_id, restaurant_id, name)
);

CREATE TABLE public.menu_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  branch_id UUID REFERENCES public.branches(id),
  category_id UUID NOT NULL REFERENCES public.categories(id),
  name TEXT NOT NULL,
  name_ur TEXT,
  name_ar TEXT,
  description TEXT,
  base_price NUMERIC(10,2) NOT NULL,
  discounted_price NUMERIC(10,2),
  preparation_time_min INTEGER DEFAULT 15,
  image_url TEXT,
  is_available BOOLEAN DEFAULT TRUE,
  is_featured BOOLEAN DEFAULT FALSE,
  is_best_seller BOOLEAN DEFAULT FALSE,
  is_new BOOLEAN DEFAULT FALSE,
  is_halal BOOLEAN DEFAULT TRUE,
  is_vegetarian BOOLEAN DEFAULT FALSE,
  is_vegan BOOLEAN DEFAULT FALSE,
  is_spicy BOOLEAN DEFAULT FALSE,
  spice_level INTEGER DEFAULT 0 CHECK (spice_level BETWEEN 0 AND 3),
  is_gluten_free BOOLEAN DEFAULT FALSE,
  is_dairy_free BOOLEAN DEFAULT FALSE,
  calories INTEGER,
  sort_order INTEGER DEFAULT 0,
  total_orders INTEGER DEFAULT 0,
  average_rating NUMERIC(3,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  UNIQUE(tenant_id, restaurant_id, name)
);

CREATE TABLE public.menu_item_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  menu_item_id UUID NOT NULL REFERENCES public.menu_items(id) ON DELETE CASCADE,
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  is_primary BOOLEAN DEFAULT FALSE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.menu_variants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  menu_item_id UUID NOT NULL REFERENCES public.menu_items(id) ON DELETE CASCADE,
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  group_name TEXT NOT NULL,
  option_name TEXT NOT NULL,
  price_modifier NUMERIC(10,2) DEFAULT 0,
  is_required BOOLEAN DEFAULT FALSE,
  is_default BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.menu_addons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  menu_item_id UUID NOT NULL REFERENCES public.menu_items(id) ON DELETE CASCADE,
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  price NUMERIC(10,2) NOT NULL DEFAULT 0,
  max_quantity INTEGER DEFAULT 1,
  is_active BOOLEAN DEFAULT TRUE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.coupons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  code TEXT NOT NULL,
  discount_type TEXT NOT NULL CHECK (discount_type IN ('percentage','fixed')),
  discount_value NUMERIC(10,2) NOT NULL,
  min_order_amount NUMERIC(10,2) DEFAULT 0,
  max_discount_amount NUMERIC(10,2),
  max_uses INTEGER,
  current_uses INTEGER DEFAULT 0,
  per_user_limit INTEGER DEFAULT 1,
  valid_from TIMESTAMPTZ DEFAULT NOW(),
  valid_until TIMESTAMPTZ NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(tenant_id, restaurant_id, code)
);

CREATE TABLE public.carts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  branch_id UUID NOT NULL REFERENCES public.branches(id),
  coupon_id UUID REFERENCES public.coupons(id),
  order_type TEXT NOT NULL DEFAULT 'delivery'
    CHECK (order_type IN ('delivery','pickup','dine_in')),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, restaurant_id)
);

CREATE TABLE public.cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cart_id UUID NOT NULL REFERENCES public.carts(id) ON DELETE CASCADE,
  menu_item_id UUID NOT NULL REFERENCES public.menu_items(id),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
  unit_price NUMERIC(10,2) NOT NULL,
  selected_variants JSONB DEFAULT '[]',
  selected_addons JSONB DEFAULT '[]',
  item_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.restaurant_tables (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  branch_id UUID NOT NULL REFERENCES public.branches(id) ON DELETE CASCADE,
  label TEXT NOT NULL,
  qr_code TEXT UNIQUE,
  seats INTEGER DEFAULT 2,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  branch_id UUID NOT NULL REFERENCES public.branches(id),
  customer_id UUID NOT NULL REFERENCES public.users(id),
  rider_id UUID REFERENCES public.users(id),
  order_number TEXT UNIQUE NOT NULL,
  order_type TEXT NOT NULL CHECK (order_type IN ('delivery','pickup','dine_in')),
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN (
      'pending','confirmed','preparing','ready',
      'picked_up','out_for_delivery','delivered','cancelled','refunded'
    )),
  delivery_address JSONB,
  table_id UUID REFERENCES public.restaurant_tables(id),
  subtotal NUMERIC(12,2) NOT NULL,
  discount_amount NUMERIC(10,2) DEFAULT 0,
  delivery_fee NUMERIC(10,2) DEFAULT 0,
  tax_amount NUMERIC(10,2) DEFAULT 0,
  total_amount NUMERIC(12,2) NOT NULL,
  coupon_id UUID REFERENCES public.coupons(id),
  loyalty_points_used INTEGER DEFAULT 0,
  loyalty_points_earned INTEGER DEFAULT 0,
  wallet_amount_used NUMERIC(10,2) DEFAULT 0,
  payment_method TEXT NOT NULL
    CHECK (payment_method IN ('card','cash','wallet','apple_pay','google_pay')),
  payment_status TEXT NOT NULL DEFAULT 'pending'
    CHECK (payment_status IN ('pending','paid','failed','refunded')),
  special_instructions TEXT,
  estimated_delivery_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  cancellation_reason TEXT,
  is_scheduled BOOLEAN DEFAULT FALSE,
  scheduled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  menu_item_id UUID NOT NULL REFERENCES public.menu_items(id),
  name TEXT NOT NULL,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price NUMERIC(10,2) NOT NULL,
  total_price NUMERIC(10,2) NOT NULL,
  selected_variants JSONB DEFAULT '[]',
  selected_addons JSONB DEFAULT '[]',
  item_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.order_status_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  status TEXT NOT NULL,
  changed_by UUID REFERENCES public.users(id),
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  customer_id UUID NOT NULL REFERENCES public.users(id),
  amount NUMERIC(12,2) NOT NULL,
  currency TEXT DEFAULT 'PKR',
  payment_method TEXT NOT NULL,
  payment_gateway TEXT CHECK (payment_gateway IN ('stripe','cash','wallet','nowpayments')),
  gateway_payment_id TEXT,
  gateway_payment_intent TEXT,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending','succeeded','failed','refunded')),
  refund_amount NUMERIC(10,2),
  refunded_at TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.loyalty_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  order_id UUID REFERENCES public.orders(id),
  points INTEGER NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('earn','redeem','adjust')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.wallet_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL REFERENCES public.customers(id) ON DELETE CASCADE,
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  amount NUMERIC(10,2) NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('top_up','order_payment','refund','adjust')),
  reference_type TEXT,
  reference_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.riders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  branch_id UUID REFERENCES public.branches(id),
  is_online BOOLEAN DEFAULT FALSE,
  current_latitude NUMERIC(10,7),
  current_longitude NUMERIC(10,7),
  last_seen_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.deliveries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  branch_id UUID NOT NULL REFERENCES public.branches(id),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  rider_id UUID REFERENCES public.users(id),
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending','accepted','picked_up','out_for_delivery','delivered','rejected')),
  pickup_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  current_latitude NUMERIC(10,7),
  current_longitude NUMERIC(10,7),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  order_id UUID REFERENCES public.orders(id),
  customer_id UUID NOT NULL REFERENCES public.users(id),
  rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  image_urls TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID REFERENCES public.restaurants(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  event_type TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.campaigns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID NOT NULL REFERENCES public.restaurants(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  audience JSONB DEFAULT '{}',
  scheduled_at TIMESTAMPTZ,
  sent_at TIMESTAMPTZ,
  created_by UUID REFERENCES public.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE,
  restaurant_id UUID REFERENCES public.restaurants(id) ON DELETE CASCADE,
  user_id UUID REFERENCES public.users(id),
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_restaurants_tenant ON public.restaurants(tenant_id);
CREATE INDEX idx_branches_restaurant ON public.branches(restaurant_id);
CREATE INDEX idx_users_auth ON public.users(auth_id);
CREATE INDEX idx_users_tenant_role ON public.users(tenant_id, role);
CREATE INDEX idx_menu_items_restaurant ON public.menu_items(restaurant_id, is_available);
CREATE INDEX idx_orders_branch_status ON public.orders(branch_id, status);
CREATE INDEX idx_orders_customer ON public.orders(customer_id, created_at DESC);
CREATE INDEX idx_deliveries_rider ON public.deliveries(rider_id, status);
CREATE INDEX idx_notifications_user ON public.notifications(user_id, read_at);

CREATE TRIGGER subscription_plans_updated_at
BEFORE UPDATE ON public.subscription_plans
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER tenants_updated_at
BEFORE UPDATE ON public.tenants
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER restaurants_updated_at
BEFORE UPDATE ON public.restaurants
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER branches_updated_at
BEFORE UPDATE ON public.branches
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER users_updated_at
BEFORE UPDATE ON public.users
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER customers_updated_at
BEFORE UPDATE ON public.customers
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER menu_items_updated_at
BEFORE UPDATE ON public.menu_items
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER orders_updated_at
BEFORE UPDATE ON public.orders
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE OR REPLACE FUNCTION public.app_user_id()
RETURNS UUID
LANGUAGE SQL
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT id FROM public.users WHERE auth_id = auth.uid() AND deleted_at IS NULL LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.app_tenant_id()
RETURNS UUID
LANGUAGE SQL
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT tenant_id FROM public.users WHERE auth_id = auth.uid() AND deleted_at IS NULL LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.app_role()
RETURNS TEXT
LANGUAGE SQL
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT role FROM public.users WHERE auth_id = auth.uid() AND deleted_at IS NULL LIMIT 1;
$$;

CREATE OR REPLACE FUNCTION public.can_manage_restaurant()
RETURNS BOOLEAN
LANGUAGE SQL
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT COALESCE(
    public.app_role() IN ('super_admin','restaurant_owner','manager'),
    FALSE
  );
$$;

ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_item_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.menu_addons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.restaurant_tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.riders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "plans are readable" ON public.subscription_plans
FOR SELECT USING (is_active = TRUE);

CREATE POLICY "super admins manage tenants" ON public.tenants
FOR ALL USING (public.app_role() = 'super_admin')
WITH CHECK (public.app_role() = 'super_admin');

CREATE POLICY "tenant users read tenant" ON public.tenants
FOR SELECT USING (id = public.app_tenant_id());

CREATE POLICY "public reads active restaurants" ON public.restaurants
FOR SELECT USING (is_active = TRUE AND deleted_at IS NULL);

CREATE POLICY "managers mutate restaurants" ON public.restaurants
FOR ALL USING (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant())
WITH CHECK (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant());

CREATE POLICY "public reads active branches" ON public.branches
FOR SELECT USING (is_active = TRUE AND deleted_at IS NULL);

CREATE POLICY "managers mutate branches" ON public.branches
FOR ALL USING (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant())
WITH CHECK (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant());

CREATE POLICY "users read themselves or tenant staff" ON public.users
FOR SELECT USING (
  id = public.app_user_id()
  OR (tenant_id = public.app_tenant_id() AND public.app_role() IN ('super_admin','restaurant_owner','manager'))
);

CREATE POLICY "managers mutate users" ON public.users
FOR ALL USING (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant())
WITH CHECK (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant());

CREATE POLICY "customers own profiles" ON public.customers
FOR ALL USING (user_id = public.app_user_id())
WITH CHECK (user_id = public.app_user_id());

CREATE POLICY "tenant staff read customers" ON public.customers
FOR SELECT USING (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant());

CREATE POLICY "users own addresses" ON public.addresses
FOR ALL USING (user_id = public.app_user_id())
WITH CHECK (user_id = public.app_user_id());

CREATE POLICY "public reads active categories" ON public.categories
FOR SELECT USING (is_active = TRUE);

CREATE POLICY "managers mutate categories" ON public.categories
FOR ALL USING (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant())
WITH CHECK (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant());

CREATE POLICY "public reads active menu items" ON public.menu_items
FOR SELECT USING (is_available = TRUE AND deleted_at IS NULL);

CREATE POLICY "managers mutate menu items" ON public.menu_items
FOR ALL USING (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant())
WITH CHECK (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant());

CREATE POLICY "public reads menu images" ON public.menu_item_images
FOR SELECT USING (TRUE);

CREATE POLICY "managers mutate menu images" ON public.menu_item_images
FOR ALL USING (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant())
WITH CHECK (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant());

CREATE POLICY "public reads active variants" ON public.menu_variants
FOR SELECT USING (is_active = TRUE);

CREATE POLICY "managers mutate variants" ON public.menu_variants
FOR ALL USING (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant())
WITH CHECK (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant());

CREATE POLICY "public reads active addons" ON public.menu_addons
FOR SELECT USING (is_active = TRUE);

CREATE POLICY "managers mutate addons" ON public.menu_addons
FOR ALL USING (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant())
WITH CHECK (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant());

CREATE POLICY "public reads active coupons" ON public.coupons
FOR SELECT USING (is_active = TRUE AND valid_until >= NOW());

CREATE POLICY "marketing mutates coupons" ON public.coupons
FOR ALL USING (
  tenant_id = public.app_tenant_id()
  AND public.app_role() IN ('super_admin','restaurant_owner','manager','marketing_staff')
)
WITH CHECK (
  tenant_id = public.app_tenant_id()
  AND public.app_role() IN ('super_admin','restaurant_owner','manager','marketing_staff')
);

CREATE POLICY "users own carts" ON public.carts
FOR ALL USING (user_id = public.app_user_id())
WITH CHECK (user_id = public.app_user_id());

CREATE POLICY "users own cart items" ON public.cart_items
FOR ALL USING (
  EXISTS (
    SELECT 1 FROM public.carts
    WHERE carts.id = cart_items.cart_id
    AND carts.user_id = public.app_user_id()
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.carts
    WHERE carts.id = cart_items.cart_id
    AND carts.user_id = public.app_user_id()
  )
);

CREATE POLICY "public reads active tables" ON public.restaurant_tables
FOR SELECT USING (is_active = TRUE);

CREATE POLICY "customers read own orders" ON public.orders
FOR SELECT USING (customer_id = public.app_user_id());

CREATE POLICY "customers create own orders" ON public.orders
FOR INSERT WITH CHECK (customer_id = public.app_user_id());

CREATE POLICY "tenant staff manage orders" ON public.orders
FOR ALL USING (
  tenant_id = public.app_tenant_id()
  AND public.app_role() IN ('super_admin','restaurant_owner','manager','cashier','kitchen_staff','delivery_manager')
)
WITH CHECK (
  tenant_id = public.app_tenant_id()
  AND public.app_role() IN ('super_admin','restaurant_owner','manager','cashier','kitchen_staff','delivery_manager')
);

CREATE POLICY "riders update assigned orders" ON public.orders
FOR UPDATE USING (rider_id = public.app_user_id())
WITH CHECK (rider_id = public.app_user_id());

CREATE POLICY "order items follow order access" ON public.order_items
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.orders
    WHERE orders.id = order_items.order_id
    AND (
      orders.customer_id = public.app_user_id()
      OR orders.tenant_id = public.app_tenant_id()
    )
  )
);

CREATE POLICY "tenant staff write order items" ON public.order_items
FOR ALL USING (tenant_id = public.app_tenant_id())
WITH CHECK (tenant_id = public.app_tenant_id());

CREATE POLICY "order history tenant read" ON public.order_status_history
FOR SELECT USING (tenant_id = public.app_tenant_id());

CREATE POLICY "order history tenant insert" ON public.order_status_history
FOR INSERT WITH CHECK (tenant_id = public.app_tenant_id());

CREATE POLICY "customers read own payments" ON public.payments
FOR SELECT USING (customer_id = public.app_user_id());

CREATE POLICY "tenant staff read payments" ON public.payments
FOR SELECT USING (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant());

CREATE POLICY "customers read own loyalty" ON public.loyalty_transactions
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.customers
    WHERE customers.id = loyalty_transactions.customer_id
    AND customers.user_id = public.app_user_id()
  )
);

CREATE POLICY "customers read own wallet" ON public.wallet_transactions
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.customers
    WHERE customers.id = wallet_transactions.customer_id
    AND customers.user_id = public.app_user_id()
  )
);

CREATE POLICY "riders manage self" ON public.riders
FOR ALL USING (user_id = public.app_user_id())
WITH CHECK (user_id = public.app_user_id());

CREATE POLICY "delivery tenant access" ON public.deliveries
FOR ALL USING (
  tenant_id = public.app_tenant_id()
  OR rider_id = public.app_user_id()
)
WITH CHECK (
  tenant_id = public.app_tenant_id()
  OR rider_id = public.app_user_id()
);

CREATE POLICY "public reads reviews" ON public.reviews
FOR SELECT USING (TRUE);

CREATE POLICY "customers write own reviews" ON public.reviews
FOR INSERT WITH CHECK (customer_id = public.app_user_id());

CREATE POLICY "users own notifications" ON public.notifications
FOR ALL USING (user_id = public.app_user_id())
WITH CHECK (user_id = public.app_user_id());

CREATE POLICY "marketing manages campaigns" ON public.campaigns
FOR ALL USING (
  tenant_id = public.app_tenant_id()
  AND public.app_role() IN ('super_admin','restaurant_owner','manager','marketing_staff')
)
WITH CHECK (
  tenant_id = public.app_tenant_id()
  AND public.app_role() IN ('super_admin','restaurant_owner','manager','marketing_staff')
);

CREATE POLICY "tenant staff read audit logs" ON public.audit_logs
FOR SELECT USING (tenant_id = public.app_tenant_id() AND public.can_manage_restaurant());
