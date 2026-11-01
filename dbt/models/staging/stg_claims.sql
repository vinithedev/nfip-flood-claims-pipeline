-- Staging: one row per claim. Renames to snake_case, derives total paid amounts and
-- groups flood zones into the risk categories used in insurance analysis.
-- No business filtering here: every raw row is kept.

with source as (

    select * from {{ source('nfip_raw', 'claims') }}

),

renamed as (

    select
        -- identifiers
        id                                           as claim_id,
        eventDesignationNumber                       as event_designation_number,
        floodEvent                                   as flood_event_name,

        -- dates
        dateOfLoss                                   as date_of_loss,
        yearOfLoss                                   as year_of_loss,
        openDate                                     as claim_open_date,
        mostRecentPaymentDate                        as most_recent_payment_date,
        originalNBDate                               as policy_original_new_business_date,
        originalConstructionDate                     as original_construction_date,
        cast(asOfDate as date)                       as as_of_date,

        -- location
        state,
        countyCode                                   as county_fips_code,
        reportedZipCode                              as reported_zip_code,
        nfipCommunityName                            as nfip_community_name,
        nfipRatedCommunityNumber                     as nfip_rated_community_number,
        latitude,
        longitude,

        -- flood risk
        ratedFloodZone                               as rated_flood_zone,
        floodZoneCurrent                             as current_flood_zone,
        case
            when upper(ratedFloodZone) like 'V%' then 'V - Coastal high risk'
            when upper(ratedFloodZone) like 'A%' then 'A - High risk'
            when upper(ratedFloodZone) in ('B', 'C', 'X') then 'B/C/X - Moderate to low risk'
            when upper(ratedFloodZone) = 'D' then 'D - Undetermined risk'
            else 'Unknown'
        end                                          as flood_zone_group,
        coalesce(upper(ratedFloodZone) like 'A%' or upper(ratedFloodZone) like 'V%', false)
                                                     as is_special_flood_hazard_area,
        causeOfDamage                                as cause_of_damage_code,
        waterDepth                                   as water_depth_inches,
        floodWaterDuration                           as flood_water_duration_hours,

        -- building
        occupancyType                                as occupancy_type_code,
        primaryResidenceIndicator                    as is_primary_residence,
        elevatedBuildingIndicator                    as is_elevated_building,
        postFIRMConstructionIndicator                as is_post_firm_construction,
        numberOfFloorsInTheInsuredBuilding           as number_of_floors_code,
        rentalPropertyIndicator                      as is_rental_property,

        -- coverage (US dollars)
        totalBuildingInsuranceCoverage               as building_coverage_amount,
        totalContentsInsuranceCoverage               as contents_coverage_amount,
        iccCoverage                                  as icc_coverage_amount,

        -- damage (US dollars, adjuster estimates)
        buildingDamageAmount                         as building_damage_amount,
        contentsDamageAmount                         as contents_damage_amount,
        buildingPropertyValue                        as building_property_value,

        -- payments (US dollars). Negative values can occur when an uncashed check is reissued.
        amountPaidOnBuildingClaim                    as amount_paid_building,
        amountPaidOnContentsClaim                    as amount_paid_contents,
        amountPaidOnIncreasedCostOfComplianceClaim   as amount_paid_icc,
        coalesce(amountPaidOnBuildingClaim, 0)
            + coalesce(amountPaidOnContentsClaim, 0)
            + coalesce(amountPaidOnIncreasedCostOfComplianceClaim, 0)
                                                     as total_amount_paid,
        nonPaymentReasonBuilding                     as non_payment_reason_building_code,
        nonPaymentReasonContents                     as non_payment_reason_contents_code

    from source

)

select
    *,
    total_amount_paid > 0 as is_paid_claim
from renamed
