-- Claims fact table for the dashboard and ad hoc analysis.
-- Partitioned by month of loss (queries filter by period) and clustered by state and
-- flood zone group (the most common filters), so BigQuery scans only what it needs.

{{
    config(
        partition_by={
            "field": "date_of_loss",
            "data_type": "date",
            "granularity": "month"
        },
        cluster_by=["state", "flood_zone_group"]
    )
}}

select
    claims.claim_id,
    claims.date_of_loss,
    claims.year_of_loss,
    claims.state,
    claims.county_fips_code,
    claims.reported_zip_code,
    claims.nfip_community_name,
    claims.latitude,
    claims.longitude,
    claims.flood_event_name,
    claims.event_designation_number,
    claims.rated_flood_zone,
    claims.flood_zone_group,
    claims.is_special_flood_hazard_area,
    claims.cause_of_damage_code,
    coalesce(causes.cause_of_damage_description, 'Other or combined codes') as cause_of_damage,
    claims.occupancy_type_code,
    claims.is_primary_residence,
    claims.is_elevated_building,
    claims.is_post_firm_construction,
    claims.water_depth_inches,
    claims.building_coverage_amount,
    claims.contents_coverage_amount,
    claims.building_damage_amount,
    claims.contents_damage_amount,
    claims.amount_paid_building,
    claims.amount_paid_contents,
    claims.amount_paid_icc,
    claims.total_amount_paid,
    claims.is_paid_claim
from {{ ref('stg_claims') }} as claims
left join {{ ref('cause_of_damage_codes') }} as causes
    on claims.cause_of_damage_code = causes.cause_of_damage_code
