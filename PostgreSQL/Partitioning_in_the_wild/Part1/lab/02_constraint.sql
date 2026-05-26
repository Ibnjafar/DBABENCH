CREATE TABLE lab.sensor_constraint (
    reading_id   BIGSERIAL,
    sensor_id    INT NOT NULL,
    location     TEXT NOT NULL,
    temperature  NUMERIC(5,2) NOT NULL,
    humidity     NUMERIC(5,2) NOT NULL,
    pressure     NUMERIC(7,2) NOT NULL,
    recorded_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE lab.sensor_constraint_202605 (
    CHECK (recorded_at >= '2026-05-01' AND recorded_at < '2026-06-01')
) INHERITS (lab.sensor_constraint);

CREATE TABLE lab.sensor_constraint_202606 (
    CHECK (recorded_at >= '2026-06-01' AND recorded_at < '2026-07-01')
) INHERITS (lab.sensor_constraint);

CREATE INDEX ON lab.sensor_constraint_202605 (sensor_id, recorded_at);
CREATE INDEX ON lab.sensor_constraint_202606 (sensor_id, recorded_at);

-- Step 1 trigger: raises exception for out-of-range 
CREATE OR REPLACE FUNCTION lab.sensor_constraint_insert()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.recorded_at >= '2026-05-01' AND NEW.recorded_at < '2026-06-01' THEN
        INSERT INTO lab.sensor_constraint_202605 VALUES (NEW.*);
    ELSIF NEW.recorded_at >= '2026-06-01' AND NEW.recorded_at < '2026-07-01' THEN
        INSERT INTO lab.sensor_constraint_202606 VALUES (NEW.*);
    ELSE
        RAISE EXCEPTION 'No partition for recorded_at = %', NEW.recorded_at;
    END IF;
    RETURN NULL;
END;
$$;

CREATE TRIGGER sensor_constraint_insert_trigger
BEFORE INSERT ON lab.sensor_constraint
FOR EACH ROW EXECUTE FUNCTION lab.sensor_constraint_insert();

-- Step 4: add default partition and update trigger
CREATE TABLE lab.sensor_constraint_default ()
    INHERITS (lab.sensor_constraint);

CREATE OR REPLACE FUNCTION lab.sensor_constraint_insert()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.recorded_at >= '2026-05-01' AND NEW.recorded_at < '2026-06-01' THEN
        INSERT INTO lab.sensor_constraint_202605 VALUES (NEW.*);
    ELSIF NEW.recorded_at >= '2026-06-01' AND NEW.recorded_at < '2026-07-01' THEN
        INSERT INTO lab.sensor_constraint_202606 VALUES (NEW.*);
    ELSE
        INSERT INTO lab.sensor_constraint_default VALUES (NEW.*);
    END IF;
    RETURN NULL;
END;
$$;
