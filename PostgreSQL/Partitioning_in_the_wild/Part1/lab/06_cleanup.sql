DELETE FROM partman.part_config WHERE parent_table LIKE 'lab.%';
SELECT cron.unschedule('create_native_partition_monthly');
DROP SCHEMA lab CASCADE;
