{{ config(alias='MEASURES') }}

select *
from unnest(array<struct<table_name string, measure_name string, sql_expression string, description string>>[
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""maximum_speed_kmh""",
        r"""MAX(t.speed)""",
        r"""Peak sampled speed. Filter the intended observation window; source includes pre/post-race samples."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""average_sample_speed_kmh""",
        r"""AVG(t.speed)""",
        r"""Sample-weighted speed, not time-weighted speed, lap speed, or distance divided by elapsed time."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""maximum_rpm""",
        r"""MAX(t.rpm)""",
        r"""Peak sampled engine rpm."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""average_sample_throttle_pct""",
        r"""AVG(IF(t.throttle BETWEEN 0 AND 100, t.throttle, NULL))""",
        r"""Sample-weighted mean restricted to the documented 0..100 percentage range. Excludes values above 100; report valid_throttle_samples and row_count. Not elapsed time at full throttle."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""braking_sample_fraction""",
        r"""SAFE_DIVIDE(COUNTIF(t.brake = 100), COUNTIF(t.brake IN (0, 100)))""",
        r"""Fraction pressed among documented 0/100 codes only. Excludes undocumented 104 and nulls. Report known_brake_samples and row_count; not elapsed braking time."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""valid_throttle_samples""",
        r"""COUNTIF(t.throttle BETWEEN 0 AND 100)""",
        r"""Sample count used by the range-filtered throttle mean; compare to row_count."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""known_brake_samples""",
        r"""COUNTIF(t.brake IN (0, 100))""",
        r"""Samples whose brake code is documented; denominator for braking_sample_fraction."""
    ),
    (
        r"""{{ target.database }}.f1.car_data""",
        r"""unusual_gear_samples""",
        r"""COUNTIF(t.n_gear NOT BETWEEN 0 AND 8)""",
        r"""Raw samples outside documented gear range. Diagnostic only; do not map them to real gears."""
    ),
    (
        r"""{{ target.database }}.f1.circuits""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.countries""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.driver_standings""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.driver_standings""",
        r"""checkpoint_points""",
        r"""SUM(t.points_current)""",
        r"""SEMI-ADDITIVE: filter to exactly one session checkpoint first. Sum across distinct drivers/teams only; never sum across checkpoints. Do not replace latest points with MAX(points), because adjustments can reduce points. Source snapshot may predate later result corrections."""
    ),
    (
        r"""{{ target.database }}.f1.driver_standings""",
        r"""checkpoint_points_change""",
        r"""SUM(t.points_current - t.points_start)""",
        r"""Change within the recorded before/after checkpoint. Not guaranteed to equal Race result points or cover Sprint points between snapshots; do not call this complete seasonal points earned. Source snapshot may predate later result corrections."""
    ),
    (
        r"""{{ target.database }}.f1.driver_standings""",
        r"""checkpoint_rank""",
        r"""MIN(t.position_current)""",
        r"""Filter to exactly one checkpoint and one driver/team. MIN is a scalar projection at that grain, not a seasonal rank or meaningful rank across entities. Source snapshot may predate later result corrections."""
    ),
    (
        r"""{{ target.database }}.f1.drivers""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.intervals""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.intervals""",
        r"""average_numeric_interval_seconds""",
        r"""AVG(SAFE_CAST(t.interval AS FLOAT64))""",
        r"""Mean numeric gap observations only. Excludes lap/status labels and nulls; sample-weighted, with a potentially biased subset. Always report numeric coverage."""
    ),
    (
        r"""{{ target.database }}.f1.intervals""",
        r"""numeric_interval_count""",
        r"""COUNT(SAFE_CAST(t.interval AS FLOAT64))""",
        r"""Number of gap observations parseable as seconds; compare with row_count to expose lap-label/null exclusions."""
    ),
    (
        r"""{{ target.database }}.f1.intervals""",
        r"""average_numeric_gap_to_leader_seconds""",
        r"""AVG(SAFE_CAST(t.gap_to_leader AS FLOAT64))""",
        r"""Mean numeric gap observations only. Excludes lap/status labels and nulls; sample-weighted, with a potentially biased subset. Always report numeric coverage."""
    ),
    (
        r"""{{ target.database }}.f1.intervals""",
        r"""numeric_gap_to_leader_count""",
        r"""COUNT(SAFE_CAST(t.gap_to_leader AS FLOAT64))""",
        r"""Number of gap observations parseable as seconds; compare with row_count to expose lap-label/null exclusions."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""timed_laps""",
        r"""COUNTIF(t.lap_duration > 0)""",
        r"""Laps with a positive recorded duration; excludes missing and nonpositive timings."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""fastest_lap_seconds""",
        r"""MIN(IF(t.lap_duration > 0, t.lap_duration, NULL))""",
        r"""Minimum positive recorded lap time. Not automatically an official fastest-lap award."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""average_lap_seconds""",
        r"""AVG(IF(t.lap_duration > 0, t.lap_duration, NULL))""",
        r"""Mean positive timed lap, including pit/safety-car effects unless explicitly filtered. Not clean-air pace."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""lap_time_stddev_seconds""",
        r"""STDDEV_POP(IF(t.lap_duration > 0, t.lap_duration, NULL))""",
        r"""Variation in positive lap durations; compare within driver/session and an explicit comparable-lap cohort."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""pit_out_laps""",
        r"""COUNTIF(t.is_pit_out_lap)""",
        r"""Rows explicitly marked as pit-out laps; not the number of stationary pit stops."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""best_duration_sector_1_seconds""",
        r"""MIN(IF(t.duration_sector_1 > 0, t.duration_sector_1, NULL))""",
        r"""Best positive recorded sector time in seconds. Best sectors may come from different laps; their sum is theoretical, not an actual lap."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""best_duration_sector_2_seconds""",
        r"""MIN(IF(t.duration_sector_2 > 0, t.duration_sector_2, NULL))""",
        r"""Best positive recorded sector time in seconds. Best sectors may come from different laps; their sum is theoretical, not an actual lap."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""best_duration_sector_3_seconds""",
        r"""MIN(IF(t.duration_sector_3 > 0, t.duration_sector_3, NULL))""",
        r"""Best positive recorded sector time in seconds. Best sectors may come from different laps; their sum is theoretical, not an actual lap."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""max_i_1_speed_kmh""",
        r"""MAX(t.i_1_speed)""",
        r"""Highest recorded trap speed in km/h; not an average lap speed."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""max_i_2_speed_kmh""",
        r"""MAX(t.i_2_speed)""",
        r"""Highest recorded trap speed in km/h; not an average lap speed."""
    ),
    (
        r"""{{ target.database }}.f1.laps""",
        r"""max_st_speed_kmh""",
        r"""MAX(t.st_speed)""",
        r"""Highest recorded trap speed in km/h; not an average lap speed."""
    ),
    (
        r"""{{ target.database }}.f1.location""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.meetings""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.overtakes""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""average_lane_duration_seconds""",
        r"""AVG(IF(t.lane_duration > 0, t.lane_duration, NULL))""",
        r"""AVG of positive recorded lane_duration in seconds. Null/nonpositive values are excluded. Keep lane transit and stationary stop separate; not race time lost to a pit strategy."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""fastest_lane_duration_seconds""",
        r"""MIN(IF(t.lane_duration > 0, t.lane_duration, NULL))""",
        r"""MIN of positive recorded lane_duration in seconds. Null/nonpositive values are excluded. Keep lane transit and stationary stop separate; not race time lost to a pit strategy."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""total_lane_duration_seconds""",
        r"""SUM(IF(t.lane_duration > 0, t.lane_duration, NULL))""",
        r"""SUM of positive recorded lane_duration in seconds. Null/nonpositive values are excluded. Keep lane transit and stationary stop separate; not race time lost to a pit strategy."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""average_stop_duration_seconds""",
        r"""AVG(IF(t.stop_duration > 0, t.stop_duration, NULL))""",
        r"""AVG of positive recorded stop_duration in seconds. Null/nonpositive values are excluded. Keep lane transit and stationary stop separate; not race time lost to a pit strategy."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""fastest_stop_duration_seconds""",
        r"""MIN(IF(t.stop_duration > 0, t.stop_duration, NULL))""",
        r"""MIN of positive recorded stop_duration in seconds. Null/nonpositive values are excluded. Keep lane transit and stationary stop separate; not race time lost to a pit strategy."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""total_stop_duration_seconds""",
        r"""SUM(IF(t.stop_duration > 0, t.stop_duration, NULL))""",
        r"""SUM of positive recorded stop_duration in seconds. Null/nonpositive values are excluded. Keep lane transit and stationary stop separate; not race time lost to a pit strategy."""
    ),
    (
        r"""{{ target.database }}.f1.pit""",
        r"""timed_stationary_stops""",
        r"""COUNTIF(t.stop_duration > 0)""",
        r"""Positive stationary timings available, not total pit visits. In the 2025 profile, 702 of 821 visits; report this coverage with stop-time aggregates."""
    ),
    (
        r"""{{ target.database }}.f1.position""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.position""",
        r"""best_observed_position""",
        r"""MIN(t.position)""",
        r"""Best sampled running rank; not finishing rank. Observation counts do not measure laps or time led."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.race_control""",
        r"""flag_message_count""",
        r"""COUNTIF(t.flag IS NOT NULL)""",
        r"""Messages carrying a flag. Not the number or duration of safety-car/red-flag incidents; reconstruct event intervals first."""
    ),
    (
        r"""{{ target.database }}.f1.session_entries""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.session_entries""",
        r"""distinct_drivers""",
        r"""COUNT(DISTINCT t.driver_id)""",
        r"""People represented by entries in the selected scope; not race starts. Non-additive across races or teams."""
    ),
    (
        r"""{{ target.database }}.f1.session_entries""",
        r"""distinct_teams""",
        r"""COUNT(DISTINCT t.team_id)""",
        r"""Teams represented by entries in the selected scope; non-additive across sessions."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""race_points""",
        r"""SUM(t.points)""",
        r"""Grand Prix result points; additive across entries and races. Sprint points are not included, so this need not equal championship totals."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""wins""",
        r"""COUNTIF(t.position = 1 AND NOT COALESCE(t.dsq, FALSE))""",
        r"""Classified wins in the selected Race results."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""podiums""",
        r"""COUNTIF(t.position BETWEEN 1 AND 3 AND NOT COALESCE(t.dsq, FALSE))""",
        r"""Classified top-three Race results."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""dnf_count""",
        r"""COUNTIF(t.dnf)""",
        r"""Results explicitly marked DNF; nulls are not counted."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""dns_count""",
        r"""COUNTIF(t.dns)""",
        r"""Results explicitly marked DNS; do not equate entries to starts."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""dsq_count""",
        r"""COUNTIF(t.dsq)""",
        r"""Results explicitly marked DSQ; flags can overlap other classifications."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""completed_laps""",
        r"""SUM(t.number_of_laps)""",
        r"""Driver-laps completed according to results. Across drivers this is not the race distance in laps."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""average_finish_position""",
        r"""AVG(t.position)""",
        r"""Mean available classified rank across selected results; not additive. State treatment of DNS/DNF/DSQ."""
    ),
    (
        r"""{{ target.database }}.f1.session_result""",
        r"""average_result_duration_seconds""",
        r"""AVG(t.duration)""",
        r"""Mean available source Race duration; comparisons require comparable race lengths and classification. Not sum of lap samples."""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.sessions""",
        r"""grand_prix_count""",
        r"""COUNTIF(t.session_name = 'Race' AND NOT COALESCE(t.is_cancelled, FALSE))""",
        r"""Scheduled noncancelled main Race sessions; excludes Sprint and testing. Consult sync_status before assuming detail is complete."""
    ),
    (
        r"""{{ target.database }}.f1.starting_grid""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.starting_grid""",
        r"""best_qualifying_lap_seconds""",
        r"""MIN(IF(t.lap_duration > 0, t.lap_duration, NULL))""",
        r"""Minimum positive lap duration supplied on the Qualifying-keyed grid. Not a full qualifying-lap history."""
    ),
    (
        r"""{{ target.database }}.f1.starting_grid""",
        r"""average_grid_position""",
        r"""AVG(t.position)""",
        r"""Mean source qualifying-grid position. Later penalties/pit-lane starts may differ."""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""average_reported_span_laps""",
        r"""AVG(IF(t.lap_end >= t.lap_start, t.lap_end - t.lap_start + 1, NULL))""",
        r"""Mean inclusive reported stint span. Boundaries overlap in this dataset; do not sum spans as distinct laps or use an unchecked many-one lap join."""
    ),
    (
        r"""{{ target.database }}.f1.stints""",
        r"""average_starting_tyre_age_laps""",
        r"""AVG(t.tyre_age_at_start)""",
        r"""Mean source tyre age at stint start, not total tyre life."""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""unavailable_scope_count""",
        r"""COUNTIF(t.status = 'unavailable_404')""",
        r"""Scopes reported unavailable by HTTP 404. Does not imply zero source activity."""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""reported_source_rows""",
        r"""SUM(t.row_count)""",
        r"""Sum disjoint completed scopes within one endpoint only; different endpoints have incompatible grains. Not a total number of F1 events."""
    ),
    (
        r"""{{ target.database }}.f1.sync_status""",
        r"""latest_scope_completion""",
        r"""MAX(t.completed_at)""",
        r"""Latest availability timestamp among selected scopes; other scopes may be older or unavailable."""
    ),
    (
        r"""{{ target.database }}.f1.team_radio""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.team_sessions""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.team_standings""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.team_standings""",
        r"""checkpoint_points""",
        r"""SUM(t.points_current)""",
        r"""SEMI-ADDITIVE: filter to exactly one session checkpoint first. Sum across distinct drivers/teams only; never sum across checkpoints. Do not replace latest points with MAX(points), because adjustments can reduce points. Source snapshot may predate later result corrections."""
    ),
    (
        r"""{{ target.database }}.f1.team_standings""",
        r"""checkpoint_points_change""",
        r"""SUM(t.points_current - t.points_start)""",
        r"""Change within the recorded before/after checkpoint. Not guaranteed to equal Race result points or cover Sprint points between snapshots; do not call this complete seasonal points earned. Source snapshot may predate later result corrections."""
    ),
    (
        r"""{{ target.database }}.f1.team_standings""",
        r"""checkpoint_rank""",
        r"""MIN(t.position_current)""",
        r"""Filter to exactly one checkpoint and one driver/team. MIN is a scalar projection at that grain, not a seasonal rank or meaningful rank across entities. Source snapshot may predate later result corrections."""
    ),
    (
        r"""{{ target.database }}.f1.teams""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of rows at this table's stated primary-key grain after its row_filter. Aggregate before any one-many expansion; never infer events from an unavailable scope."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""average_sample_air_temperature""",
        r"""AVG(t.air_temperature)""",
        r"""Sample-weighted mean in the units documented on the dimension. Not time-weighted; weather is session-level, independent of driver samples."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""average_sample_track_temperature""",
        r"""AVG(t.track_temperature)""",
        r"""Sample-weighted mean in the units documented on the dimension. Not time-weighted; weather is session-level, independent of driver samples."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""average_sample_humidity""",
        r"""AVG(t.humidity)""",
        r"""Sample-weighted mean in the units documented on the dimension. Not time-weighted; weather is session-level, independent of driver samples."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""average_sample_pressure""",
        r"""AVG(t.pressure)""",
        r"""Sample-weighted mean in the units documented on the dimension. Not time-weighted; weather is session-level, independent of driver samples."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""average_sample_wind_speed""",
        r"""AVG(t.wind_speed)""",
        r"""Sample-weighted mean in the units documented on the dimension. Not time-weighted; weather is session-level, independent of driver samples."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""rainy_sample_fraction""",
        r"""SAFE_DIVIDE(COUNTIF(t.rainfall = 1), COUNT(t.rainfall))""",
        r"""Fraction of nonnull observations flagged as rain. Not rainfall depth or percentage of elapsed race time."""
    ),
    (
        r"""{{ target.database }}.f1.weather""",
        r"""maximum_track_temperature_c""",
        r"""MAX(t.track_temperature)""",
        r"""Maximum recorded track temperature in degrees Celsius."""
    ),
    (
        r"""{{ target.database }}.f1.transcript_passages_search""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of chunks, not documents, rules, utterances or incidents."""
    ),
    (
        r"""{{ target.database }}.f1.regulation_passages_search""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of chunks, not documents, rules, utterances or incidents."""
    ),
    (
        r"""{{ target.database }}.f1.glossary_passages_search""",
        r"""row_count""",
        r"""COUNT(*)""",
        r"""Number of chunks, not documents, rules, utterances or incidents."""
    ),
    (
        r"""{{ target.database }}.f1.transcript_passages_search""",
        r"""document_count""",
        r"""COUNT(DISTINCT t.document_id)""",
        r"""Distinct source documents represented by these chunks."""
    ),
    (
        r"""{{ target.database }}.f1.regulation_passages_search""",
        r"""document_count""",
        r"""COUNT(DISTINCT t.document_id)""",
        r"""Distinct source documents represented by these chunks."""
    ),
    (
        r"""{{ target.database }}.f1.glossary_passages_search""",
        r"""document_count""",
        r"""COUNT(DISTINCT t.document_id)""",
        r"""Distinct source documents represented by these chunks."""
    ),
    (
        r"""{{ target.database }}.f1.transcript_passages_search""",
        r"""source_block_count""",
        r"""COUNT(DISTINCT TO_JSON_STRING(STRUCT(t.document_id, t.source_position)))""",
        r"""Distinct original text blocks; one block can contain multiple search chunks."""
    ),
    (
        r"""{{ target.database }}.f1.regulation_passages_search""",
        r"""source_block_count""",
        r"""COUNT(DISTINCT TO_JSON_STRING(STRUCT(t.document_id, t.source_position)))""",
        r"""Distinct original text blocks; one block can contain multiple search chunks."""
    ),
    (
        r"""{{ target.database }}.f1.glossary_passages_search""",
        r"""source_block_count""",
        r"""COUNT(DISTINCT TO_JSON_STRING(STRUCT(t.document_id, t.source_position)))""",
        r"""Distinct original text blocks; one block can contain multiple search chunks."""
    ),
    (
        r"""{{ target.database }}.f1.transcript_passages_search""",
        r"""embedding_ready_count""",
        r"""COUNTIF(t.embedding.status = '' AND ARRAY_LENGTH(t.embedding.result) = 768)""",
        r"""Chunks with a usable 768-dimensional embedding; compare with row_count to assess search coverage."""
    ),
    (
        r"""{{ target.database }}.f1.regulation_passages_search""",
        r"""embedding_ready_count""",
        r"""COUNTIF(t.embedding.status = '' AND ARRAY_LENGTH(t.embedding.result) = 768)""",
        r"""Chunks with a usable 768-dimensional embedding; compare with row_count to assess search coverage."""
    ),
    (
        r"""{{ target.database }}.f1.glossary_passages_search""",
        r"""embedding_ready_count""",
        r"""COUNTIF(t.embedding.status = '' AND ARRAY_LENGTH(t.embedding.result) = 768)""",
        r"""Chunks with a usable 768-dimensional embedding; compare with row_count to assess search coverage."""
    ),
    (
        r"""{{ target.database }}.f1.transcript_passages_search""",
        r"""embedding_error_count""",
        r"""COUNTIF(t.embedding.status != '')""",
        r"""Chunks whose embedding status reports an error; these lack a successful semantic representation."""
    ),
    (
        r"""{{ target.database }}.f1.regulation_passages_search""",
        r"""embedding_error_count""",
        r"""COUNTIF(t.embedding.status != '')""",
        r"""Chunks whose embedding status reports an error; these lack a successful semantic representation."""
    ),
    (
        r"""{{ target.database }}.f1.glossary_passages_search""",
        r"""embedding_error_count""",
        r"""COUNTIF(t.embedding.status != '')""",
        r"""Chunks whose embedding status reports an error; these lack a successful semantic representation."""
    )
])
