SELECT *
FROM (
  -- 🔹 Leak Position counts
  SELECT
    DATE(created_at) AS log_date,
    v.pos_name AS defect_name,
    COUNT(*) FILTER (WHERE v.pos_value IS TRUE) AS total
  FROM leak_test_log
  CROSS JOIN LATERAL (
    VALUES
      ('pos_1', pos_1),
      ('pos_2', pos_2),
      ('pos_3', pos_3),
      ('pos_4', pos_4),
      ('pos_5', pos_5),
      ('pos_6', pos_6),
      ('pos_7', pos_7),
      ('pos_8', pos_8),
      ('pos_9', pos_9),
      ('pos_10', pos_10),
      ('pos_11', pos_11),
      ('pos_12', pos_12),
      ('pos_13', pos_13),
      ('pos_14', pos_14),
      ('pos_15', pos_15)
  ) AS v(pos_name, pos_value)
  GROUP BY log_date, v.pos_name

  UNION ALL

  -- 🔸 Defect Name counts
  SELECT
    DATE(l.created_at) AS log_date,
    v.defect_name,
    COUNT(*) FILTER (WHERE v.insp_value IS TRUE) AS total
  FROM leak_test_log l
  JOIN leak_test_insp_name n ON l.station_id = n.station_id
  CROSS JOIN LATERAL (
    VALUES
      ('insp_1', n.insp_1, l.insp_1),
      ('insp_2', n.insp_2, l.insp_2),
      ('insp_3', n.insp_3, l.insp_3),
      ('insp_4', n.insp_4, l.insp_4),
      ('insp_5', n.insp_5, l.insp_5),
      ('insp_6', n.insp_6, l.insp_6),
      ('insp_7', n.insp_7, l.insp_7),
      ('insp_8', n.insp_8, l.insp_8),
      ('insp_9', n.insp_9, l.insp_9)
  ) AS v(insp_name, defect_name, insp_value)
  WHERE v.defect_name IS NOT NULL
  GROUP BY log_date, v.defect_name

) AS combined
WHERE TO_CHAR(log_date, 'YYYY-MM') = %s
ORDER BY log_date, defect_name;
