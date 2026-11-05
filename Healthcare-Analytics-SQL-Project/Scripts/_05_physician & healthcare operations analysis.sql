/*
Physician & Healthcare Operations Analysis:
-------------------------------------------------------------------------------------------------------------------------
This analysis explores physician activity and healthcare operations, focusing on physician specialties, Medicare 
participation, medical procedure volumes, and payment trends.

It also examines CPT code distribution, identifies frequently performed medical procedures, tracks monthly payments 
across physician specialties, and compares hospital locations based on physician count, patient volume, and gross charges.

Focus: Understanding physician activity, specialties, procedures, hospital locations, and operational performance.
-------------------------------------------------------------------------------------------------------------------------
*/
/* ====================================================================================================================*/

/* Question 1:
How many CptCodes are in each CptGrouping? */


	SELECT
		CptGrouping,
		COUNT(DISTINCT CptCode)                               AS cptcode_count
	FROM dimCptCode
	GROUP BY CptGrouping
	ORDER BY cptcode_count DESC


/* Question 2:
How many physicians have submitted a Medicare insurance claim? */


	SELECT
		COUNT(DISTINCT ProviderNpi)                           AS count_of_providers
	FROM FactTable ft
	INNER JOIN dimPhysician ph
		ON ft.dimPhysicianPK = ph.dimPhysicianPK
	INNER JOIN dimPayer pa
		ON ft.dimPayerPK = pa.dimPayerPK
	WHERE PayerName = 'Medicare'


/* Question 3:
How many CptCodes have more than 100 units? */


	SELECT
		CptCode,
		CptDesc,
		SUM(CPTUnits)                                         AS cpt_units
	FROM FactTable ft
	INNER JOIN dimCptCode cpt
		ON ft.dimCPTCodePK = cpt.dimCPTCodePK
	GROUP BY CptCode, CptDesc
	HAVING SUM(CPTUnits) > 100
	ORDER BY 3 DESC


/* Question 4:
Find the physician specialty that has received the highest amount of payments. 
Then show the payments by month for this group of physicians. */


	SELECT TOP 1
		ph.ProviderSpecialty,
		-SUM(Payment)                                         AS payment
	FROM FactTable ft
	INNER JOIN dimPhysician ph
		ON ft.dimPhysicianPK = ph.dimPhysicianPK
	GROUP BY ph.ProviderSpecialty
	ORDER BY 2 DESC;

	SELECT
		ph.ProviderSpecialty,
		da.MonthPeriod,
		da.MonthYear,
		FORMAT(-SUM(Payment), '$#,###')                       AS payment
	FROM FactTable ft
	INNER JOIN dimPhysician ph
		ON ft.dimPhysicianPK = ph.dimPhysicianPK
	INNER JOIN dimDate da
		ON ft.dimDatePostPK = da.dimDatePostPK
	WHERE ph.ProviderSpecialty = 'Internal Medicine'
	GROUP BY 		
		ph.ProviderSpecialty,
		da.MonthPeriod,
		da.MonthYear
	ORDER BY da.MonthPeriod ASC


/* Question 5:
Build a Table that includes the following elements:
	- LocationName
	- CountofPhysicians
	- CountofPatients
	- GrossCharge
	- AverageChargeperPatients */


	SELECT 
		l.LocationName AS location,
		FORMAT(COUNT(DISTINCT ph.ProviderNpi), '#,#')           AS count_of_physician,
		FORMAT(COUNT(DISTINCT pt.PatientNumber), '#,#')         AS count_of_patient,
		FORMAT(SUM(ft.GrossCharge), '$#,#')  AS charges,
		FORMAT(SUM(ft.GrossCharge) / COUNT(DISTINCT pt.PatientNumber), '$#,#')  AS avg_charge_per_patient
	FROM
	FactTable ft
	INNER JOIN dimLocation l
		ON ft.dimLocationPK = l.dimLocationPK
	INNER JOIN dimPhysician ph
		ON ft.dimPhysicianPK = ph.dimPhysicianPK
	INNER JOIN dimPatient pt
		ON ft.dimPatientPK = pt.dimPatientPK
	GROUP BY l.LocationName
