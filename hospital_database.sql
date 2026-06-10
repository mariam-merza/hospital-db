-- =============================================================================
-- Hospital Database
-- Created by: Mariam Merza
-- =============================================================================
-- DESCRIPTION:
--   A relational database for managing healthcare facility operations,
--   including hospitals, doctors, patients, appointments, and medical
--   equipment (with imaging and surgical subclasses).
--
-- SCHEMA OVERVIEW:
--   Hospital       - Medical facilities
--   Doctor         - Medical professionals (recursive supervisor relationship)
--   Patient        - Patients seeking care
--   Appointment    - Scheduled consultations (weak entity, depends on Doctor)
--   Equipment      - Medical equipment inventory (superclass)
--   Imaging        - Subclass of Equipment for imaging devices
--   Surgical       - Subclass of Equipment for surgical tools
-- =============================================================================


-- -----------------------------------------------------------------------------
-- TABLE: Hospital
-- Stores information about each medical facility.
--
-- Primary Key: Hospital_ID
-- -----------------------------------------------------------------------------
CREATE TABLE Hospital (
    Hospital_ID  INT            PRIMARY KEY,
    Name         VARCHAR(100),       -- Full name of the hospital
    Location     VARCHAR(100),       -- City and country (e.g. 'New York, USA')
    Rating       FLOAT               -- Average rating score (e.g. 4.7)
);

INSERT INTO Hospital (Hospital_ID, Name, Location, Rating) VALUES
    (1, 'City Hospital',             'New York, USA',       4.7),
    (2, 'Medical Center',            'London, UK',          4.5),
    (3, 'Community Health Center',   'San Francisco, USA',  4.2),
    (4, 'Central Hospital',          'Paris, France',       4.9),
    (5, 'Metropolitan Hospital',     'Tokyo, Japan',        4.6),
    (6, 'Regional Medical Center',   'Sydney, Australia',   4.3),
    (7, 'Health First Clinic',       'Toronto, Canada',     4.8),
    (8, 'Sunset General Hospital',   'Los Angeles, USA',    4.4);


-- -----------------------------------------------------------------------------
-- TABLE: Doctor
-- Stores profiles of medical professionals.
--
-- Primary Key:   Doctor_ID
-- Foreign Keys:  Hospital_ID  -> Hospital(Hospital_ID)
--                Supervisor_ID -> Doctor(Doctor_ID)   [recursive / self-referencing]
--
-- NOTE: Supervisor_ID is NULL for doctors with no supervisor (top of hierarchy).
-- -----------------------------------------------------------------------------
CREATE TABLE Doctor (
    Doctor_ID      INT            PRIMARY KEY,
    Name           VARCHAR(100),       -- Full name including title (e.g. 'Dr. Sarah Adams')
    Specialization VARCHAR(100),       -- Medical specialization (e.g. 'Cardiologist')
    Hospital_ID    INT,                -- Hospital the doctor is affiliated with
    Supervisor_ID  INT,                -- Supervisor within the same Doctor table (self-join)
    FOREIGN KEY (Hospital_ID)   REFERENCES Hospital(Hospital_ID),
    FOREIGN KEY (Supervisor_ID) REFERENCES Doctor(Doctor_ID)
);

INSERT INTO Doctor (Doctor_ID, Name, Specialization, Hospital_ID, Supervisor_ID) VALUES
    (1, 'Dr. Sarah Adams',      'Cardiologist',       1, NULL),
    (2, 'Dr. Mark Johnson',     'Pediatrician',       2, 1),
    (3, 'Dr. Emma Garcia',      'Neurologist',        3, NULL),
    (4, 'Dr. Michael Brown',    'Surgeon',            4, 3),
    (5, 'Dr. James Lee',        'Orthopedic Surgeon', 5, NULL),
    (6, 'Dr. Samantha Roberts', 'Dermatologist',      6, 5),
    (7, 'Dr. Lucas Baker',      'Pediatrician',       7, NULL),
    (8, 'Dr. Emma Foster',      'Psychiatrist',       8, 7);


