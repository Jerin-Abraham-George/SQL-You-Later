/*
Financial Performance & Revenue Cycle Analysis:
-------------------------------------------------------------------------------------------------------------------------
This analysis explores the financial performance of healthcare organizations, focusing on gross charges, insurance 
reimbursements, payment trends, and collection rates.

It also examines physician credentialing adjustments, charge and payment per unit, contractual adjustments, net charges,
and outstanding accounts receivable to identify potential revenue leakage and collection inefficiencies.

Focus: Understanding hospital revenue, reimbursement, insurance payments, billing issues, and collection performance.
-------------------------------------------------------------------------------------------------------------------------
*/

/* ====================================================================================================================*/

/* Question 1:
How many rows of data are in the FactTable that include a Gross Charge greater than $100? */

	
	SELECT 
		COUNT(*)                                                                   AS total_rows
	FROM FactTable
	WHERE GrossCharge > 100


/* Question 2:
Calculate the Gross Collection Rate (GCR) for each LocationName.
-- GCR = Payments divided GrossCharge --
Which LocationName has the highest GCR? */


	SELECT
		LocationName,
		FORMAT(-SUM(Payment) / SUM(GrossCharge), 'P1')                             AS GCR
	FROM 
	FactTable ft
	INNER JOIN dimLocation l
		ON ft.dimLocationPK = l.dimLocationPK
	GROUP BY LocationName
	ORDER BY GCR DESC


/* Question 3:
a. How many dollars have been written off (adjustments) due to credentialing (AdjustmentReason)? 
b. Which location has the highest number of credentialing adjustments? 
c. How many physicians at this location have been impacted by credentialing adjustments? 
   What does this mean? Who are these physicans? */


	-- a.

	SELECT
		FORMAT(-SUM(ft.Adjustment), '$#,###')                                        AS adjustment_amount
	FROM FactTable ft
	INNER JOIN dimTransaction t
		ON ft.dimTransactionPK = t.dimTransactionPK
	WHERE t.AdjustmentReason = 'Credentialing'


	-- b.

	SELECT TOP 1
		l.LocationName,
		FORMAT(-SUM(ft.Adjustment), '$#,###')                                       AS adjustment_amount
	FROM FactTable ft
	INNER JOIN dimTransaction t
		ON ft.dimTransactionPK = t.dimTransactionPK
	INNER JOIN dimLocation l
		ON ft.dimLocationPK = l.dimLocationPK
	WHERE t.AdjustmentReason = 'Credentialing'
	GROUP BY l.LocationName
	ORDER BY -SUM(ft.Adjustment) DESC


	-- c.

	SELECT
		COUNT(DISTINCT p.ProviderName)                                             AS physicians_count,
		FORMAT(-SUM(ft.Adjustment), '$#,###')                                      AS adjustment_amount
	FROM FactTable ft
	INNER JOIN dimTransaction t
		ON ft.dimTransactionPK = t.dimTransactionPK
	INNER JOIN dimPhysician p
		ON ft.dimPhysicianPK = p.dimPhysicianPK
	INNER JOIN dimLocation l
		ON ft.dimLocationPK = l.dimLocationPK
	WHERE t.AdjustmentReason = 'Credentialing' AND l.LocationName = 'Angelstone Community Hospital';


	SELECT
		DISTINCT p.ProviderNpi,
		p.ProviderName,
		FORMAT(-SUM(ft.Adjustment), '$#,###')                                      AS adjustment_amount,
		-SUM(ft.Adjustment)                                                        AS sort
	FROM FactTable ft
	INNER JOIN dimTransaction t
		ON ft.dimTransactionPK = t.dimTransactionPK
	INNER JOIN dimPhysician p
		ON ft.dimPhysicianPK = p.dimPhysicianPK
	INNER JOIN dimLocation l
		ON ft.dimLocationPK = l.dimLocationPK
	WHERE t.AdjustmentReason = 'Credentialing' AND l.LocationName = 'Angelstone Community Hospital'
	GROUP BY
		p.ProviderNpi,
		p.ProviderName
	ORDER BY sort DESC

	/* 

	====== What does this mean? ======
	Provider Credentialing refers to the process of ensuring that a physician is properly credentialed, enrolled, and 
	registered with an insurance company so that services provided to insured patients can be reimbursed.

	In this case, Angelstone Community Hospital has missed out on $2,107 in potential revenue because a physician 
	providing patient care was not properly credentialed with the relevant insurance company.

	---------------------------------------------------------------------------------------------------------------------

	====== What Needs to Be Done? ======

	The staff at Angelstone Community Hospital should prioritize completing the credentialing and enrollment process for 
	all physicians as soon as possible.

	Until physicians are properly credentialed, the hospital risks losing reimbursement for services rendered to insured 
	patients.

	---------------------------------------------------------------------------------------------------------------------

	====== Bottom Line ====== 
	
	The hospital is leaving money on the table simply because its physicians are not properly credentialed. 
	Addressing this issue promptly will help prevent further revenue leakage and ensure the hospital receives the 
	reimbursement it is entitled to.

	*/


