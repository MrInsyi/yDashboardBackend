WITH classified AS (
  SELECT
    station_id,
    DATE(created_at) AS log_date,
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
  WHERE created_at >= CURRENT_DATE - INTERVAL '30 days'
    AND station_id = 10
)

SELECT
  log_date AS date,
  station_id,
  COUNT(*) AS total_output,
  SUM(is_defective) AS total_defect,
  ROUND(
    100.0 * (SUM(is_defective)::numeric / NULLIF(COUNT(*), 0)),
    2
  ) AS defect_rate,
  ROUND(
    100.0 * (1 - (SUM(is_defective)::numeric / NULLIF(COUNT(*), 0))),
    2
  ) AS yield_rate,
  ROUND(
    ((COUNT(*) - SUM(is_defective))::numeric / NULLIF(COUNT(*), 0)) * 100,
    2
  ) AS fpy_rate
FROM classified
GROUP BY log_date, station_id
ORDER BY log_date;
