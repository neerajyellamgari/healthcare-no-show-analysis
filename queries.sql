-- dataset csv file was done by import as flat file

use healthcaredb;

SELECT COUNT(*) AS total_rows FROM appointments;

SELECT AppointmentID, COUNT(*) AS cnt
FROM appointments
GROUP BY AppointmentID
HAVING COUNT(*) > 1;

UPDATE appointments
SET Gender = CASE 
                WHEN Gender IN ('M','MALE') THEN 'M'
                WHEN Gender IN ('F','FEMALE') THEN 'F'
                ELSE NULL
             END;


UPDATE appointments
SET Age = NULL
WHERE Age < 0 OR Age > 120;



ALTER TABLE appointments ADD lead_days INT;

UPDATE appointments
SET lead_days = DATEDIFF(DAY, ScheduledDay, AppointmentDay);


SELECT COUNT(*) AS negative_leads
FROM appointments
WHERE lead_days < 0;


SELECT 
    COUNT(*) AS total_appointments,
    SUM(CASE WHEN Showed_up = 1 THEN 1 ELSE 0 END) AS showed,
    SUM(CASE WHEN Showed_up = 0 THEN 1 ELSE 0 END) AS no_show,
    ROUND(100.0 * SUM(CASE WHEN Showed_up = 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_no_show
FROM appointments;


SELECT Gender,
    COUNT(*) AS total,
    SUM(CASE WHEN Showed_up = 1 THEN 1 ELSE 0 END) AS showed,
    ROUND(100.0 * SUM(CASE WHEN Showed_up = 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_no_show
FROM appointments
GROUP BY Gender
ORDER BY pct_no_show DESC;


SELECT
    CASE 
        WHEN Age < 13 THEN '0-12'
        WHEN Age BETWEEN 13 AND 19 THEN '13-19'
        WHEN Age BETWEEN 20 AND 35 THEN '20-35'
        WHEN Age BETWEEN 36 AND 60 THEN '36-60'
        ELSE '60+' END AS age_group,
    COUNT(*) AS total,
    SUM(CASE WHEN Showed_up = 0 THEN 1 ELSE 0 END) AS no_shows,
    ROUND(100.0 * SUM(CASE WHEN Showed_up = 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_no_show
FROM appointments
GROUP BY CASE 
        WHEN Age < 13 THEN '0-12'
        WHEN Age BETWEEN 13 AND 19 THEN '13-19'
        WHEN Age BETWEEN 20 AND 35 THEN '20-35'
        WHEN Age BETWEEN 36 AND 60 THEN '36-60'
        ELSE '60+' END
ORDER BY pct_no_show DESC;


SELECT SMS_received,
    COUNT(*) AS total,
    SUM(CASE WHEN Showed_up = 0 THEN 1 ELSE 0 END) AS no_shows,
    ROUND(100.0 * SUM(CASE WHEN Showed_up = 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_no_show
FROM appointments
GROUP BY SMS_received;


SELECT lead_days,
    COUNT(*) AS total,
    ROUND(100.0 * SUM(CASE WHEN Showed_up = 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_no_show
FROM appointments
GROUP BY lead_days
ORDER BY lead_days;


USE healthcaredb;

-- If the cleaned table already exists, drop it so we can rebuild
IF OBJECT_ID('dbo.appointments_cleaned', 'U') IS NOT NULL
    DROP TABLE dbo.appointments_cleaned;


-- Create cleaned table
SELECT
    PatientId,
    AppointmentID,
    
    -- Normalize Gender
    CASE 
        WHEN Gender IN ('M','MALE','m','male') THEN 'M'
        WHEN Gender IN ('F','FEMALE','f','female') THEN 'F'
        ELSE NULL
    END AS Gender,
    
    -- Convert dates
    CAST(ScheduledDay AS DATETIME)   AS ScheduledDay,
    CAST(AppointmentDay AS DATE)     AS AppointmentDay,
    
    -- Clean Age
    CASE 
        WHEN Age < 0 OR Age > 120 THEN NULL
        ELSE Age
    END AS Age,
    
    Neighbourhood,
    
    -- Keep booleans as BIT (0/1)
    CAST(Scholarship AS BIT)   AS Scholarship,
    CAST(Hipertension AS BIT)  AS Hipertension,
    CAST(Diabetes AS BIT)      AS Diabetes,
    CAST(Alcoholism AS BIT)    AS Alcoholism,
    CAST(Handcap AS BIT)       AS Handcap,
    CAST(SMS_received AS BIT)  AS SMS_received,
    CAST(Showed_up AS BIT)     AS Showed_up,
    
    -- Compute lead days
    DATEDIFF(DAY, ScheduledDay, AppointmentDay) AS lead_days

INTO dbo.appointments_cleaned
FROM dbo.appointments;


SELECT TOP 20 * 
FROM dbo.appointments_cleaned;


SELECT * 
FROM dbo.appointments_cleaned;