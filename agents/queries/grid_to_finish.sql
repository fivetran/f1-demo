-- Each output row is one published grid entry, including entrants with no Race result.
SELECT g.session_key AS qualifying_session_key, g.driver_id, race.session_key AS race_session_key,
  d.full_name, g.position AS grid_position, result.position AS finish_position,
  g.position - result.position AS positions_gained,
  result.driver_number AS result_driver_number, result.dnf, result.dns, result.dsq
FROM `__F1_GCP_PROJECT__.f1.starting_grid` AS g
JOIN `__F1_GCP_PROJECT__.f1.sessions` AS q ON g.session_key = q.session_key
LEFT JOIN `__F1_GCP_PROJECT__.f1.sessions` AS race
  ON q.meeting_key = race.meeting_key
  AND q.session_name = 'Qualifying' AND NOT COALESCE(q.is_cancelled, FALSE)
  AND race.session_name = 'Race' AND NOT COALESCE(race.is_cancelled, FALSE)
LEFT JOIN `__F1_GCP_PROJECT__.f1.session_entries` AS e
  ON race.session_key = e.session_key AND g.driver_id = e.driver_id
LEFT JOIN `__F1_GCP_PROJECT__.f1.session_result` AS result
  ON e.session_key = result.session_key AND e.driver_number = result.driver_number
JOIN `__F1_GCP_PROJECT__.f1.drivers` AS d ON g.driver_id = d.driver_id
ORDER BY qualifying_session_key, grid_position
