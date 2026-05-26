\timing on

TRUNCATE lab.sensor_native CASCADE;
TRUNCATE lab.sensor_constraint CASCADE;
TRUNCATE lab.sensor_partman CASCADE;
TRUNCATE lab.sensor_dynamic;

-- =============================================
\echo '--- Write Test 1: 1M rows single month ---'
-- =============================================

\echo '[1/4] native'
INSERT INTO lab.sensor_native
    (sensor_id, location, temperature, humidity, pressure, recorded_at)
SELECT (random()*9+101)::int,
    (ARRAY['Server Room A','Server Room B','Data Hall North',
           'Data Hall South','UPS Room','Cooling Unit 1',
           'Cooling Unit 2','Office Floor 1','Office Floor 2',
           'Rooftop Station'])[floor(random()*10+1)],
    round((18+random()*20)::numeric,2),
    round((30+random()*50)::numeric,2),
    round((1000+random()*30)::numeric,2),
    '2026-05-01'::timestamptz+(random()*interval '30 days')
FROM generate_series(1,1000000);

\echo '[2/4] constraint'
INSERT INTO lab.sensor_constraint
    (sensor_id, location, temperature, humidity, pressure, recorded_at)
SELECT (random()*9+101)::int,
    (ARRAY['Server Room A','Server Room B','Data Hall North',
           'Data Hall South','UPS Room','Cooling Unit 1',
           'Cooling Unit 2','Office Floor 1','Office Floor 2',
           'Rooftop Station'])[floor(random()*10+1)],
    round((18+random()*20)::numeric,2),
    round((30+random()*50)::numeric,2),
    round((1000+random()*30)::numeric,2),
    '2026-05-01'::timestamptz+(random()*interval '30 days')
FROM generate_series(1,1000000);

\echo '[3/4] partman'
INSERT INTO lab.sensor_partman
    (sensor_id, location, temperature, humidity, pressure, recorded_at)
SELECT (random()*9+101)::int,
    (ARRAY['Server Room A','Server Room B','Data Hall North',
           'Data Hall South','UPS Room','Cooling Unit 1',
           'Cooling Unit 2','Office Floor 1','Office Floor 2',
           'Rooftop Station'])[floor(random()*10+1)],
    round((18+random()*20)::numeric,2),
    round((30+random()*50)::numeric,2),
    round((1000+random()*30)::numeric,2),
    '2026-05-01'::timestamptz+(random()*interval '30 days')
FROM generate_series(1,1000000);

\echo '[4/4] dynamic'
INSERT INTO lab.sensor_dynamic
    (sensor_id, location, temperature, humidity, pressure, recorded_at)
SELECT (random()*9+101)::int,
    (ARRAY['Server Room A','Server Room B','Data Hall North',
           'Data Hall South','UPS Room','Cooling Unit 1',
           'Cooling Unit 2','Office Floor 1','Office Floor 2',
           'Rooftop Station'])[floor(random()*10+1)],
    round((18+random()*20)::numeric,2),
    round((30+random()*50)::numeric,2),
    round((1000+random()*30)::numeric,2),
    '2026-05-01'::timestamptz+(random()*interval '30 days')
FROM generate_series(1,1000000);

-- =============================================
\echo '--- Write Test 2: 1M rows across 4 months ---'
-- =============================================

\echo '[1/4] native'
INSERT INTO lab.sensor_native
    (sensor_id, location, temperature, humidity, pressure, recorded_at)
SELECT (random()*9+101)::int,
    (ARRAY['Server Room A','Server Room B','Data Hall North',
           'Data Hall South','UPS Room','Cooling Unit 1',
           'Cooling Unit 2','Office Floor 1','Office Floor 2',
           'Rooftop Station'])[floor(random()*10+1)],
    round((18+random()*20)::numeric,2),
    round((30+random()*50)::numeric,2),
    round((1000+random()*30)::numeric,2),
    '2026-05-01'::timestamptz+(random()*interval '122 days')
FROM generate_series(1,1000000);

\echo '[2/4] constraint'
INSERT INTO lab.sensor_constraint
    (sensor_id, location, temperature, humidity, pressure, recorded_at)
SELECT (random()*9+101)::int,
    (ARRAY['Server Room A','Server Room B','Data Hall North',
           'Data Hall South','UPS Room','Cooling Unit 1',
           'Cooling Unit 2','Office Floor 1','Office Floor 2',
           'Rooftop Station'])[floor(random()*10+1)],
    round((18+random()*20)::numeric,2),
    round((30+random()*50)::numeric,2),
    round((1000+random()*30)::numeric,2),
    '2026-05-01'::timestamptz+(random()*interval '122 days')
FROM generate_series(1,1000000);

\echo '[3/4] partman'
INSERT INTO lab.sensor_partman
    (sensor_id, location, temperature, humidity, pressure, recorded_at)
SELECT (random()*9+101)::int,
    (ARRAY['Server Room A','Server Room B','Data Hall North',
           'Data Hall South','UPS Room','Cooling Unit 1',
           'Cooling Unit 2','Office Floor 1','Office Floor 2',
           'Rooftop Station'])[floor(random()*10+1)],
    round((18+random()*20)::numeric,2),
    round((30+random()*50)::numeric,2),
    round((1000+random()*30)::numeric,2),
    '2026-05-01'::timestamptz+(random()*interval '122 days')
FROM generate_series(1,1000000);

\echo '[4/4] dynamic'
INSERT INTO lab.sensor_dynamic
    (sensor_id, location, temperature, humidity, pressure, recorded_at)
SELECT (random()*9+101)::int,
    (ARRAY['Server Room A','Server Room B','Data Hall North',
           'Data Hall South','UPS Room','Cooling Unit 1',
           'Cooling Unit 2','Office Floor 1','Office Floor 2',
           'Rooftop Station'])[floor(random()*10+1)],
    round((18+random()*20)::numeric,2),
    round((30+random()*50)::numeric,2),
    round((1000+random()*30)::numeric,2),
    '2026-05-01'::timestamptz+(random()*interval '122 days')
FROM generate_series(1,1000000);

\timing off
