{{
    config(
        materialized='incremental'
    )
}}

with final as (
  select
    cast(id as integer) as id,
    cast(vending_machine_id as integer) as vending_machine_id,
    cast(item_id as integer) as item_id,
    cast(saled_at as timestamp) as saled_at
  from
    {{ source("source", "s_sale") }}
{% if is_incremental() %}
  where
    cast(saled_at as timestamp) > (
      select max(saled_at) from {{ this }}
    )
{% endif %}
)
select * from final
