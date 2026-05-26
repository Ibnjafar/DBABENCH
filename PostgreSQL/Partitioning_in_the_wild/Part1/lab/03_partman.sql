CREATE TABLE lab.sensor_partman (
    reading_id   BIGSERIAL,
    sensor_id    INT NOT NULL,
    location     TEXT NOT NULL,
    temperature  NUMERIC(5,2) NOT NULL,
    humidity     NUMERIC(5,2) NOT NULL,
    pressure     NUMERIC(7,2) NOT NULL,
    recorded_at  TIMESTAMPTZ NOT NULL DEFAULT now()
) PARTITION BY RANGE (recorded_at);

CREATE INDEX ON lab.sensor_partman (sensor_id, recorded_at);

SELECT partman.create_parent(
    p_parent_table => 'lab.sensor_partman',
    p_control      => 'recorded_at',
    p_interval     => '1 month',
    p_premake      => 3
);
