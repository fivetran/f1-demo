{% macro publish_agents_after_run(results) %}
    {% set names = ['root', 'tables', 'dimensions', 'measures', 'joins'] %}
    {% set batch = namespace(loaded=0, failed=false) %}
    {% for result in results %}
        {% if result.status not in ['success', 'pass'] %}
            {% set batch.failed = true %}
        {% endif %}
        {% if result.node.resource_type == 'seed' and result.node.name in
            ['agents_root', 'agents_tables', 'agents_dimensions', 'agents_measures', 'agents_joins'] %}
            {% set batch.loaded = batch.loaded + 1 %}
        {% endif %}
    {% endfor %}
    {% if batch.loaded == 0 or batch.failed %}
        {{ return('select 1 /* No successful catalog seed batch to publish. */') }}
    {% endif %}
    {% if batch.loaded != 5 %}
        {{ exceptions.raise_compiler_error('Publish all five seeds with --select tag:agents_schema.') }}
    {% endif %}

    {# Decode CSV values and capture one consistent batch before publishing. #}
    {% for name in names %}
        create temp table agents_{{ name }} as
        select *
        {% if name == 'root' %}
            replace(replace(json_value(content), '__F1_GCP_PROJECT__', '{{ target.database }}') as content)
        {% elif name == 'tables' %}
            replace(json_value_array(primary_key) as primary_key,
                    replace(table_name, '__F1_GCP_PROJECT__', '{{ target.database }}') as table_name)
        {% elif name == 'joins' %}
            replace(replace(from_table, '__F1_GCP_PROJECT__', '{{ target.database }}') as from_table,
                    replace(to_table, '__F1_GCP_PROJECT__', '{{ target.database }}') as to_table)
        {% else %}
            replace(replace(table_name, '__F1_GCP_PROJECT__', '{{ target.database }}') as table_name)
        {% endif %}
        from {{ ref('agents_' ~ name) }};
    {% endfor %}

    create schema if not exists `{{ target.database }}.AGENTS` options(location='US');
    {% for name in names %}
        create table if not exists `{{ target.database }}.AGENTS.{{ name | upper }}`
        options(labels=[('publisher', 'f1-demo-agents')])
        as select * from agents_{{ name }} where false;
    {% endfor %}

    -- Keep table identity/BI Engine preferences and other ROOT providers intact.
    begin transaction;
    {% for name in names %}
        delete from `{{ target.database }}.AGENTS.{{ name | upper }}`
        where {% if name == 'root' %}provider = 'f1'{% else %}true{% endif %};
        insert into `{{ target.database }}.AGENTS.{{ name | upper }}`
        select * from agents_{{ name }};
    {% endfor %}
    commit transaction;
{% endmacro %}
