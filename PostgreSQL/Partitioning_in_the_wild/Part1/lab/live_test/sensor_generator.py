"""
Sensor data generator for partitioning live test.
Inserts rows into all four partition approaches simultaneously.

Usage:
    python sensor_generator.py
    python sensor_generator.py --rows 100000
    python sensor_generator.py --drift 55        # simulate boundary crossing
    python sensor_generator.py --batch 500       # rows per batch
    python sensor_generator.py --approach native # target one table only


"""

import argparse
import os
import random
import time
from datetime import datetime, timezone, timedelta

import psycopg2
from psycopg2.extras import execute_values

# connection 
DB = {
    "host":     os.getenv("PG_HOST",     "**********"),
    "port":     int(os.getenv("PG_PORT", "5432")),
    "dbname":   os.getenv("PG_DB",       "labdb"),
    "user":     os.getenv("PG_USER",     "********"),
    "password": os.getenv("PG_PASSWORD", "************"),
}

# constants
LOCATIONS = [
    "Server Room A", "Server Room B", "Data Hall North",
    "Data Hall South", "UPS Room", "Cooling Unit 1",
    "Cooling Unit 2", "Office Floor 1", "Office Floor 2",
    "Rooftop Station",
]

TABLES = {
    "native":     "lab.sensor_native",
    "constraint": "lab.sensor_constraint",
    "partman":    "lab.sensor_partman",
    "dynamic":    "lab.sensor_dynamic",
}

INSERT_SQL = """
    INSERT INTO {table}
        (sensor_id, location, temperature, humidity, pressure, recorded_at)
    VALUES %s
"""


#row generation 
def make_row(sensor_id: int, drift_minutes: int = 0):
    recorded_at = datetime.now(timezone.utc) + timedelta(minutes=drift_minutes)
    return (
        sensor_id,
        random.choice(LOCATIONS),
        round(random.uniform(18, 38), 2),
        round(random.uniform(30, 80), 2),
        round(random.uniform(1000, 1030), 2),
        recorded_at,
    )


#  insert 
def insert_batch(cur, table: str, rows: list):
    try:
        execute_values(cur, INSERT_SQL.format(table=table), rows)
        return len(rows), 0
    except Exception as e:
        cur.connection.rollback()
        return 0, len(rows)


#  main 
def main():
    parser = argparse.ArgumentParser(description="Sensor data generator")
    parser.add_argument("--rows",     type=int,  default=10000,
                        help="Total rows to insert (default 10000)")
    parser.add_argument("--batch",    type=int,  default=100,
                        help="Rows per batch (default 100)")
    parser.add_argument("--drift",    type=int,  default=0,
                        help="Shift recorded_at forward N minutes to simulate boundary crossing")
    parser.add_argument("--approach", type=str,  default="all",
                        choices=["all", "native", "constraint", "partman", "dynamic"],
                        help="Target one table or all (default all)")
    parser.add_argument("--sleep",    type=float, default=0.0,
                        help="Sleep seconds between batches (default 0)")
    args = parser.parse_args()

    targets = TABLES if args.approach == "all" else {args.approach: TABLES[args.approach]}

    print(f"Connecting to {DB['host']}:{DB['port']}/{DB['dbname']}")
    conn = psycopg2.connect(**DB)
    conn.autocommit = False
    cur = conn.cursor()

    total_inserted = {k: 0 for k in targets}
    total_failed   = {k: 0 for k in targets}
    batches        = args.rows // args.batch
    sensor_ids     = list(range(101, 111))

    print(f"Inserting {args.rows} rows in {batches} batches of {args.batch}")
    if args.drift:
        print(f"Drift: +{args.drift} minutes (simulating boundary crossing)")
    print()

    start = time.time()

    for batch_num in range(1, batches + 1):
        rows = [make_row(random.choice(sensor_ids), args.drift)
                for _ in range(args.batch)]

        for approach, table in targets.items():
            inserted, failed = insert_batch(cur, table, rows)
            total_inserted[approach] += inserted
            total_failed[approach]   += failed

        conn.commit()

        if batch_num % 10 == 0 or batch_num == batches:
            elapsed = time.time() - start
            rps = sum(total_inserted.values()) / elapsed if elapsed > 0 else 0
            print(f"Batch {batch_num:>4}/{batches}  "
                  f"elapsed {elapsed:>6.1f}s  "
                  f"~{rps:>7.0f} rows/s")

        if args.sleep:
            time.sleep(args.sleep)

    elapsed = time.time() - start
    print()
    print("Results:")
    print(f"{'Approach':<12} {'Inserted':>10} {'Failed':>8}")
    print("-" * 32)
    for approach in targets:
        print(f"{approach:<12} {total_inserted[approach]:>10} {total_failed[approach]:>8}")
    print(f"\nTotal time: {elapsed:.1f}s")

    cur.close()
    conn.close()


if __name__ == "__main__":
    main()
