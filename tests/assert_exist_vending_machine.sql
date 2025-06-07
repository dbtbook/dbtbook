select s.id
from {{ source("source", "sale") }} s
where not exists (
    select * from {{ ref("vending_machine") }} as vm
    where s.vending_machine_id in cast(vm.id as VARCHAR)
)
