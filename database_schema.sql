DROP TABLE IF EXISTS reviews CASCADE;
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS room_rates CASCADE;
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS promotions CASCADE;
DROP TABLE IF EXISTS stays CASCADE;
DROP TABLE IF EXISTS users CASCADE;
CREATE EXTENSION IF NOT EXISTS postgis;

-- Tabla: users (UUID obligatorio para Supabase Auth)
CREATE TABLE users (
    auth_user_id UUID PRIMARY KEY,
    username TEXT NOT NULL,
    user_type TEXT CHECK (user_type IN ('guest', 'host', 'admin')),
    preferred_language TEXT,
    preferred_theme JSON,
    profile_image_url TEXT,
    email TEXT UNIQUE NOT NULL,
    phone_number TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla: stays (BIGSERIAL )
CREATE TABLE stays (
    stay_id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT CHECK (category IN ('hotel', 'cabin', 'apartment', 'hostel')),
    description TEXT,
    status TEXT CHECK (status IN ('published', 'draft', 'closed')) DEFAULT 'draft',
    location GEOMETRY(Point, 4326),
    main_image_url TEXT,
    owner_id UUID REFERENCES users(auth_user_id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla: promotions (UUID )
CREATE TABLE promotions (
    promotion_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stay_id BIGINT REFERENCES stays(stay_id),
    description TEXT NOT NULL,
    discount_percentage NUMERIC(5,2) CHECK (discount_percentage >= 0 AND discount_percentage <= 100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    state TEXT NOT NULL CHECK (state IN ('active', 'paused', 'expired', 'restricted')) DEFAULT 'active'
);
-- Tabla: rooms (BIGSERIAL)
CREATE TABLE rooms (
    room_id BIGSERIAL PRIMARY KEY,
    stay_id BIGINT REFERENCES stays(stay_id),
    availability_status TEXT CHECK (availability_status IN ('available', 'unavailable')) DEFAULT 'available',
    room_image_url TEXT,
    features JSON,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

    -- Tabla: room_rates (BIGSERIAL)
CREATE TABLE room_rates (
    id BIGSERIAL PRIMARY KEY,
    room_id BIGINT REFERENCES rooms(room_id),
    rate_type TEXT CHECK (rate_type IN ('hour', 'night', 'day', 'week', 'month')),
    price DECIMAL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    promotion_id UUID REFERENCES promotions(promotion_id)
);

-- Tabla: bookings (BIGSERIAL)
CREATE TABLE bookings (
    booking_id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(auth_user_id),
    room_id BIGINT REFERENCES rooms(room_id),
    check_in_date DATE,
    check_out_date DATE,
    booking_status TEXT CHECK (booking_status IN ('pending', 'confirmed', 'cancelled')) DEFAULT 'pending',
    total_price DECIMAL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla: reviews (BIGSERIAL para mejor rendimiento)
CREATE TABLE reviews (
    review_id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES users(auth_user_id),
    stay_id BIGINT REFERENCES stays(stay_id),
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);