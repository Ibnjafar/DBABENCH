CREATE TABLE lab.sensor_native (
    reading_id   BIGSERIAL,
    sensor_id    INT NOT NULL,
    location     TEXT NOT NULL,
    temperature  NUMERIC(5,2) NOT NULL,
    humidity     NUMERIC(5,2) NOT NULL,
    pressure     NUMERIC(7,2) NOT NULL,
    recorded_at  TIMESTAMPTZ NOT NULL DEFAULT now()
) PARTITION BY RANGE (recorded_at);

CREATE TABLE lab.sensor_native_202605
    PARTITION OF lab.sensor_native
    FOR VALUES FROM ('2026-05-01') TO ('2026-06-01');

CREATE TABLE lab.sensor_native_202606
    PARTITION OF lab.sensor_native
    FOR VALUES FROM ('2026-06-01') TO ('2026-07-01');

CREATE INDEX ON lab.sensor_native (sensor_id, recorded_at);

-- Step 4: add default partition
CREATE TABLE lab.sensor_native_default
    PARTITION OF lab.sensor_native DEFAULT;

-- Optional: pg_cron auto-partition creation (runs 25th of each month)
CREATE OR REPLACE FUNCTION lab.create_next_partition_native()
RETURNS void LANGUAGE plpgsql AS $$
DECLARE
    next_month     DATE;
    partition_name TEXT;
    start_date     TEXT;
    end_date       TEXT;
BEGIN
    next_month     := date_trunc('month', now() + interval '1 month');
    partition_name := 'lab.sensor_native_' || to_char(next_month, 'YYYYMM');
    start_date     := to_char(next_month, 'YYYY-MM-DD');
    end_date       := to_char(next_month + interval '1 month', 'YYYY-MM-DD');

    IF NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'lab'
          AND c.relname = 'sensor_native_' || to_char(next_month, 'YYYYMM')
    ) THEN
        EXECUTE format(
            'CREATE TABLE %s
             PARTITION OF lab.sensor_native
             FOR VALUES FROM (%L) TO (%L)',
            partition_name, start_date, end_date
        );
    END IF;
END;
$$;

SELECT cron.schedule(
    'create_native_partition_monthly',
    '0 2 25 * *',
    'SELECT lab.create_next_partition_native()'
);
