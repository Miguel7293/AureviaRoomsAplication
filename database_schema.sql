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





INSERT INTO stays (name, category, description, status, location, main_image_url, owner_id) VALUES
('Palacio Andino', 'hotel', 'Hotel en los Andes', 'published', ST_SetSRID(ST_Point(-77.02, -12.04), 4326), 'https://img.com/s1.png', '52ff6995-c965-4f65-8a1d-7ec739cdf094'),
('Cabaña del Río', 'cabin', 'Cabaña junto al río', 'published', ST_SetSRID(ST_Point(-76.98, -12.05), 4326), 'https://img.com/s2.png', '52ff6995-c965-4f65-8a1d-7ec739cdf094'),
('Apartamento Colonial', 'apartment', 'Departamento céntrico', 'draft', ST_SetSRID(ST_Point(-77.04, -12.03), 4326), 'https://img.com/s3.png', '52ff6995-c965-4f65-8a1d-7ec739cdf094'),
('Hostal Sol Naciente', 'hostel', 'Económico y cálido', 'published', ST_SetSRID(ST_Point(-77.06, -12.06), 4326), 'https://img.com/s4.png', '52ff6995-c965-4f65-8a1d-7ec739cdf094'),
('Castillo de Niebla', 'hotel', 'Estancia mágica en la niebla', 'closed', ST_SetSRID(ST_Point(-77.10, -12.02), 4326), 'https://img.com/s5.png', '52ff6995-c965-4f65-8a1d-7ec739cdf094'),
('Refugio del Cóndor', 'cabin', 'Aventura en las alturas', 'published', ST_SetSRID(ST_Point(-76.95, -12.08), 4326), 'https://img.com/s6.png', '52ff6995-c965-4f65-8a1d-7ec739cdf094');


INSERT INTO promotions (stay_id, description, discount_percentage, start_date, end_date, state)
VALUES 
(7, 'Promo verano 20%', 20, '2025-07-01', '2025-07-31', 'active'),
(8, 'Semana mágica 15%', 15, '2025-07-10', '2025-07-20', 'active'),
(9, 'Mes inaugural 10%', 10, '2025-07-01', '2025-08-01', 'paused'),
(10, 'Solo esta semana', 5, '2025-07-05', '2025-07-12', 'active'),
(11, 'Última oportunidad', 30, '2025-07-03', '2025-07-07', 'expired'),
(12, 'Aventura al 25%', 25, '2025-07-01', '2025-07-15', 'restricted');

INSERT INTO rooms (stay_id, availability_status, room_image_url, features) VALUES
(7, 'available', 'https://img.com/r1.png', '{"beds":2,"wifi":true}'),
(7, 'available', 'https://img.com/r2.png', '{"beds":1,"tv":true}'),
(8, 'available', 'https://img.com/r3.png', '{"beds":3,"chimney":true}'),
(9, 'unavailable', 'https://img.com/r4.png', '{"beds":1,"balcony":true}'),
(10, 'available', 'https://img.com/r5.png', '{"beds":2,"shared_bathroom":true}'),
(11, 'available', 'https://img.com/r6.png', '{"beds":1,"view":"mountains"}');


INSERT INTO room_rates (room_id, rate_type, price, promotion_id) VALUES
(1, 'night', 100.00, (SELECT promotion_id FROM promotions LIMIT 1 OFFSET 0)),
(2, 'night', 90.00, (SELECT promotion_id FROM promotions LIMIT 1 OFFSET 1)),
(3, 'week', 600.00, (SELECT promotion_id FROM promotions LIMIT 1 OFFSET 2)),
(4, 'day', 50.00, NULL),
(5, 'hour', 15.00, (SELECT promotion_id FROM promotions LIMIT 1 OFFSET 3)),
(6, 'night', 110.00, (SELECT promotion_id FROM promotions LIMIT 1 OFFSET 4));

-- BOOKINGS
INSERT INTO bookings (user_id, room_id, check_in_date, check_out_date, booking_status, total_price) VALUES
('6bdeb3cf-878c-4dc9-9133-5490c9cb8f1a', 1, '2025-07-10', '2025-07-12', 'confirmed', 180.00),
('6bdeb3cf-878c-4dc9-9133-5490c9cb8f1a', 2, '2025-07-11', '2025-07-14', 'pending', 270.00),
('6bdeb3cf-878c-4dc9-9133-5490c9cb8f1a', 3, '2025-07-15', '2025-07-20', 'confirmed', 500.00),
('6bdeb3cf-878c-4dc9-9133-5490c9cb8f1a', 4, '2025-07-20', '2025-07-21', 'cancelled', 50.00),
('6bdeb3cf-878c-4dc9-9133-5490c9cb8f1a', 5, '2025-07-08', '2025-07-09', 'confirmed', 15.00),
('6bdeb3cf-878c-4dc9-9133-5490c9cb8f1a', 6, '2025-07-09', '2025-07-10', 'pending', 110.00);


-- REVIEWS
INSERT INTO reviews (user_id, stay_id, rating, comment) VALUES
('6bdeb3cf-878c-4dc9-9133-5490c9cb8f1a', 7, 5, 'Estancia magnífica, vista al valle.'),
('6bdeb3cf-878c-4dc9-9133-5490c9cb8f1a', 8, 4, 'Muy acogedor y tranquilo.'),
('6bdeb3cf-878c-4dc9-9133-5490c9cb8f1a', 9, 3, 'Un poco ruidoso pero céntrico.'),
('6bdeb3cf-878c-4dc9-9133-5490c9cb8f1a', 10, 2, 'Faltaba limpieza.'),
('6bdeb3cf-878c-4dc9-9133-5490c9cb8f1a', 11, 4, 'Hermosa arquitectura.'),
('6bdeb3cf-878c-4dc9-9133-5490c9cb8f1a', 12, 5, 'Perfecto para desconectar del mundo.');