with final as (
  select
    cast(id as integer) as id,
    name,
    address
  from
    {{ source("source", "vending_machine") }}
)
select * from final
