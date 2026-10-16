{% macro assert_analytics_target() %}
    {% if target.schema != 'f1' or target.database != env_var('F1_GCP_PROJECT') %}
        {{ exceptions.raise_compiler_error('Normalized models must target the configured F1_GCP_PROJECT and f1 dataset; source datasets must never be dbt targets.') }}
    {% endif %}
    {% set retention = namespace(needed=false) %}
    {% for resource in selected_resources %}
        {% if resource in ['model.f1_demo.car_data', 'model.f1_demo.location', 'model.f1_demo.intervals', 'model.f1_demo.position'] %}
            {% set retention.needed = true %}
        {% endif %}
    {% endfor %}
    {% if not retention.needed %}
        {{ return('select 1 /* No historical time-series rebuild selected. */') }}
    {% endif %}
    {# Historical samples must not inherit the dataset's old 60-day retention. #}
    alter schema `{{ target.database }}.{{ target.schema }}`
        set options (default_partition_expiration_days = null, default_table_expiration_days = null);
    {% for table in ['car_data', 'location', 'intervals', 'position'] %}
    alter table if exists `{{ target.database }}.{{ target.schema }}.{{ table }}`
        set options (partition_expiration_days = null);
    {% endfor %}
{% endmacro %}
