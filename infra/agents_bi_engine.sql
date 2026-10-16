-- Project/location infrastructure, deliberately outside dbt model builds.
-- 1 GiB is the minimum BI Engine reservation. This incurs ongoing capacity charges.
-- Apply only when establishing this project's dedicated AGENTS reservation;
-- SET OPTIONS replaces any existing size/preferred-table list.
ALTER BI_CAPACITY `__F1_GCP_PROJECT__.region-us.default`
SET OPTIONS (
  size_gb = 1,
  preferred_tables = [
    '__F1_GCP_PROJECT__.AGENTS.ROOT',
    '__F1_GCP_PROJECT__.AGENTS.TABLES',
    '__F1_GCP_PROJECT__.AGENTS.DIMENSIONS',
    '__F1_GCP_PROJECT__.AGENTS.MEASURES',
    '__F1_GCP_PROJECT__.AGENTS.JOINS'
  ]
);
