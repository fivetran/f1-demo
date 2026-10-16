# Delivered BigQuery schema

Project: `__F1_GCP_PROJECT__`. Observed: 2026-10-11T21:17:22.364203+00:00.

Schemas and counts below are read from BigQuery. Keys are connector upsert keys; BigQuery does not enforce them.

Fivetran adds `_fivetran_synced` and `_fivetran_deleted`. Filter deleted rows in downstream queries.

Validation: passed

## Endpoint coverage

HTTP 404 means source data is unavailable; it does not mean no activity occurred.

| Endpoint | Availability | Request scopes | Source rows |
|---|---|---:|---:|
| `car_data` | available | 479 | 16,395,014 |
| `championship_drivers` | available | 24 | 498 |
| `championship_teams` | available | 24 | 240 |
| `drivers` | available | 24 | 479 |
| `intervals` | available | 24 | 586,192 |
| `laps` | available | 24 | 26,265 |
| `location` | available | 479 | 16,847,473 |
| `meetings` | available | 1 | 25 |
| `overtakes` | available | 24 | 5,855 |
| `pit` | available | 24 | 821 |
| `position` | available | 24 | 11,564 |
| `race_control` | available | 24 | 2,216 |
| `session_result` | available | 24 | 479 |
| `sessions` | available | 1 | 123 |
| `starting_grid` | available | 24 | 480 |
| `stints` | available | 24 | 1,318 |
| `team_radio` | available | 24 | 765 |
| `weather` | available | 24 | 3,760 |

## f1_openf1.car_data

16,395,014 active rows. Key: `session_key`, `driver_number`, `date`.

| Column | BigQuery type |
|---|---|
| `date` | TIMESTAMP |
| `driver_number` | INTEGER |
| `session_key` | INTEGER |
| `brake` | INTEGER |
| `drs` | INTEGER |
| `meeting_key` | INTEGER |
| `n_gear` | INTEGER |
| `rpm` | INTEGER |
| `speed` | INTEGER |
| `throttle` | INTEGER |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_openf1.championship_drivers

498 active rows. Key: `session_key`, `driver_number`.

| Column | BigQuery type |
|---|---|
| `driver_number` | INTEGER |
| `session_key` | INTEGER |
| `meeting_key` | INTEGER |
| `points_current` | FLOAT |
| `points_start` | FLOAT |
| `position_current` | INTEGER |
| `position_start` | INTEGER |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_openf1.championship_teams

240 active rows. Key: `session_key`, `team_name`.

| Column | BigQuery type |
|---|---|
| `session_key` | INTEGER |
| `team_name` | STRING |
| `meeting_key` | INTEGER |
| `points_current` | FLOAT |
| `points_start` | FLOAT |
| `position_current` | INTEGER |
| `position_start` | INTEGER |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_openf1.drivers

479 active rows. Key: `session_key`, `driver_number`.

| Column | BigQuery type |
|---|---|
| `driver_number` | INTEGER |
| `session_key` | INTEGER |
| `broadcast_name` | STRING |
| `country_code` | STRING |
| `first_name` | STRING |
| `full_name` | STRING |
| `headshot_url` | STRING |
| `last_name` | STRING |
| `meeting_key` | INTEGER |
| `name_acronym` | STRING |
| `team_colour` | STRING |
| `team_name` | STRING |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_openf1.intervals

586,192 active rows. Key: `session_key`, `driver_number`, `date`.

| Column | BigQuery type |
|---|---|
| `date` | TIMESTAMP |
| `driver_number` | INTEGER |
| `session_key` | INTEGER |
| `gap_to_leader` | STRING |
| `interval` | STRING |
| `meeting_key` | INTEGER |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_openf1.laps

26,265 active rows. Key: `session_key`, `driver_number`, `lap_number`.

| Column | BigQuery type |
|---|---|
| `driver_number` | INTEGER |
| `lap_number` | INTEGER |
| `session_key` | INTEGER |
| `date_start` | TIMESTAMP |
| `duration_sector_1` | FLOAT |
| `duration_sector_2` | FLOAT |
| `duration_sector_3` | FLOAT |
| `i_1_speed` | INTEGER |
| `i_2_speed` | INTEGER |
| `is_pit_out_lap` | BOOLEAN |
| `lap_duration` | FLOAT |
| `meeting_key` | INTEGER |
| `segments_sector_1` | JSON |
| `segments_sector_2` | JSON |
| `segments_sector_3` | JSON |
| `st_speed` | INTEGER |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_openf1.location

