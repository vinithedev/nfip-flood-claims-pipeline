-- Losses by flood zone risk group and building elevation: does elevating a building
-- reduce what the insurer pays? Compares severity across risk groups.

select
    flood_zone_group,
    coalesce(is_elevated_building, false)                 as is_elevated_building,
    count(*)                                              as claim_count,
    countif(is_paid_claim)                                as paid_claim_count,
    round(sum(total_amount_paid), 2)                      as total_amount_paid,
    round(safe_divide(sum(total_amount_paid), countif(is_paid_claim)), 2)
                                                          as avg_severity,
    round(avg(water_depth_inches), 1)                     as avg_water_depth_inches
from {{ ref('fct_claims') }}
group by flood_zone_group, is_elevated_building
