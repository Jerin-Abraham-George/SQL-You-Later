/*
================================================================================
PROJECT : HOSPITAL DATABASE - SQL PRACTICE
PLATFORM : sql-practice.com
TOTAL QUESTIONS : 54
================================================================================

ABOUT THIS FILE
This file contains 54 SQL practice questions covering fundamental and
intermediate querying techniques using a hospital database.

TABLES USED
    patients
    admissions
    doctors
    province_names

NOTES
    1. Queries are written for Microsoft SQL Server (T-SQL).
    2. Question wording is retained from the original exercise, with minor
       grammatical cleanup where appropriate.

================================================================================
*/


/*=============================================================================
  SECTION 1 - BASIC QUERIES AND FILTERING
========
====================================================================*/

-- QUESTION 01
-- Show the first name, last name, and gender of patients whose gender is 'M'.

    SELECT
        first_name,
        last_name,
        gender
    FROM patients
    WHERE gender = 'M';

-- QUESTION 02
-- Show the first name and last name of patients who do not have allergies.

    SELECT
        first_name,
        last_name
    FROM patients
    WHERE allergies IS NULL;

-- QUESTION 03
-- Show the first name of patients whose first name starts with the letter 'C'.

    SELECT
        first_name
    FROM patients
    WHERE first_name LIKE 'C%';

-- QUESTION 04
-- Show the first name and last name of patients whose weight is between 100 and 120 (inclusive).

    SELECT
        first_name,
        last_name
    FROM patients
    WHERE weight BETWEEN 100 AND 120;

-- QUESTION 05
-- Replace NULL values in the allergies column with 'NKA'.
-- WARNING: This modifies the patients table.

    UPDATE patients
    SET allergies = 'NKA'
    WHERE allergies IS NULL;

-- QUESTION 06
-- Display each patient's full name in a single column.

    SELECT
        CONCAT(first_name, ' ', last_name) AS full_name
    FROM patients;

-- QUESTION 07
-- Show each patient's first name, last name, and full province name.

    SELECT
        p.first_name,
        p.last_name,
        pn.province_name
    FROM patients AS p
    LEFT JOIN province_names AS pn
        ON p.province_id = pn.province_id;

-- QUESTION 08
-- Count the patients whose birth year is 2010.

    SELECT
        COUNT(patient_id) AS total_patients
    FROM patients
    WHERE YEAR(birth_date) = 2010;

-- QUESTION 09
-- Show the first name, last name, and height of the tallest patient(s).

    SELECT
        first_name,
        last_name,
        height
    FROM patients
    WHERE height = (
        SELECT MAX(height)
        FROM patients
    );

-- QUESTION 10
-- Show all columns for patients with the specified patient IDs.

    SELECT
        *
    FROM patients
    WHERE patient_id IN (1, 45, 534, 879, 1000);


/*=============================================================================
  SECTION 2 - AGGREGATIONS, GROUPING AND DATE ANALYSIS
=============================================================================*/


-- QUESTION 11
-- Show the total number of admissions.

    SELECT
        COUNT(*) AS total_admissions
    FROM admissions;

-- QUESTION 12
-- Show all admission records where admission and discharge occurred on the same day.

    SELECT
        *
    FROM admissions
    WHERE admission_date = discharge_date;

-- QUESTION 13
-- Show patient ID 579 and the total number of their admissions.

    SELECT
        patient_id,
        COUNT(*) AS total_admissions
    FROM admissions
    WHERE patient_id = 579
    GROUP BY patient_id;

-- QUESTION 14
-- Show the unique cities of patients living in province 'NS'.

    SELECT DISTINCT
        city
    FROM patients
    WHERE province_id = 'NS';

-- QUESTION 15
-- Find patients whose height is greater than 160 and weight is greater than 70.

    SELECT
        first_name,
        last_name,
        birth_date
    FROM patients
    WHERE height > 160
      AND weight > 70;

