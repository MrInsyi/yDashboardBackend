WITH all_labels AS (
  SELECT n.station_id, v.defect_name AS label
  FROM leak_test_insp_name n
  CROSS JOIN LATERAL (
    VALUES
      (n.insp_1),
      (n.insp_2),
      (n.insp_3),
      (n.insp_4),
      (n.insp_5),
      (n.insp_6),
      (n.insp_7),
      (n.insp_8),
      (n.insp_9),
      (n.insp_10),
      (n.insp_11),
      (n.insp_12)
  ) AS v(defect_name)
  WHERE v.defect_name IS NOT NULL

  UNION ALL

  SELECT DISTINCT l.station_id, v2.pos_name AS label
  FROM leak_test_log l
  CROSS JOIN LATERAL (
    VALUES
      ('POS_1'), ('POS_2'), ('POS_3'), ('POS_4'),
      ('POS_5'), ('POS_6'), ('POS_7'), ('POS_8'),
      ('POS_9'), ('POS_10'), ('POS_11'), ('POS_12'),
      ('POS_13'), ('POS_14'), ('POS_15'), ('POS_16')
  ) AS v2(pos_name)
),

defect_counts AS (
  SELECT 
    l.station_id,
    v.label_name,
    COUNT(*) AS total_occurrences
  FROM leak_test_log AS l
  JOIN leak_test_insp_name AS n
    ON n.station_id = l.station_id
  CROSS JOIN LATERAL (
    VALUES
      (n.insp_1,  l.insp_1),
      (n.insp_2,  l.insp_2),
      (n.insp_3,  l.insp_3),
      (n.insp_4,  l.insp_4),
      (n.insp_5,  l.insp_5),
      (n.insp_6,  l.insp_6),
      (n.insp_7,  l.insp_7),
      (n.insp_8,  l.insp_8),
      (n.insp_9,  l.insp_9),
      (n.insp_10, l.insp_10),
      (n.insp_11, l.insp_11),
      (n.insp_12, l.insp_12),
      ('POS_1',  l.pos_1),
      ('POS_2',  l.pos_2),
      ('POS_3',  l.pos_3),
      ('POS_4',  l.pos_4),
      ('POS_5',  l.pos_5),
      ('POS_6',  l.pos_6),
      ('POS_7',  l.pos_7),
      ('POS_8',  l.pos_8),
      ('POS_9',  l.pos_9),
      ('POS_10', l.pos_10),
      ('POS_11', l.pos_11),
      ('POS_12', l.pos_12),
      ('POS_13', l.pos_13),
      ('POS_14', l.pos_14),
      ('POS_15', l.pos_15),
      ('POS_16', l.pos_16)
  ) AS v(label_name, result_bool)
  WHERE 
      v.result_bool IS TRUE
      AND DATE(l.created_at) BETWEEN %s AND %s
  GROUP BY l.station_id, v.label_name
)

-- 🔹 Combine labels with counts + WC_ID
SELECT 
  a.station_id,
  s.workcell_id,  -- <── added from jtc_station
  a.label AS defect_or_position,
  COALESCE(d.total_occurrences, 0) AS total_occurrences
FROM all_labels a
LEFT JOIN defect_counts d
  ON a.label = d.label_name
 AND a.station_id = d.station_id
LEFT JOIN jtc_station s   -- <── new join here
  ON a.station_id = s.id
ORDER BY s.workcell_id, a.station_id, a.label;
