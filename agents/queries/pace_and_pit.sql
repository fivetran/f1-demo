-- Aggregate independent facts before combining; joining raw laps to raw pit visits inflates both.
WITH pace AS (
  SELECT session_key, driver_number,
    AVG(IF(lap_duration > 0, lap_duration, NULL)) AS average_recorded_lap_seconds,
    COUNT(*) AS lap_rows
  FROM `__F1_GCP_PROJECT__.f1.laps` GROUP BY 1, 2
), stops AS (
  SELECT session_key, driver_number, COUNT(*) AS pit_visits,
    AVG(IF(stop_duration > 0, stop_duration, NULL)) AS average_stationary_stop_seconds
  FROM `__F1_GCP_PROJECT__.f1.pit` GROUP BY 1, 2
)
SELECT e.session_key, e.driver_id, e.team_id, pace.lap_rows,
  pace.average_recorded_lap_seconds, COALESCE(stops.pit_visits, 0) AS pit_visits,
  stops.average_stationary_stop_seconds
FROM `__F1_GCP_PROJECT__.f1.session_entries` AS e
LEFT JOIN pace USING (session_key, driver_number)
LEFT JOIN stops USING (session_key, driver_number)
-- Zero pit visits is justified only for scopes explicitly completed as available.
JOIN `__F1_GCP_PROJECT__.f1.sync_status` AS coverage
  ON e.session_key = coverage.session_key AND coverage.endpoint = 'pit'
  AND coverage.status = 'available' AND coverage.driver_number IS NULL