-- QUESTION 16
-- Show patients from Hamilton who have a recorded allergy.

    SELECT
        first_name,
        last_name,
        allergies
    FROM patients
    WHERE allergies IS NOT NULL
      AND city = 'Hamilton';

-- QUESTION 17
-- Show unique birth years in ascending order.

    SELECT DISTINCT
        YEAR(birth_date) AS birth_year
    FROM patients
    ORDER BY birth_year ASC;

-- QUESTION 18
-- Show first names that occur exactly once in the patients table.

    SELECT
        first_name
    FROM patients
    GROUP BY first_name
    HAVING COUNT(*) = 1;

-- QUESTION 19
-- Show patients whose first name starts and ends with 'S' and is at least six characters long.

    SELECT
        patient_id,
        first_name
    FROM patients
    WHERE first_name LIKE 'S%____%s';

-- QUESTION 20
-- Show patients who have an admission diagnosis of 'Dementia'.

    SELECT DISTINCT
        p.patient_id,
        p.first_name,
        p.last_name
    FROM patients AS p
    INNER JOIN admissions AS a
        ON p.patient_id = a.patient_id
    WHERE a.diagnosis = 'Dementia';

-- QUESTION 21
-- Display every patient's first name, ordered by name length and then alphabetically.

    SELECT
        first_name
    FROM patients
    ORDER BY LEN(first_name), first_name;

-- QUESTION 22
-- Show the total number of male and female patients in a single row.

    SELECT
        SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) AS male_count,
        SUM(CASE WHEN gender = 'F' THEN 1 ELSE 0 END) AS female_count
    FROM patients;

-- QUESTION 23
-- Show patients allergic to Penicillin or Morphine, ordered by allergy and name.

    SELECT
        first_name,
        last_name,
        allergies
    FROM patients
    WHERE allergies IN ('Penicillin', 'Morphine')
    ORDER BY
        allergies ASC,
        first_name ASC,
        last_name ASC;

-- QUESTION 24
-- Show patients admitted more than once for the same diagnosis.

    SELECT
        patient_id,
        diagnosis
    FROM admissions
    GROUP BY
        patient_id,
        diagnosis
    HAVING COUNT(*) > 1;

-- QUESTION 25
-- Show the number of patients in each city, from highest to lowest, then by city name.

    SELECT
        city,
        COUNT(DISTINCT patient_id) AS total_patients
    FROM patients
    GROUP BY city
    ORDER BY
        total_patients DESC,
        city ASC;


/*=============================================================================
  SECTION 3 - SET OPERATORS, CONDITIONAL LOGIC AND STRING FUNCTIONS
=============================================================================*/


-- QUESTION 26
-- Show the first name, last name, and role of every patient and doctor.

    SELECT
        first_name,
        last_name,
        'Patient' AS role
    FROM patients
    UNION ALL
    SELECT
        first_name,
        last_name,
        'Doctor' AS role
    FROM doctors;

-- QUESTION 27
-- Show all recorded allergies ordered by popularity. Exclude NULL values.

    SELECT
        allergies,
        COUNT(*) AS patient_count
    FROM patients
    WHERE allergies IS NOT NULL
    GROUP BY allergies
    ORDER BY patient_count DESC;

-- QUESTION 28
-- Show patients born in the 1970s, ordered from earliest to latest birth date.

    SELECT
        first_name,
        last_name,
        birth_date
    FROM patients
    WHERE birth_date >= '19700101'
      AND birth_date < '19800101'
    ORDER BY birth_date ASC;

-- QUESTION 29
-- Display last name in uppercase followed by first name in lowercase, separated by a comma.
-- Order by first name in descending order.

    SELECT
        CONCAT(UPPER(last_name), ',', LOWER(first_name)) AS new_name_format
    FROM patients
    ORDER BY first_name DESC;

-- QUESTION 30
-- Show provinces where the sum of patient heights is at least 7,000.

    SELECT
        province_id,
        SUM(height) AS sum_height
    FROM patients
    GROUP BY province_id
    HAVING SUM(height) >= 7000;

