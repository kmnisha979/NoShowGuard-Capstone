
-- NoShowGuard Capstone
-- Part 2: SQL Analysis

USE noshowguard;

-- Task 2.1: Database validation
-- Successfully imported:
-- 8 clinics
-- 990 appointments
-- 218 no-shows

-- Primary key constraint test:
-- INSERT INTO appointments
-- SELECT *
-- FROM appointments
-- WHERE appointment_id = 'A0001';

-- Expected and observed:
-- Error Code: 1062
-- Duplicate entry 'A0001'
-- for key 'appointments.PRIMARY'

-- Task 2.2: Clinic-level no-show analysis

-- Task 2.2: Clinic-level no-show analysis

SELECT
    c.clinic_id,
    c.clinic_name,
    COUNT(a.appointment_id) AS total_appointments,
    SUM(a.no_show) AS total_no_shows,
    ROUND(
        100.0 * SUM(a.no_show) / COUNT(a.appointment_id),
        1
    ) AS no_show_rate_pct
FROM clinics c
JOIN appointments a
    ON c.clinic_id = a.clinic_id
GROUP BY
    c.clinic_id,
    c.clinic_name
HAVING COUNT(a.appointment_id) >= 95
ORDER BY no_show_rate_pct DESC;

-------------------------------------------

-- Task 2.2: All clinics without the HAVING filter

SELECT
    c.clinic_id,
    c.clinic_name,
    COUNT(a.appointment_id) AS total_appointments,
    SUM(a.no_show) AS total_no_shows,
    ROUND(
        100.0 * SUM(a.no_show) / COUNT(a.appointment_id),
        1
    ) AS no_show_rate_pct
FROM clinics c
JOIN appointments a
    ON c.clinic_id = a.clinic_id
GROUP BY
    c.clinic_id,
    c.clinic_name
ORDER BY no_show_rate_pct DESC;

----------------------------------------------------------------

-- Task 2.3: No-show analysis by booking lead time

SELECT
    CASE
        WHEN lead_days BETWEEN 1 AND 7 THEN '1-7 days'
        WHEN lead_days BETWEEN 8 AND 14 THEN '8-14 days'
        WHEN lead_days BETWEEN 15 AND 30 THEN '15-30 days'
        ELSE '31+ days'
    END AS lead_time_band,
    COUNT(*) AS total_appointments,
    SUM(no_show) AS total_no_shows,
    ROUND(
        100.0 * SUM(no_show) / COUNT(*),
        1
    ) AS no_show_rate_pct
FROM appointments
GROUP BY lead_time_band
ORDER BY MIN(lead_days);

---------------------------------------------------------------


-- Task 2.4: Monthly no-show trends using CTE and LAG()

WITH monthly_rates AS (
    SELECT
        DATE_FORMAT(appt_date, '%Y-%m') AS appointment_month,
        COUNT(*) AS total_appointments,
        SUM(no_show) AS total_no_shows,
        ROUND(
            100.0 * SUM(no_show) / COUNT(*),
            1
        ) AS no_show_rate_pct
    FROM appointments
    GROUP BY DATE_FORMAT(appt_date, '%Y-%m')
)
SELECT
    appointment_month,
    total_appointments,
    total_no_shows,
    no_show_rate_pct,
    ROUND(
        no_show_rate_pct -
        LAG(no_show_rate_pct) OVER (
            ORDER BY appointment_month
        ),
        1
    ) AS change_from_previous_month
FROM monthly_rates
ORDER BY appointment_month;

-----------------------------------------------------------------

-- Task 2.5: Rank clinics within each city

WITH clinic_rates AS (
    SELECT
        c.clinic_name,
        c.city,
        ROUND(
            100.0 * SUM(a.no_show) / COUNT(*),
            1
        ) AS no_show_pct
    FROM clinics c
    JOIN appointments a
        ON c.clinic_id = a.clinic_id
    GROUP BY
        c.clinic_id,
        c.clinic_name,
        c.city
)
SELECT
    clinic_name,
    city,
    no_show_pct,
    RANK() OVER (
        PARTITION BY city
        ORDER BY no_show_pct DESC
    ) AS rank_in_city,
    CASE
        WHEN no_show_pct > (
            SELECT 100.0 * SUM(no_show) / COUNT(*)
            FROM appointments
        ) THEN 'above'
        WHEN no_show_pct < (
            SELECT 100.0 * SUM(no_show) / COUNT(*)
            FROM appointments
        ) THEN 'below'
        ELSE 'equal'
    END AS vs_overall
FROM clinic_rates
ORDER BY city, rank_in_city;