16,847,473 active rows. Key: `session_key`, `driver_number`, `date`.

| Column | BigQuery type |
|---|---|
| `date` | TIMESTAMP |
| `driver_number` | INTEGER |
| `session_key` | INTEGER |
| `meeting_key` | INTEGER |
| `x` | INTEGER |
| `y` | INTEGER |
| `z` | INTEGER |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_openf1.meetings

25 active rows. Key: `meeting_key`.

| Column | BigQuery type |
|---|---|
| `meeting_key` | INTEGER |
| `circuit_key` | INTEGER |
| `circuit_image` | STRING |
| `circuit_info_url` | STRING |
| `circuit_short_name` | STRING |
| `circuit_type` | STRING |
| `country_code` | STRING |
| `country_flag` | STRING |
| `country_key` | INTEGER |
| `country_name` | STRING |
| `date_end` | TIMESTAMP |
| `date_start` | TIMESTAMP |
| `gmt_offset` | STRING |
| `is_cancelled` | BOOLEAN |
| `location` | STRING |
| `meeting_name` | STRING |
| `meeting_official_name` | STRING |
| `year` | INTEGER |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_openf1.overtakes

5,855 active rows. Key: `session_key`, `date`, `overtaking_driver_number`, `overtaken_driver_number`.

| Column | BigQuery type |
|---|---|
| `date` | TIMESTAMP |
| `overtaken_driver_number` | INTEGER |
| `overtaking_driver_number` | INTEGER |
| `session_key` | INTEGER |
| `meeting_key` | INTEGER |
| `position` | INTEGER |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_openf1.pit

821 active rows. Key: `session_key`, `driver_number`, `date`.

| Column | BigQuery type |
|---|---|
| `date` | TIMESTAMP |
| `driver_number` | INTEGER |
| `session_key` | INTEGER |
| `lane_duration` | FLOAT |
| `lap_number` | INTEGER |
| `meeting_key` | INTEGER |
| `pit_duration` | FLOAT |
| `stop_duration` | FLOAT |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_openf1.position

11,564 active rows. Key: `session_key`, `driver_number`, `date`.

| Column | BigQuery type |
|---|---|
| `date` | TIMESTAMP |
| `driver_number` | INTEGER |
| `session_key` | INTEGER |
| `meeting_key` | INTEGER |
| `position` | INTEGER |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_openf1.race_control

2,216 active rows. Key: `session_key`, `message_id`.

| Column | BigQuery type |
|---|---|
| `message_id` | STRING |
| `session_key` | INTEGER |
| `category` | STRING |
| `date` | TIMESTAMP |
| `driver_number` | INTEGER |
| `flag` | STRING |
| `lap_number` | INTEGER |
| `meeting_key` | INTEGER |
| `message` | STRING |
| `qualifying_phase` | STRING |
| `scope` | STRING |
| `sector` | INTEGER |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_openf1.sessions

123 active rows. Key: `session_key`.

| Column | BigQuery type |
|---|---|
| `session_key` | INTEGER |
| `circuit_key` | INTEGER |
| `circuit_short_name` | STRING |
| `country_code` | STRING |
| `country_key` | INTEGER |
| `country_name` | STRING |
| `date_end` | TIMESTAMP |
| `date_start` | TIMESTAMP |
| `gmt_offset` | STRING |
| `is_cancelled` | BOOLEAN |
| `location` | STRING |
| `meeting_key` | INTEGER |
| `session_name` | STRING |
| `session_type` | STRING |
| `year` | INTEGER |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_openf1.session_result

479 active rows. Key: `session_key`, `driver_number`.

| Column | BigQuery type |
|---|---|
| `driver_number` | INTEGER |
| `session_key` | INTEGER |
| `dnf` | BOOLEAN |
| `dns` | BOOLEAN |
| `dsq` | BOOLEAN |
| `duration` | FLOAT |
| `gap_to_leader` | STRING |
| `number_of_laps` | INTEGER |
| `meeting_key` | INTEGER |
| `position` | INTEGER |
| `points` | FLOAT |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_openf1.starting_grid

480 active rows. Key: `session_key`, `driver_number`.

| Column | BigQuery type |
|---|---|
| `session_key` | INTEGER |
| `driver_number` | INTEGER |
| `lap_duration` | FLOAT |
| `meeting_key` | INTEGER |
| `position` | INTEGER |
| `_fivetran_synced` | TIMESTAMP |
| `_fivetran_deleted` | BOOLEAN |

## f1_openf1.stints