-- QUESTION 31
-- Show the difference between the largest and smallest weights for patients named Maroni.

    SELECT
        MAX(weight) - MIN(weight) AS weight_delta
    FROM patients
    WHERE last_name = 'Maroni';

-- QUESTION 32
-- Show each day of the month and the number of admissions that occurred on that day.
-- Sort from the most admissions to the fewest.

    SELECT
        DAY(admission_date) AS day_number,
        COUNT(*) AS number_of_admissions
    FROM admissions
    GROUP BY DAY(admission_date)
    ORDER BY number_of_admissions DESC;

-- QUESTION 33
-- Show all columns for patient 542's most recent admission record(s).

    SELECT
        *
    FROM admissions
    WHERE patient_id = 542
      AND admission_date = (
          SELECT MAX(admission_date)
          FROM admissions
          WHERE patient_id = 542
      );

-- QUESTION 34
-- Show admissions matching either of the following criteria:
-- 1. Patient ID is odd and attending doctor ID is 1, 5, or 19.
-- 2. Doctor ID contains the digit 2 and patient ID has three characters.

    SELECT
        patient_id,
        attending_doctor_id,
        diagnosis
    FROM admissions
    WHERE (
            patient_id % 2 <> 0
            AND attending_doctor_id IN (1, 5, 19)
          )
       OR (
            CONVERT(VARCHAR(20), attending_doctor_id) LIKE '%2%'
            AND LEN(CONVERT(VARCHAR(20), patient_id)) = 3
          );


/*=============================================================================
  SECTION 4 - JOINS AND RELATIONSHIP-BASED ANALYSIS
=============================================================================*/


-- QUESTION 35
-- Show each doctor's first name, last name, and total number of admissions attended.

    SELECT
        d.first_name,
        d.last_name,
        COUNT(*) AS admissions_total
    FROM admissions AS a
    INNER JOIN doctors AS d
        ON d.doctor_id = a.attending_doctor_id
    GROUP BY
        d.doctor_id,
        d.first_name,
        d.last_name;

-- QUESTION 36
-- Show each doctor's ID, full name, first admission date, and last admission date.

    SELECT
        d.doctor_id,
        CONCAT(d.first_name, ' ', d.last_name) AS full_name,
        MIN(a.admission_date) AS first_admission_date,
        MAX(a.admission_date) AS last_admission_date
    FROM doctors AS d
    LEFT JOIN admissions AS a
        ON d.doctor_id = a.attending_doctor_id
    GROUP BY
        d.doctor_id,
        d.first_name,
        d.last_name;

-- QUESTION 37
-- Display the total number of patients in each province, ordered from highest to lowest.

    SELECT
        pr.province_name,
        COUNT(DISTINCT pa.patient_id) AS patient_count
    FROM patients AS pa
    LEFT JOIN province_names AS pr
        ON pa.province_id = pr.province_id
    GROUP BY
        pr.province_id,
        pr.province_name
    ORDER BY patient_count DESC;

-- QUESTION 38
-- For every admission with a diagnosis, show the patient's name, diagnosis, and attending doctor's name.

    SELECT
        CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
        a.diagnosis,
        CONCAT(d.first_name, ' ', d.last_name) AS doctor_name
    FROM patients AS p
    INNER JOIN admissions AS a
        ON p.patient_id = a.patient_id
    INNER JOIN doctors AS d
        ON a.attending_doctor_id = d.doctor_id
    WHERE a.diagnosis IS NOT NULL;

-- QUESTION 39
-- Show first name, last name, and count for names shared by more than one patient.

    SELECT
        first_name,
        last_name,
        COUNT(*) AS num_of_duplicates
    FROM patients
    GROUP BY
        first_name,
        last_name
    HAVING COUNT(*) > 1;