/* Question 4:
There are a two visit types that you have been asked to compare (use CptDesc).
	- Office/outpatient visit est
	- Office/outpatient visit new
Show each CptCode, CptDesc and the assocaited CptUnits.
What is the Charge per CptUnit? (Reduce to two decimals)
What does this mean? */


	SELECT
		cc.CptCode,
		cc.CptDesc,
		SUM(ft.CPTUnits) AS cptunits,
		FORMAT(SUM(ft.GrossCharge) / SUM(ft.CPTUnits), '$#.##')                               AS charge_per_unit
	FROM FactTable ft
	INNER JOIN dimCptCode cc
		ON ft.dimCPTCodePK = cc.dimCPTCodePK
	WHERE cc.CptDesc IN ('Office/outpatient visit est', 'Office/outpatient visit new')
	GROUP BY 
		cc.CptCode,
		cc.CptDesc
	ORDER BY 1, 2 DESC

	/* 

	====== What does this mean? ======
	When we look at established patient visits, we can see a clear pattern: as the CPT code level increases, 
	the charge per unit also increases.

	This means that CPT code 99215 carries the highest charge among the established patient visit levels discussed.

	Higher-level visits generally involve greater medical decision-making complexity and/or more physician time, 
	which supports a higher level of reimbursement.

	---------------------------------------------------------------------------------------------------------------------

	====== Why does this matter? ======

	Physicians can bill for a higher-level visit when the documentation supports the additional time, complexity, or 
	medical decision-making involved in treating the patient.

	---------------------------------------------------------------------------------------------------------------------

	====== Bottom Line ====== 

	Higher-level established patient visits can generate more revenue for the practice. However, it is 
	important to ensure that the services provided and the clinical documentation fully support the CPT code billed.

	*/


/* Question 5:
Analyse the PaymentperUnit (NOT ChargeperUnit). You've been tasked with finding the PaymentperUnit by PayerName. 
Do this analysis on the following visit type (CptDesc) - Initial hospital care
Show each CptCode, CptDesc and associated CptUnits. */


	SELECT
		cc.CptCode,
		cc.CptDesc,
		p.PayerName,
		SUM(ft.CPTUnits)                                                                             AS cptunits,
		FORMAT(-SUM(ft.Payment) / NULLIF(SUM(ft.CPTUnits), 0), '$#')                                 AS payment_per_unit,
		SUM(ft.Payment) / NULLIF(SUM(ft.CPTUnits), 0)                                                AS sort
	FROM FactTable ft
	INNER JOIN dimCptCode cc
		ON ft.dimCPTCodePK = cc.dimCPTCodePK
	INNER JOIN dimPayer p
		ON ft.dimPayerPK = p.dimPayerPK
	WHERE cc.CptDesc = 'Initial hospital care'
	GROUP BY
		cc.CptCode,
		cc.CptDesc,
		p.PayerName
	ORDER BY 6 DESC


