with final as (
  select
    cast(s.saled_at as date) as sale_dt,
    s.vending_machine_id,
    v.name as item_name,
    count(s.item_id) as amount,
    sum(i.price) as total
  from
    {{ ref("sale") }} as s
  inner join
    {{ ref("vending_machine") }} as v
  on
    v.id = s.vending_machine_id
  inner join
    {{ ref("item") }} as i
  on
    i.id = s.item_id
  group by
    cast(s.saled_at as date),
    s.vending_machine_id,
    v.name
)
select * from final