-- QUESTION 40
-- Show patient name, height in feet (1 decimal), weight in pounds (0 decimals), birth date, and full gender.
-- Conversion: centimetres to feet = divide by 30.48; kilograms to pounds = multiply by 2.205.

    SELECT
        CONCAT(first_name, ' ', last_name) AS patient_name,
        ROUND(CAST(height AS DECIMAL(10, 2)) / 30.48, 1) AS height_feet,
        ROUND(weight * 2.205, 0) AS weight_pounds,
        birth_date,
        CASE
            WHEN gender = 'M' THEN 'Male'
            WHEN gender = 'F' THEN 'Female'
            ELSE 'Unknown'
        END AS gender_type
    FROM patients;

-- QUESTION 41
-- Show patients who do not have any records in the admissions table.

    SELECT
        p.patient_id,
        p.first_name,
        p.last_name
    FROM patients AS p
    LEFT JOIN admissions AS a
        ON p.patient_id = a.patient_id
    WHERE a.patient_id IS NULL;


/*=============================================================================
  SECTION 5 - SUBQUERIES, WINDOW FUNCTIONS AND ADVANCED ANALYSIS
=============================================================================*/


-- QUESTION 42
-- Show the maximum, minimum, and average number of admissions per admission date.

    SELECT
        MAX(daily_admissions) AS max_visits,
        MIN(daily_admissions) AS min_visits,
        CAST(ROUND(AVG(CAST(daily_admissions AS DECIMAL(10, 2))), 2) AS DECIMAL(10, 2)) AS avg_visits
    FROM (
        SELECT
            admission_date,
            COUNT(*) AS daily_admissions
        FROM admissions
        GROUP BY admission_date
    ) AS daily_counts;

-- QUESTION 43
-- Show every patient with at least one admission and their most recent admission and doctor's name.
-- RANK preserves multiple admissions when the latest admission date is tied.

    WITH RankedAdmissions AS (
        SELECT
            p.patient_id,
            CONCAT(p.first_name, ' ', p.last_name) AS patient_name,
            a.admission_date,
            CONCAT(d.first_name, ' ', d.last_name) AS doctor_name,
            RANK() OVER (
                PARTITION BY p.patient_id
                ORDER BY a.admission_date DESC
            ) AS admission_rank
        FROM patients AS p
        INNER JOIN admissions AS a
            ON p.patient_id = a.patient_id
        INNER JOIN doctors AS d
            ON a.attending_doctor_id = d.doctor_id
    )
    SELECT
        patient_id,
        patient_name,
        admission_date,
        doctor_name
    FROM RankedAdmissions
    WHERE admission_rank = 1;

-- QUESTION 44
-- Group patients into weight bands (0-9, 10-19, etc.) and count patients in each band.

    WITH PatientWeightGroups AS (
        SELECT
            patient_id,
            (weight / 10) * 10 AS weight_group
        FROM patients
        WHERE weight >= 0
    )
    SELECT
        weight_group,
        COUNT(patient_id) AS patients_in_group
    FROM PatientWeightGroups
    GROUP BY weight_group
    ORDER BY weight_group DESC;

-- QUESTION 45
-- Show patient ID, weight, height, and obesity indicator (1 if BMI >= 30; otherwise 0).

    SELECT
        patient_id,
        weight,
        height,
        CASE
            WHEN height > 0
             AND CAST(weight AS DECIMAL(10, 2)) /
                 POWER(CAST(height AS DECIMAL(10, 2)) / 100.0, 2) >= 30
            THEN 1
            ELSE 0
        END AS isObese
    FROM patients;

-- QUESTION 46
-- Show patients diagnosed with Epilepsy whose attending doctor's first name is Lisa.

    SELECT DISTINCT
        p.patient_id,
        p.first_name,
        p.last_name,
        d.specialty
    FROM patients AS p
    INNER JOIN admissions AS a
        ON p.patient_id = a.patient_id
    INNER JOIN doctors AS d
        ON a.attending_doctor_id = d.doctor_id
    WHERE a.diagnosis = 'Epilepsy'
      AND d.first_name = 'Lisa';

