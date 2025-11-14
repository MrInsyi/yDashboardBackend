WITH classified AS (
  SELECT
    station_id,
    date_trunc('hour', (created_at AT TIME ZONE 'Asia/Kuala_Lumpur')) AS log_hour,
    CASE WHEN
      COALESCE(insp_1, FALSE) OR COALESCE(insp_2, FALSE) OR COALESCE(insp_3, FALSE) OR
      COALESCE(insp_4, FALSE) OR COALESCE(insp_5, FALSE) OR COALESCE(insp_6, FALSE) OR
      COALESCE(insp_7, FALSE) OR COALESCE(insp_8, FALSE) OR COALESCE(insp_9, FALSE) OR
      COALESCE(insp_10, FALSE) OR COALESCE(insp_11, FALSE) OR COALESCE(insp_12, FALSE) OR
      COALESCE(pos_1, FALSE) OR COALESCE(pos_2, FALSE) OR COALESCE(pos_3, FALSE) OR
      COALESCE(pos_4, FALSE) OR COALESCE(pos_5, FALSE) OR COALESCE(pos_6, FALSE) OR
      COALESCE(pos_7, FALSE) OR COALESCE(pos_8, FALSE) OR COALESCE(pos_9, FALSE) OR
      COALESCE(pos_10, FALSE) OR COALESCE(pos_11, FALSE) OR COALESCE(pos_12, FALSE) OR
      COALESCE(pos_13, FALSE) OR COALESCE(pos_14, FALSE) OR COALESCE(pos_15, FALSE) OR
      COALESCE(pos_16, FALSE)
    THEN 1 ELSE 0 END AS is_defective
  FROM leak_test_log
  WHERE 
    station_id = %(station_id)s
    AND (created_at AT TIME ZONE 'Asia/Kuala_Lumpur')::time BETWEEN '08:00' AND '20:00'
    AND (created_at AT TIME ZONE 'Asia/Kuala_Lumpur')::date = %(target_date)s
),

hours AS (
  SELECT generate_series(
    (%(target_date)s::timestamp AT TIME ZONE 'Asia/Kuala_Lumpur') + interval '8 hour',
    (%(target_date)s::timestamp AT TIME ZONE 'Asia/Kuala_Lumpur') + interval '20 hour',
    interval '1 hour'
  ) AS hour_start
)

SELECT
  to_char(h.hour_start, 'HH24:00') AS hour_label,
  c.station_id,
  COUNT(c.*) AS total_output,
  COALESCE(SUM(c.is_defective), 0) AS total_defect,
  ROUND(
    100.0 * (COALESCE(SUM(c.is_defective), 0)::numeric / NULLIF(COUNT(c.*), 0)),
    2
  ) AS defect_rate,
  ROUND(
    100.0 * (1 - (COALESCE(SUM(c.is_defective), 0)::numeric / NULLIF(COUNT(c.*), 0))),
    2
  ) AS yield_rate,
  ROUND(
    ((COUNT(c.*) - COALESCE(SUM(c.is_defective), 0))::numeric / NULLIF(COUNT(c.*), 0)) * 100,
    2
  ) AS fpy_rate
FROM hours h
LEFT JOIN classified c
  ON c.log_hour = h.hour_start
GROUP BY h.hour_start, c.station_id
ORDER BY h.hour_start;
