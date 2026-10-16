-- Diagnostics only: this many-many range match is intentionally absent from AGENTS.JOINS.
SELECT COUNTIF(stint_matches > 1) AS ambiguous_laps,
  COUNTIF(stint_matches = 0) AS unmatched_laps, COUNT(*) AS lap_rows
FROM (
  SELECT l.session_key, l.driver_number, l.lap_number, COUNT(s.stint_number) AS stint_matches
  FROM `__F1_GCP_PROJECT__.f1.laps` AS l
  LEFT JOIN `__F1_GCP_PROJECT__.f1.stints` AS s
    ON l.session_key = s.session_key AND l.driver_number = s.driver_number
    AND l.lap_number BETWEEN s.lap_start AND s.lap_end
  GROUP BY 1, 2, 3
)