-- -----------------------------------------------------------------------------
-- TABLE: Patient
-- Stores information about patients registered in the system.
--
-- Primary Key: Patient_ID
-- -----------------------------------------------------------------------------
CREATE TABLE Patient (
    Patient_ID  INT            PRIMARY KEY,
    Name        VARCHAR(100),       -- Full name of the patient
    Age         INT,                -- Age in years
    Phone_Num   VARCHAR(20)         -- Contact phone number (international format)
);

INSERT INTO Patient (Patient_ID, Name, Age, Phone_Num) VALUES
    (1, 'John Smith',       45, '+1234567890'),
    (2, 'Emily Johnson',    30, '+1987654321'),
    (3, 'Sophia Anderson',  28, '+1122334455'),
    (4, 'Oliver Wilson',    50, '+9988776655'),
    (5, 'Liam Miller',      35, '+447700112233'),
    (6, 'Ava Brown',        24, '+61400998877'),
    (7, 'Noah Garcia',      42, '+1234001122'),
    (8, 'Mia Wilson',       60, '+18005556666');


-- -----------------------------------------------------------------------------
-- TABLE: Appointment
-- Records scheduled consultations between patients and doctors.
--
-- NOTE: Appointment is a WEAK ENTITY — its identity depends on the Doctor entity.
--
-- Primary Key (composite): Appointment_ID + Doctor_ID
-- Foreign Keys:  Doctor_ID  -> Doctor(Doctor_ID)
--                Patient_ID -> Patient(Patient_ID)
-- -----------------------------------------------------------------------------
CREATE TABLE Appointment (
    Appointment_ID  INT,
    Date            DATETIME,           -- Scheduled date and time of appointment
    Room            INT,                -- Room number for the appointment
    Doctor_ID       INT,                -- Attending doctor
    Patient_ID      INT,                -- Patient being seen
    PRIMARY KEY (Appointment_ID, Doctor_ID),
    FOREIGN KEY (Doctor_ID)  REFERENCES Doctor(Doctor_ID),
    FOREIGN KEY (Patient_ID) REFERENCES Patient(Patient_ID)
);

INSERT INTO Appointment (Appointment_ID, Date, Room, Doctor_ID, Patient_ID) VALUES
    (1, '2023-12-10 09:00:00', 101, 1, 1),
    (2, '2023-12-15 10:30:00', 205, 2, 2),
    (3, '2023-12-18 11:15:00', 302, 3, 3),
    (4, '2023-12-20 14:00:00', 104, 4, 4),
    (5, '2023-12-22 08:45:00', 402, 5, 5),
    (6, '2023-12-25 16:30:00', 201, 6, 6),
    (7, '2023-12-28 13:45:00', 301, 7, 7),
    (8, '2023-12-30 12:00:00', 103, 8, 8);


-- -----------------------------------------------------------------------------
-- TABLE: Equipment
-- Superclass table for all medical equipment in the hospital inventory.
--
-- Primary Key:  Equipment_ID
-- Foreign Key:  Hospital_ID -> Hospital(Hospital_ID)
--
-- NOTE: Imaging and Surgical are subclasses of this table.
--       Equipment_IDs 1,2,3,5,6 are Imaging; 4,7,8 are Surgical.
-- -----------------------------------------------------------------------------
CREATE TABLE Equipment (
    Equipment_ID     INT            PRIMARY KEY,
    Name             VARCHAR(100),       -- Equipment name (e.g. 'MRI Scanner')
    Manufacturer     VARCHAR(100),       -- Manufacturer name
    ManufacturedYear INT,                -- Year of manufacture
    Amount           INT,                -- Quantity available at the hospital
    Hospital_ID      INT,                -- Hospital that owns the equipment
    FOREIGN KEY (Hospital_ID) REFERENCES Hospital(Hospital_ID)
);

