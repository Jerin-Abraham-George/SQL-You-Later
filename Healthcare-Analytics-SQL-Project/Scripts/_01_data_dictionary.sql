/*
===========================================================================
                                DATA DICTIONARY
===========================================================================

TABLE: FactTable
---------------------------------------------------------------------------

Column Name          Definition
---------------------------------------------------------------------------
FactTablePK          Unique identifier (Primary Key) for the fact table.

dimPatientPK         Unique identifier that joins the patient
                     table to the fact table.

dimPhysicianPK       Unique identifier that joins the physician
                     table to the fact table.

dimDatePostPK        Text formatted date that specifies the day
                     the transaction was posted to the billing system.

dimDateServicePK     Text formatted date that specifies the day
                     the patient was seen by the physician.

dimCPTCodePK         Unique identifier that joins the CPT table
                     to the fact table.

dimPayerPK           Unique identifier that joins the payer table
                     to the fact table.

dimTransactionPK     Unique identifier that joins the transaction
                     table to the fact table.

dimLocationPK        Unique identifier that joins the location
                     table to the fact table.

dimDiagnosisCodePK   Unique identifier that joins the diagnosis
                     code table to the fact table.

PatientNumber        Unique Patient identifier (MRN).

CPTUnits             The number of times the CPT Code has been performed.

GrossCharge          The gross charge for the CPT Code.
                     This includes the contractual adjustment.

Payment              Payment received from payer and patient.

Adjustment           Any dollars from the gross charge that will
                     not be collected.

AR                   Outstanding accounts receivable that have
                     yet to be collected or written off.


TABLE: dimPatient
---------------------------------------------------------------------------

FirstName            First Name of the patient.
LastName             Last Name of the patient.
Email                Patient's email address.
PatientGender        Gender/Sex of the patient.
PatientAge           Patient's age.
City                 City that the patient lives in.
State                State that the patient lives in.


TABLE: dimTransaction
---------------------------------------------------------------------------

TransactionType     Clarifies whether the transaction was a
                    charge, payment, adjustment, etc.

Transaction         Specific transaction descriptions.

AdjustmentReason    Groups adjustments into operational reason groups.


TABLE: dimPhysician
---------------------------------------------------------------------------

ProviderNpi          Unique number assigned to each physician
                     upon completion of medical school.

ProviderName         Physician's last name.

ProviderSpecialty    Area in which the physician has specialized.

ProviderFTE          Physician time spent working on a weekly basis.


TABLE: dimPayer
---------------------------------------------------------------------------

PayerName            Payer category.


TABLE: dimLocation
---------------------------------------------------------------------------

LocationName         Specifies where the service was rendered.


TABLE: dimDiagnosisCode
---------------------------------------------------------------------------

DiagnosisCode              Code assigned by the physician to
                           specify the patient's diagnosis.

DiagnosisCode
Description                Description to clarify the diagnosis code.

DiagnosisCodeGroup         Group of diagnosis codes.


TABLE: dimCptCode
---------------------------------------------------------------------------

CptCode              Five-digit Current Procedural Terminology
                     code used to assign services rendered
                     to the patient.

CptDesc              Specific CPT description.

CptGrouping          Groups the CPT codes into types of services.


TABLE: dimDate
---------------------------------------------------------------------------

Date                 Date format - either date service was rendered
                     or date of a transaction.

Year                 Year - either date service was rendered
                     or date of a transaction.

Month                Month - either date service was rendered
                     or date of a transaction.

MonthPeriod          YYYYMM text format.

MonthYear            Month and Year.

Day                  Day of Month Number.

DayName              Day of week name.

===========================================================================
                    END OF DATA DICTIONARY
===========================================================================
*/
