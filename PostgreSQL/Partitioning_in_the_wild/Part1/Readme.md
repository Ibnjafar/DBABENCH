# Partitioning in the Wild: Part 1

**Your partitioned table will fail at midnight**

Series: Partitioning in the Wild | Part 1 of 10
Platform: PostgreSQL 18.3 | Tested on Docker

## What this post covers

Three PostgreSQL partitioning approaches built side by side using monthly partitions.
We simulate out-of-range inserts, apply fixes, test a fourth dynamic approach, and run a write benchmark across all four.

## Approaches compared

| Approach | Description |
|---|---|
| Native declarative | PG10+ built-in range partitioning |
| Constraint-based | Legacy inheritance with trigger routing (pre-PG10) |
| pg_partman | Automated lifecycle management on top of native |
| Dynamic trigger | Auto-creates partition on first insert via trigger |

## Key findings

| Approach | Write 1M rows (single month) | Write 1M rows (multi-month) | Auto partition creation | Monthly manual work |
|---|---|---|---|---|
| native | 6,158 ms | 6,577 ms | No | DDL every month |
| constraint (static) | 34,902 ms | 31,531 ms | No | DDL + trigger update |
| pg_partman | 8,150 ms | 9,868 ms | Yes, in advance | None |
| dynamic trigger | 110,630 ms | 94,632 ms | Yes, on first insert | None |

## Lab structure

```
lab/
├── 00_setup.sql            -- schema creation
├── 01_native.sql           -- native declarative + pg_cron auto-partition
├── 02_constraint.sql       -- constraint-based with static and updated trigger
├── 03_partman.sql          -- pg_partman setup
├── 04_dynamic_trigger.sql  -- dynamic auto-creating trigger
├── 05_benchmark.sql        -- write benchmark queries
├── 06_cleanup.sql          -- drop everything and start fresh
└── live_test/
    ├── README.md           -- connection and usage instructions
    ├── requirements.txt    -- psycopg2-binary
    └── sensor_generator.py -- live bulk data ingestion with drift simulation
```

## Prerequisites

- PostgreSQL 18.3
- pg_partman 5.4.3
- pg_cron (optional, for auto-partition scheduling in 01_native.sql)
- Docker  (Windows/Mac/Linux) or any PostgreSQL instance

## Quick start

```sql
-- Run in order
\i lab/00_setup.sql
\i lab/01_native.sql
\i lab/02_constraint.sql
\i lab/03_partman.sql
\i lab/04_dynamic_trigger.sql
```

## Read the full post

[Your partitioned table will fail at midnight](https://dbabench.blogspot.com/2026/05/your-partitioned-table-will-fail-at.html)

## Series: Partitioning in the Wild
```
| Post | Title |
|------|-------|
| 1 | Your partitioned table will fail at midnight |
| 2 | Pre-creating partitions manually is how incidents start at 3am |
| 3 | Moving 50 million rows into a partitioned table without downtime |
| 4 | Partition pruning: the feature that only works if you write queries right |
| 5 | What breaks in your partitioned tables when you upgrade to PG18 |
```