INSERT INTO Equipment (Equipment_ID, Name, Manufacturer, ManufacturedYear, Amount, Hospital_ID) VALUES
    (1, 'MRI Scanner',        'ABC Medical',       2020, 3, 1),
    (2, 'X-Ray Machine',      'XYZ Healthcare',    2019, 2, 2),
    (3, 'Ultrasound Machine', 'MedTech Solutions', 2021, 4, 3),
    (4, 'Bob',                'SurgiEquip',        2018, 6, 4),
    (5, 'CT Scanner',         'MediScan',          2022, 3, 5),
    (6, 'Endoscopy Tower',    'EndoTech',          2020, 4, 6),
    (7, 'Table',              'AnesLife',          2023, 5, 7),
    (8, 'Cutter',             'ElectroEquip',      2019, 7, 8);


-- -----------------------------------------------------------------------------
-- TABLE: Imaging
-- Subclass of Equipment. Stores attributes specific to imaging devices.
--
-- Primary Key:  Equipment_ID (also FK to Equipment)
-- Foreign Key:  Equipment_ID -> Equipment(Equipment_ID)
-- -----------------------------------------------------------------------------
CREATE TABLE Imaging (
    Equipment_ID  INT            PRIMARY KEY,
    ImagingType   VARCHAR(100),       -- Type of imaging (e.g. 'MRI', 'X-Ray')
    Resolution    VARCHAR(50),        -- Image quality (e.g. 'High Definition')
    FOREIGN KEY (Equipment_ID) REFERENCES Equipment(Equipment_ID)
);

INSERT INTO Imaging (Equipment_ID, ImagingType, Resolution) VALUES
    (1, 'MRI',        'High Definition'),
    (2, 'X-Ray',      'Standard Resolution'),
    (3, 'Ultrasound', 'Digital Imaging'),
    (5, 'CT Scan',    'Enhanced Imaging'),
    (6, 'Endoscopy',  'High Definition');


-- -----------------------------------------------------------------------------
-- TABLE: Surgical
-- Subclass of Equipment. Stores attributes specific to surgical instruments.
--
-- Primary Key:  Equipment_ID (also FK to Equipment)
-- Foreign Key:  Equipment_ID -> Equipment(Equipment_ID)
-- -----------------------------------------------------------------------------
CREATE TABLE Surgical (
    Equipment_ID     INT            PRIMARY KEY,
    SurgicalType     VARCHAR(100),       -- Type of surgical tool (e.g. 'Surgical Robot')
    ReplacementDate  DATETIME,           -- Scheduled replacement or maintenance date
    FOREIGN KEY (Equipment_ID) REFERENCES Equipment(Equipment_ID)
);

INSERT INTO Surgical (Equipment_ID, SurgicalType, ReplacementDate) VALUES
    (4, 'Surgical Robot',  '2023-05-15'),
    (7, 'Operating Table', '2024-01-20'),
    (8, 'Scalpel',         '2023-04-05');


-- =============================================================================
-- QUERIES
-- =============================================================================


-- -----------------------------------------------------------------------------
-- QUERY 1: Single-table — List all hospital names and locations
-- Returns the name and location of every hospital in the system.
-- -----------------------------------------------------------------------------
SELECT Name, Location
FROM Hospital;


-- -----------------------------------------------------------------------------
-- QUERY 2: Single-table — Calculate the average hospital rating
-- Uses AVG() to compute the mean rating across all hospitals.
-- -----------------------------------------------------------------------------
SELECT AVG(Rating) AS Avg_Rating
FROM Hospital;


-- -----------------------------------------------------------------------------
-- QUERY 3: Single-table with subquery — Hospitals above average rating
-- Returns hospitals whose rating exceeds the overall average,
-- using a correlated subquery to compute the average inline.
-- -----------------------------------------------------------------------------
SELECT Name, Rating
FROM Hospital
WHERE Rating > (
    SELECT AVG(Rating)
    FROM Hospital
);


