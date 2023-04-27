--Show unique birth years from patients and order them by ascending.
select distinct year(birth_date)
from patients
order by year(birth_date);

Alternative Soln 
select year(birth_date)
from patients
group by year(birth_date)


--Show unique first names from the patients table which only occurs once in the list.
Select first_name
from patients
group by first_name
having count(*)=1;

Alternative Soln
SELECT first_name
FROM (
    SELECT
      first_name,
      COUNT(first_name) AS occurrencies
    FROM patients
    GROUP BY first_name
  )
WHERE occurrencies = 1


--Show patient_id and first_name from patients where their first_name start and ends with 's' and is at least 6 characters long.
Select patient_id
,first_name
from patients
where first_name like 'S____%s';

Alternative Soln
SELECT
  patient_id,
  first_name
FROM patients
WHERE
  first_name LIKE 's%s'
  AND LEN(first_name) >= 6;


--Show patient_id, first_name, last_name from patients whos diagnosis is 'Dementia'.
Select patient_id
,first_name
,last_name
from patients 
join admissions using(patient_id) 
where diagnosis='Dementia';

Alternative Soln
​SELECT
  patient_id,
  first_name,
  last_name
FROM patients
WHERE patient_id IN (
    SELECT patient_id
    FROM admissions
    WHERE diagnosis = 'Dementia'
  );


--Display every patient's first_name. Order the list by the length of each name and then by alphbetically.
Select first_name
from patients
order by length(first_name)
,first_name;


--Show the total amount of male patients and the total amount of female patients in the patients table. Display the two results in the same row.
Select count(case when gender='M' then 1 end) as male_count
,count(case when gender='F' then 1 end) as female_count
from patients;

Alternative Soln
SELECT 
  SUM(Gender = 'M') as male_count, 
  SUM(Gender = 'F') AS female_count
FROM patients


--Show first and last name, allergies from patients which have allergies to either 'Penicillin' or 'Morphine'. Show results ordered ascending by allergies then by first_name then by last_name.
select first_name
,last_name
,allergies
from patients
where allergies in ('Penicillin','Morphine')
order by allergies
,first_name
,last_name;

Alternative Soln
SELECT
  first_name,
  last_name,
  allergies
FROM
  patients
WHERE
  allergies = 'Penicillin'
  OR allergies = 'Morphine'
ORDER BY
  allergies ASC,
  first_name ASC,
  last_name ASC;


--Show patient_id, diagnosis from admissions. Find patients admitted multiple times for the same diagnosis.
select patient_id
,diagnosis
from admissions
group by patient_id
,diagnosis
having count(*)>1;


--Show the city and the total number of patients in the city in the order from most to least patients.
select city
,count(distinct patient_id)
from patients
group by city
order by count(patient_id) desc, city asc;

Alternative Soln
select
  city,
  count(*) AS num_patients
from patients
group by city
order by num_patients DESC, city asc;


--Show first name, last name and role of every person that is either patient or doctor.
SELECT first_name, last_name, 'Patient' as role FROM patients
    union all
select first_name, last_name, 'Doctor' from doctors;


--Show all allergies ordered by popularity. Remove 'NKA' and NULL values from query.
select allergies
,count(allergies)
from patients
where allergies is not null and allergies<>'NKA'
group by allergies
order by count(allergies) desc;

Alternative Solutions
SELECT
  allergies,
  COUNT(*)
FROM patients
WHERE allergies NOT NULL
GROUP BY allergies
ORDER BY COUNT(*) DESC


--Show all patient's first_name, last_name, and birth_date who were born in the 1970s decade. Sort the list starting from the earliest birth_date.
select first_name
,last_name
,birth_date
from patients
where birth_date between '1970-01-01' and '1979-12-31'
order by birth_date;

Alternative Soln
SELECT
  first_name,
  last_name,
  birth_date
FROM patients
WHERE
  birth_date >= '1970-01-01'
  AND birth_date < '1980-01-01'
ORDER BY birth_date ASC


--We want to display each patient's full name in a single column. Their last_name in all upper letters must appear first, then first_name in all lower case letters. Separate the last_name and first_name with a comma. Order the list by the first_name in decending order.
select concat(upper(last_name),',',lower(first_name)) as full_name
from patients
order by first_name desc;

Alternative Soln
SELECT
  UPPER(last_name) || ',' || LOWER(first_name) AS new_name_format
FROM patients
ORDER BY first_name DESC;


