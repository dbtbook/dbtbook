with final as (
  select
    cast(id as integer) as id,
    name,
    cast(price as integer) as price
  from
    {{ source("source", "item") }}
)
select * from final
