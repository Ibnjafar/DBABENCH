

\timing on

-- Write Test 1: 1M rows single month
INSERT INTO lab.sensor_native
    (sensor_id, location, temperature, humidity, pressure, recorded_at)
SELECT
    (random() * 9 + 101)::int,
    (ARRAY['Server Room A','Server Room B','Data Hall North',
           'Data Hall South','UPS Room','Cooling Unit 1',
           'Cooling Unit 2','Office Floor 1','Office Floor 2',
           'Rooftop Station'])[floor(random()*10+1)],
    round((18 + random() * 20)::numeric, 2),
    round((30 + random() * 50)::numeric, 2),
    round((1000 + random() * 30)::numeric, 2),
    '2026-05-01'::timestamptz + (random() * interval '30 days')
FROM generate_series(1, 1000000);

-- Repeat for sensor_constraint, sensor_partman, sensor_dynamic

-- Write Test 2: 1M rows spread across 4 months
INSERT INTO lab.sensor_native
    (sensor_id, location, temperature, humidity, pressure, recorded_at)
SELECT
    (random() * 9 + 101)::int,
    (ARRAY['Server Room A','Server Room B','Data Hall North',
           'Data Hall South','UPS Room','Cooling Unit 1',
           'Cooling Unit 2','Office Floor 1','Office Floor 2',
           'Rooftop Station'])[floor(random()*10+1)],
    round((18 + random() * 20)::numeric, 2),
    round((30 + random() * 50)::numeric, 2),
    round((1000 + random() * 30)::numeric, 2),
    '2026-05-01'::timestamptz + (random() * interval '122 days')
FROM generate_series(1, 1000000);

-- Repeat for sensor_constraint, sensor_partman, sensor_dynamic

\timing off

ANALYZE lab.sensor_native;
ANALYZE lab.sensor_constraint;
ANALYZE lab.sensor_partman;
ANALYZE lab.sensor_dynamic;