1,318 active rows. Key: `session_key`, `driver_number`, `stint_number`.

| Column | BigQuery type |
|---|---|
| `driver_number` | INTEGER |
| `session_key` | INTEGER |
| `stint_number` | INTEGER |
| `compound` | STRING |
| `lap_end` | INTEGER |
| `lap_start` | INTEGER |
| `meeting_key` | INTEGER |
| `tyre_age_at_start` | INTEGER |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_openf1.team_radio

765 active rows. Key: `session_key`, `driver_number`, `date`, `recording_url`.

| Column | BigQuery type |
|---|---|
| `date` | TIMESTAMP |
| `driver_number` | INTEGER |
| `recording_url` | STRING |
| `session_key` | INTEGER |
| `meeting_key` | INTEGER |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_openf1.weather

3,760 active rows. Key: `session_key`, `date`.

| Column | BigQuery type |
|---|---|
| `date` | TIMESTAMP |
| `session_key` | INTEGER |
| `air_temperature` | FLOAT |
| `humidity` | FLOAT |
| `meeting_key` | INTEGER |
| `pressure` | FLOAT |
| `rainfall` | INTEGER |
| `track_temperature` | FLOAT |
| `wind_direction` | INTEGER |
| `wind_speed` | FLOAT |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_openf1.sync_status

1,296 active rows. Key: `endpoint`, `scope`.

| Column | BigQuery type |
|---|---|
| `endpoint` | STRING |
| `scope` | STRING |
| `session_key` | INTEGER |
| `driver_number` | INTEGER |
| `status` | STRING |
| `row_count` | INTEGER |
| `completed_at` | TIMESTAMP |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_documents.transcripts

102 active rows. Key: `document_id`.

| Column | BigQuery type |
|---|---|
| `document_id` | STRING |
| `source_url` | STRING |
| `title` | STRING |
| `published_at` | STRING |
| `content_hash` | STRING |
| `source_hash` | STRING |
| `parser_version` | STRING |
| `full_text` | STRING |
| `section_count` | INTEGER |
| `meeting_key` | INTEGER |
| `race_name` | STRING |
| `conference_type` | STRING |
| `association_method` | STRING |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_documents.transcript_passages

7,720 active rows. Key: `document_id`, `position`.

| Column | BigQuery type |
|---|---|
| `document_id` | STRING |
| `position` | INTEGER |
| `text` | STRING |
| `question` | STRING |
| `speaker` | STRING |
| `section` | STRING |
| `page_number` | INTEGER |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_documents.regulations

8 active rows. Key: `document_id`.

| Column | BigQuery type |
|---|---|
| `document_id` | STRING |
| `source_url` | STRING |
| `title` | STRING |
| `published_at` | STRING |
| `content_hash` | STRING |
| `source_hash` | STRING |
| `parser_version` | STRING |
| `full_text` | STRING |
| `section_count` | INTEGER |
| `applicable_season` | INTEGER |
| `rule_family` | STRING |
| `applicability_status` | STRING |
| `effective_from` | STRING |
| `effective_to` | STRING |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_documents.regulation_sections

4,645 active rows. Key: `document_id`, `position`.

| Column | BigQuery type |
|---|---|
| `document_id` | STRING |
| `position` | INTEGER |
| `text` | STRING |
| `question` | STRING |
| `speaker` | STRING |
| `section` | STRING |
| `page_number` | INTEGER |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_documents.glossary

5 active rows. Key: `document_id`.

| Column | BigQuery type |
|---|---|
| `document_id` | STRING |
| `source_url` | STRING |
| `title` | STRING |
| `published_at` | STRING |
| `content_hash` | STRING |
| `source_hash` | STRING |
| `parser_version` | STRING |
| `full_text` | STRING |
| `section_count` | INTEGER |
| `applicability_status` | STRING |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_documents.glossary_sections

799 active rows. Key: `document_id`, `position`.

| Column | BigQuery type |
|---|---|
| `document_id` | STRING |
| `position` | INTEGER |
| `text` | STRING |
| `question` | STRING |
| `speaker` | STRING |
| `section` | STRING |
| `page_number` | INTEGER |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |

## f1_documents.fetch_status

115 active rows. Key: `source_url`.

| Column | BigQuery type |
|---|---|
| `source_url` | STRING |
| `status` | STRING |
| `detail` | STRING |
| `checked_at` | TIMESTAMP |
| `_fivetran_deleted` | BOOLEAN |
| `_fivetran_synced` | TIMESTAMP |
