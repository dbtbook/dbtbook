with final as (
    select * from {{ ref("sale") }}
    where saled_at >= '{{ var("start_date") }}'
)
select * from final
