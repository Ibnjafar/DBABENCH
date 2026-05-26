## Live test: sensor data generator

### Prerequisites
```bash
pip install psycopg2-binary
```

### Configure connection
Edit `live_test/sensor_generator.py` and update the DB section with your values:
```python
DB = {
    "host":     os.getenv("PG_HOST",     "localhost"),
    "port":     int(os.getenv("PG_PORT", "5432")),
    "dbname":   os.getenv("PG_DB",       "postgres"),
    "user":     os.getenv("PG_USER",     "postgres"),
    "password": os.getenv("PG_PASSWORD", ""),
}
```

### Usage
```bash
# Basic run: 10k rows across all four tables
python sensor_generator.py

# 100k rows in batches of 1000
python sensor_generator.py --rows 100000 --batch 1000

# Simulate partition boundary crossing (shift time 55 minutes forward)
python sensor_generator.py --drift 55

# Target only partman table
python sensor_generator.py --approach partman --rows 50000

# Slow insert to watch in real time
python sensor_generator.py --sleep 0.1 --rows 1000
```