-- -----------------------------------------------------------------------------
-- QUERY 4: Two-table JOIN — Doctors with their affiliated hospital
-- Joins Doctor and Hospital on Hospital_ID to display each doctor's
-- name alongside the hospital they work at.
-- -----------------------------------------------------------------------------
SELECT
    Doctor.Name   AS Doctor_Name,
    Hospital.Name AS Hospital_Name
FROM Doctor
INNER JOIN Hospital ON Doctor.Hospital_ID = Hospital.Hospital_ID;


-- -----------------------------------------------------------------------------
-- QUERY 5: Two-table JOIN — Total equipment per hospital
-- Left joins Hospital and Equipment to sum equipment quantities per hospital.
-- Includes hospitals even if they have no equipment (LEFT JOIN).
-- -----------------------------------------------------------------------------
SELECT
    Hospital.Hospital_ID,
    Hospital.Name             AS Hospital_Name,
    SUM(Equipment.Amount)     AS Total_Equipment_Amount
FROM Hospital
LEFT JOIN Equipment ON Hospital.Hospital_ID = Equipment.Hospital_ID
GROUP BY Hospital.Hospital_ID, Hospital.Name;


-- -----------------------------------------------------------------------------
-- QUERY 6: Two-table UNION — Combined equipment type listing
-- Merges both equipment subclasses (Imaging and Surgical) into one result set.
-- UNION automatically removes duplicate rows.
-- -----------------------------------------------------------------------------
SELECT Equipment_ID, ImagingType  AS EquipmentType FROM Imaging
UNION
SELECT Equipment_ID, SurgicalType AS EquipmentType FROM Surgical;


-- -----------------------------------------------------------------------------
-- QUERY 7: Three-table JOIN — Appointment details with doctor and hospital info
-- Joins Appointment -> Doctor -> Hospital to show each appointment alongside
-- the attending doctor's name and their affiliated hospital.
-- -----------------------------------------------------------------------------
SELECT
    Appointment.Appointment_ID,
    Appointment.Date,
    Appointment.Room,
    Doctor.Name   AS Doctor_Name,
    Hospital.Name AS Hospital_Name
FROM Appointment
INNER JOIN Doctor   ON Appointment.Doctor_ID   = Doctor.Doctor_ID
INNER JOIN Hospital ON Doctor.Hospital_ID      = Hospital.Hospital_ID;


-- -----------------------------------------------------------------------------
-- QUERY 8: Three-table JOIN — Patients seen by a Pediatrician
-- Retrieves unique patient names who have had an appointment with a doctor
-- whose specialization is 'Pediatrician'.
-- -----------------------------------------------------------------------------
SELECT DISTINCT Patient.Name AS Patient_Name
FROM Patient
INNER JOIN Appointment ON Patient.Patient_ID    = Appointment.Patient_ID
INNER JOIN Doctor      ON Appointment.Doctor_ID = Doctor.Doctor_ID
WHERE Doctor.Specialization = 'Pediatrician';


-- -----------------------------------------------------------------------------
-- QUERY 9: Three-table JOIN with EXISTS — Hospitals with active appointments
-- Returns the names of hospitals that have at least one doctor with a
-- scheduled appointment in the system, using correlated EXISTS subqueries.
-- -----------------------------------------------------------------------------
SELECT DISTINCT H1.Name
FROM Hospital H1
INNER JOIN Hospital H2 ON H1.Name = H2.Name
WHERE EXISTS (
    SELECT *
    FROM Doctor D
    INNER JOIN Appointment A ON D.Doctor_ID = A.Doctor_ID
    WHERE D.Hospital_ID = H1.Hospital_ID
)
AND EXISTS (
    SELECT *
    FROM Doctor D
    INNER JOIN Appointment A ON D.Doctor_ID = A.Doctor_ID
    WHERE D.Hospital_ID = H2.Hospital_ID
);
