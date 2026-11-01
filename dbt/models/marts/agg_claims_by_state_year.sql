-- Losses by state and year: claim count, total paid and severity (average paid per paid claim).
-- Note: true claim frequency needs exposure (policies in force), which this dataset doesn't have.

select
    state,
    year_of_loss,
    count(*)                                              as claim_count,
    countif(is_paid_claim)                                as paid_claim_count,
    round(sum(total_amount_paid), 2)                      as total_amount_paid,
    round(safe_divide(sum(total_amount_paid), countif(is_paid_claim)), 2)
                                                          as avg_severity,
    round(safe_divide(countif(is_paid_claim), count(*)), 4)
                                                          as paid_claim_ratio
from {{ ref('fct_claims') }}
where state is not null
  and year_of_loss is not null
group by state, year_of_loss
