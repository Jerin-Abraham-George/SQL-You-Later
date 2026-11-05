/*
Patient Demographics & Clinical Analysis:
-------------------------------------------------------------------------------------------------------------------------
This analysis explores patient demographics and clinical activity, focusing on understanding patient populations, 
age distributions, and diagnosis patterns across healthcare facilities.

It also examines patient characteristics based on age and gender, identifies unique patient counts, and analyzes 
clinical service utilization through CPT units and diagnosis code groupings.

Focus: Understanding patient populations, demographics, diagnoses, and clinical activity.
-------------------------------------------------------------------------------------------------------------------------
*/

/* ====================================================================================================================*/

/* Question 1:
How many unique patients exist is the Healthcare_DB? */


	SELECT
		COUNT(DISTINCT PatientNumber)                   AS unique_patient_count
	FROM dimPatient


/* Question 2:
How many CptUnits by DiagnosisCodeGroup are assigned to a "J code" Diagnosis 
(these are diagnosis codes with the letter J in the code)? */
	

	SELECT
		dc.DiagnosisCodeGroup,
		SUM(CPTUnits)                                   AS total_cpt_units
	FROM FactTable ft
	INNER JOIN dimDiagnosisCode dc
		ON ft.dimDiagnosisCodePK = dc.dimDiagnosisCodePK
	WHERE dc.DiagnosisCode LIKE 'J%'
	GROUP BY dc.DiagnosisCodeGroup
	ORDER BY 2 DESC


/* Question 3:
Create a report that details Patient demographics.
The report should group patients into three buckets- Under 18, between 18-65, & over 65
Include the following columns:
	-First and Last name in the same column
	-Email
	-Patient Age
	-City and State in the same column */

	SELECT
		CONCAT(p.FirstName, ' ' , p.LastName)             AS full_name,
		p.Email,
		p.PatientAge,
		CASE	
			WHEN p.PatientAge < 18 THEN 'Under 18'
			WHEN p.PatientAge < 65 THEN 'Between 18-65'
			ELSE 'Over 65'
		END AS patient_age_buckets,
		CONCAT(p.City, ', ' , p.[State]) AS [city/state]
	FROM dimPatient p


/* Question 4:
What is the average patient age by gender for patients seen at Big Heart Community Hospital with a Diagnosis that 
included Type 2 diabetes? And how many Patients are included in that average? */


	SELECT
		PatientGender,
		FORMAT(AVG(PatientAge), '#.#')                   AS avg_patient_age,
		COUNT(DISTINCT PatientNumber)                    AS count_of_patients
		-- SUM(patientage) / COUNT(DISTINCT PatientNumber) AS avg_check 
	FROM 
			(SELECT DISTINCT
				ft.PatientNumber,
				p.PatientGender,
				CONVERT(DECIMAL(10,2), p.PatientAge)         AS PatientAge
			FROM FactTable ft
			INNER JOIN dimPatient p
				ON ft.dimPatientPK = p.dimPatientPK
			INNER JOIN dimDiagnosisCode dc
				ON ft.dimDiagnosisCodePK = dc.dimDiagnosisCodePK
			INNER JOIN dimLocation l
				ON ft.dimLocationPK = l.dimLocationPK
			WHERE l.LocationName = 'Big Heart Community Hospital' AND dc.DiagnosisCodeDescription LIKE '%Type 2%'
			) t
	GROUP BY PatientGender
