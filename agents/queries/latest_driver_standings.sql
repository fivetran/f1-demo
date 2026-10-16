-- Choose latest available checkpoint by event time, never the maximum points value.
WITH checkpoint AS (
  SELECT s.session_key
  FROM `__F1_GCP_PROJECT__.f1.sessions` AS s
  WHERE EXISTS (SELECT 1 FROM `__F1_GCP_PROJECT__.f1.driver_standings` AS p
                WHERE p.session_key = s.session_key)
  ORDER BY s.date_start DESC, s.session_key DESC LIMIT 1
)
SELECT p.session_key, p.driver_id, d.full_name, p.points_current, p.position_current
FROM `__F1_GCP_PROJECT__.f1.driver_standings` AS p
JOIN checkpoint USING (session_key)
JOIN `__F1_GCP_PROJECT__.f1.drivers` AS d USING (driver_id)
ORDER BY p.position_current
