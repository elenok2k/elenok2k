

-- =========================================
-- Решение задачи
-- =========================================

WITH first_call AS (
    SELECT
        ID_client,
        last_nm,
        first_nm,
        middle_nm,
        birth_dt,
        contact_dt AS first_contact_dt
    FROM (
        SELECT
            c.*,
            ROW_NUMBER() OVER (
                PARTITION BY c.ID_client
                ORDER BY c.contact_dt
            ) AS rn
        FROM CRM c
        WHERE c.result_contact = 'дозвон'
          AND c.contact_dt >= '2018-04-01'
          AND c.contact_dt <  '2018-05-01'
    ) t
    WHERE rn = 1
),

first_app_after_call AS (
    SELECT
        fc.ID_client,
        MIN(s.app_dt) AS first_app_after_call_dt
    FROM first_call fc
    LEFT JOIN SVC s
        ON s.ID_client = fc.ID_client
       AND s.app_dt > fc.first_contact_dt
    GROUP BY fc.ID_client
)

SELECT
    fc.ID_client,
    fc.last_nm,
    fc.first_nm,
    fc.middle_nm,
    fc.birth_dt,
    fc.first_contact_dt,
    faa.first_app_after_call_dt
FROM first_call fc
LEFT JOIN first_app_after_call faa
    ON fc.ID_client = faa.ID_client
ORDER BY fc.ID_client;
