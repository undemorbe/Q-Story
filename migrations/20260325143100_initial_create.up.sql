CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE buildings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    client_id TEXT NOT NULL,
    title TEXT NOT NULL,
    compressed_description TEXT NOT NULL,

    top_description TEXT,
    main_description TEXT,
    bottom_description TEXT,

    image TEXT,
    started_at TIMESTAMP NOT NULL,
    ended_at TIMESTAMP NOT NULL,
    type TEXT NOT NULL,
    person TEXT DEFAULT '',
    resources TEXT[]
);

CREATE TABLE markers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    building_id UUID UNIQUE NOT NULL,

    client_id TEXT NOT NULL,
    lat TEXT NOT NULL,
    lon TEXT NOT NULL,
    title TEXT NOT NULL,
    type TEXT NOT NULL,

    compressed_description TEXT NOT NULL,

    FOREIGN KEY (building_id)
        REFERENCES buildings(id)
        ON DELETE CASCADE
);

CREATE INDEX idx_markers_building_id ON markers(building_id);