/* Question 6:
Within the FactTable we are able to see GrossCharges. Find the NetCharge, which means Contractual adjustments need to 
be subtracted from the GrossCharge (GrossCharges - Contractual Adjustments).

Then calculate the Net Collection Rate (Payments/NetCharge) for each 
physician specialty. 

Which physician specialty has the worst Net Collection Rate with a NetCharge greater than $25,000? 
What is happening here? 

Where are the other dollars and why aren't they being collected?

What does this mean? */


	SELECT
		ProviderSpecialty,
		FORMAT(gross_charges,'$#,#')                                                                       AS gross_charges,
		FORMAT(contractual_adj, '$#,#')                                                                    AS contractual_adj,
		FORMAT(net_charges, '$#,#')                                                                        AS net_charges,
		FORMAT(adjustments-contractual_adj, '$#,#')                                                        AS adjustments,
		FORMAT(-payments / net_charges, 'P0')                                                              AS net_collection_rate,
		FORMAT(AR, '$#,#')                                                                                 AS ar,
		FORMAT(AR/net_charges, 'P0')                                                                       AS percent_in_ar,
		FORMAT(-(adjustments-contractual_adj) / net_charges, 'P0')                                         AS writeoff_percent
	FROM
		(SELECT
			ph.ProviderSpecialty,
			SUM(ft.GrossCharge)                                                                              AS gross_charges,
			SUM(
				CASE
					WHEN t.AdjustmentReason = 'Contractual' THEN ft.Adjustment
					ELSE NULL
				END)                                                                                           AS contractual_adj,
			SUM(ft.GrossCharge) +
			SUM(
				CASE
					WHEN t.AdjustmentReason = 'Contractual' THEN ft.Adjustment
					ELSE NULL
				END)                                                                                           AS net_charges,
			SUM(ft.Payment)                                                                                  AS payments,
			SUM(ft.Adjustment)                                                                               AS adjustments,
			SUM(ft.AR)                                                                                       AS AR
		FROM FactTable ft
		INNER JOIN dimPhysician ph
			ON ft.dimPhysicianPK = ph.dimPhysicianPK
		INNER JOIN dimTransaction t
			ON ft.dimTransactionPK = t.dimTransactionPK
		GROUP BY ph.ProviderSpecialty) t
	WHERE net_charges > 25000
	ORDER BY net_collection_rate ASC

	/* 

	====== What does this mean? ======
	When we look at all the physician specialties, we can see that the hospital is collecting between 83% and 95% of its 
	Net Charges. This means that, overall, the hospital is doing a fairly good job of collecting payments, but there is 
	still room for improvement.

	---------------------------------------------------------------------------------------------------------------------

	====== What Does the Overall Picture Tell Us ======

	-- Obstetrics & Gynecology: Has the lowest collection rate at 83%. 
	   This means the hospital is collecting only 83 cents for every dollar it expects to receive.
	-- Pediatrics: Has a collection rate of 86%, which means 14% of its Net Charges have not been collected.
	-- Nurse Practitioner: Also has an 86% collection rate, with 8% of its Net Charges still in Accounts Receivable.
	-- Radiology: Has a collection rate of 92%. Although this is a good rate, it still has $7,321 in outstanding 
	   Accounts Receivable.
	-- Emergency Medicine: Has a 93% collection rate, meaning most of its expected payments are being collected.
	-- Family Medicine: Has a 95% collection rate, showing that the hospital is collecting most of what it is owed.
	-- Internal Medicine: Also has a 95% collection rate. However, it has the highest outstanding AR balance at $7,735.

	---------------------------------------------------------------------------------------------------------------------

	====== Where Is the Money Going? ======

	The money that hasn't been collected is mainly sitting in Accounts Receivable (AR) or has been written off through 
	other adjustments.

	Accounts Receivable is money that the hospital is still waiting to receive from insurance companies or patients. 
	This money may still be collected if the hospital follows up on unpaid claims and outstanding balances.

	Other adjustments are amounts that have been written off for reasons other than contractual agreements. 
	These amounts are generally no longer expected to be collected.

	---------------------------------------------------------------------------------------------------------------------

	====== Bottom Line ====== 

	Overall, the hospital is collecting most of the money it is owed, but it is still leaving some money on the table.

	The hospital should focus on improving collections in Obstetrics & Gynecology, Pediatrics, and Nurse Practitioners. 
	It should also pay attention to the outstanding AR balances in Internal Medicine and Radiology.

	By following up on unpaid claims, resolving billing issues, and making sure payments are collected on time, the 
	hospital can reduce outstanding balances and bring in more revenue.
	
	*/
