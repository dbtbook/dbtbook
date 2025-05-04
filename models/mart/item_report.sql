with final as (
  select
    cast(s.saled_at as date) as sale_dt,
    s.item_id,
    i.name as item_name,
    count(s.item_id) as amount,
    sum(i.price) as total
  from
    {{ ref("sale") }} as s
  inner join
    {{ ref("item") }} as i
  on
    i.id = s.item_id
  group by
    cast(s.saled_at as date),
    s.item_id,
    i.name
)
select * from final