--Show the province_id(s), sum of height; where the total sum of its patient's height is greater than or equal to 7,000.
select province_id
,sum(height)
from patients
group by province_id
having sum(height)>6999;

Alternative Soln
SELECT
  province_id,
  SUM(height) AS sum_height
FROM patients
GROUP BY province_id
HAVING sum_height >= 7000


--Show the difference between the largest weight and smallest weight for patients with the last name 'Maroni'.
select max(weight)-min(weight)
from patients
where last_name='Maroni';

Alternative Soln
SELECT
  (MAX(weight) - MIN(weight)) AS weight_delta
FROM patients
WHERE last_name = 'Maroni';


--Show all of the days of the month (1-31) and how many admission_dates occurred on that day. Sort by the day with most admissions to least admissions.
select day(admission_date)
,count(admission_date)
from admissions
group by day(admission_date)
order by count(admission_date) desc;

Alternative Soln
SELECT
  DAY(admission_date) AS day_number,
  COUNT(*) AS number_of_admissions
FROM admissions
GROUP BY day_number
ORDER BY number_of_admissions DESC


--Show all columns for patient_id 542's most recent admission_date..
SELECT *
FROM admissions
WHERE patient_id = 542
GROUP BY patient_id
HAVING
  admission_date = MAX(admission_date);

Alternative Soln
​SELECT *
FROM admissions
WHERE
  patient_id = '542'
  AND admission_date = (
    SELECT MAX(admission_date)
    FROM admissions
    WHERE patient_id = '542'
  )


--Show the nursing_unit_id and count of admissions for each nursing_unit_id. Exclude the following nursing_unit_ids: 'CCU', 'OR', 'ICU', 'ER'.
select nursing_unit_id
,count(patient_id)
from admissions
where nursing_unit_id not in ('CCU','OR','ICU','ER')
group by nursing_unit_id;


/*Show patient_id, attending_doctor_id, and diagnosis for admissions that match one of the two criteria:
1. patient_id is an odd number and attending_doctor_id is either 1, 5, or 19.
2. attending_doctor_id contains a 2 and the length of patient_id is 3 characters.
select
  patient_id,
  attending_doctor_id,
  diagnosis
from admissions
where
  (
    attending_doctor_id in (1, 5, 19)
    and patient_id % 2 != 0
  )
  OR 
  (
    attending_doctor_id like '%2%'
    and len(patient_id) = 3
  )

--Show first_name, last_name, and the total amount of admissions attended for each doctor.
select first_name
,last_name
,count(patient_id) as total_amount_of_admissions_attended
from doctors p
join admissions a on p.doctor_id=a.attending_doctor_id
group by doctor_id;

Alternative Soln
SELECT
  first_name,
  last_name,
  count(*)
from
  doctors p,
  admissions a
where
  a.attending_doctor_id = p.doctor_id
group by p.doctor_id;


--For each doctor, display their id, full name, and the first and last admission date they attended.
select doctor_id
,concat(first_name,' ',last_name) as full_name
,max(a.admission_date)
,min(a.admission_date)
from doctors p
join admissions a on p.doctor_id=a.attending_doctor_id
group by doctor_id;


--Display the total amount of patients for each province. Order by descending.
select
  province_name,
  count(*) as patient_count
from patients pa
  join province_names pr on pr.province_id = pa.province_id
group by pr.province_id
order by patient_count desc;


--For every admission, display the patient's full name, their admission diagnosis, and their doctor's
 full name who diagnosed their problem.
select
  concat(patients.first_name, ' ', patients.last_name) as patient_name,
  diagnosis,
  concat(doctors.first_name,' ',doctors.last_name) as doctor_name
from patients
  join admissions ON admissions.patient_id = patients.patient_id
  join doctors ON doctors.doctor_id = admissions.attending_doctor_id;


--display the number of duplicate patients based on their first_name and last_name.
select
  first_name,
  last_name,
  count(*) as num_of_duplicates
from patients
group by
  first_name,
  last_name
having count(*) > 1


--Display patient's full name,
height in the units feet rounded to 1 decimal,
weight in the unit pounds rounded to 0 decimals,
birth_date,
gender non abbreviated.

Convert CM to feet by dividing by 30.48.
Convert KG to pounds by multiplying by 2.205.
select
    concat(first_name, ' ', last_name) as 'patient_name', 
    round(height / 30.48, 1) as 'height "Feet"', 
    round(weight * 2.205, 0) AS 'weight "Pounds"', birth_date,
case
	when gender = 'M' then 'MALE' 
  else 'FEMALE' 
end as 'gender_type'
from patients