-- QUESTION 47
-- Create a temporary password for patients who have at least one admission.
-- Password format: patient ID + length of last name + birth year.

    SELECT DISTINCT
        p.patient_id,
        CONCAT(
            p.patient_id,
            LEN(p.last_name),
            YEAR(p.birth_date)
        ) AS temp_password
    FROM patients AS p
    INNER JOIN admissions AS a
        ON a.patient_id = p.patient_id;

-- QUESTION 48
-- Calculate admission costs by insurance status. Even patient IDs have insurance.
-- Insured admission cost = $10; uninsured admission cost = $50.

    SELECT
        CASE
            WHEN patient_id % 2 = 0 THEN 'Yes'
            ELSE 'No'
        END AS has_insurance,
        SUM(
            CASE
                WHEN patient_id % 2 = 0 THEN 10
                ELSE 50
            END
        ) AS cost_after_insurance
    FROM admissions
    GROUP BY
        CASE
            WHEN patient_id % 2 = 0 THEN 'Yes'
            ELSE 'No'
        END;

-- QUESTION 49
-- Show province names where the number of male patients exceeds the number of female patients.

    SELECT
        pr.province_name
    FROM patients AS p
    INNER JOIN province_names AS pr
        ON p.province_id = pr.province_id
    GROUP BY
        pr.province_id,
        pr.province_name
    HAVING
        SUM(CASE WHEN p.gender = 'M' THEN 1 ELSE 0 END) >
        SUM(CASE WHEN p.gender = 'F' THEN 1 ELSE 0 END);

-- QUESTION 50
-- Find the patient matching all specified demographic and location criteria.

    SELECT
        *
    FROM patients
    WHERE first_name LIKE '__r%'
      AND gender = 'F'
      AND MONTH(birth_date) IN (2, 5, 12)
      AND weight BETWEEN 60 AND 80
      AND patient_id % 2 = 1
      AND city = 'Kingston';

-- QUESTION 51
-- Show the percentage of patients whose gender is 'M', rounded to two decimal places.

    SELECT
        CONCAT(
            CAST(ROUND(
                100.0 * SUM(CASE WHEN gender = 'M' THEN 1 ELSE 0 END) /
                NULLIF(COUNT(*), 0),
                2
            ) AS DECIMAL(5, 2)),
            '%'
        ) AS percent_of_male_patients
    FROM patients;

-- QUESTION 52
-- For each admission date, show the number of admissions and the change from the previous date.

    WITH DailyAdmissions AS (
        SELECT
            admission_date,
            COUNT(*) AS admission_count
        FROM admissions
        GROUP BY admission_date
    )
    SELECT
        admission_date,
        admission_count,
        admission_count - LAG(admission_count) OVER (ORDER BY admission_date) AS admission_count_change
    FROM DailyAdmissions
    ORDER BY admission_date;

-- QUESTION 53
-- Sort province names alphabetically, but always place Ontario first.

    SELECT
        province_name
    FROM province_names
    ORDER BY
        CASE WHEN province_name = 'Ontario' THEN 0 ELSE 1 END,
        province_name;

-- QUESTION 54
-- Show each doctor's yearly admission count, including doctor ID, name, specialty, and year.

    SELECT
        d.doctor_id,
        CONCAT(d.first_name, ' ', d.last_name) AS doctor_full_name,
        d.specialty,
        YEAR(a.admission_date) AS selected_year,
        COUNT(a.admission_date) AS total_admissions
    FROM doctors AS d
    LEFT JOIN admissions AS a
        ON d.doctor_id = a.attending_doctor_id
    GROUP BY
        d.doctor_id,
        d.first_name,
        d.last_name,
        d.specialty,
        YEAR(a.admission_date)
    ORDER BY
        d.doctor_id,
        selected_year;

/*
================================================================================
END OF HOSPITAL DATABASE SQL PRACTICE
================================================================================
*/
