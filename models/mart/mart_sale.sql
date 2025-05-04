with final as (
    select * from {{ ref("sale") }}
)
select * from final
