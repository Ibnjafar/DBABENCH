CREATE TABLE lab.sensor_dynamic (
    reading_id   BIGSERIAL,
    sensor_id    INT NOT NULL,
    location     TEXT NOT NULL,
    temperature  NUMERIC(5,2) NOT NULL,
    humidity     NUMERIC(5,2) NOT NULL,
    pressure     NUMERIC(7,2) NOT NULL,
    recorded_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX ON lab.sensor_dynamic (sensor_id, recorded_at);

CREATE OR REPLACE FUNCTION lab.sensor_dynamic_insert()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    partition_name TEXT;
    start_date     TIMESTAMPTZ;
    end_date       TIMESTAMPTZ;
BEGIN
    start_date     := date_trunc('month', NEW.recorded_at);
    end_date       := start_date + interval '1 month';
    partition_name := 'lab.sensor_dynamic_'
                      || to_char(start_date, 'YYYYMM');

    IF NOT EXISTS (
        SELECT 1 FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE n.nspname = 'lab'
          AND c.relname = 'sensor_dynamic_'
                          || to_char(start_date, 'YYYYMM')
    ) THEN
        EXECUTE format(
            'CREATE TABLE %s (
                CHECK (recorded_at >= %L AND recorded_at < %L)
            ) INHERITS (lab.sensor_dynamic)',
            partition_name, start_date, end_date
        );
        EXECUTE format(
            'CREATE INDEX ON %s (sensor_id, recorded_at)',
            partition_name
        );
    END IF;

    EXECUTE format(
        'INSERT INTO %s VALUES ($1.*)', partition_name
    ) USING NEW;

    RETURN NULL;
END;
$$;

CREATE TRIGGER sensor_dynamic_insert_trigger
BEFORE INSERT ON lab.sensor_dynamic
FOR EACH ROW EXECUTE FUNCTION lab.sensor_dynamic_insert();
