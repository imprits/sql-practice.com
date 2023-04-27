--Show all of the patients grouped into weight groups. Show the total amount of patients in each weight group. Order the list by the weight group decending.*/
select count(patient_id) as patients_in_group
,floor(weight/10)*10 as weight_group
from patients
group by weight_group
order by weight_group desc;

Alternative Soln
SELECT
  TRUNCATE(weight, -1) AS weight_group,
  COUNT(*)
FROM patients
GROUP BY weight_group
ORDER BY weight_group DESC;


--Show patient_id, weight, height, isObese from the patients table. Display isObese as a boolean 0 or 1.
select patient_id
,weight
,height
,case when (weight/power((height/100.0),2))>=30 then 1 else 0 end as isObese
from patients;

Alternative Soln
SELECT
  patient_id,
  weight,
  height,
  weight / POWER(CAST(height AS float) / 100, 2) >= 30 AS obese
FROM patients


--Show patient_id, first_name, last_name, and attending doctors's specialty. Show only the patients who has a primary_diagnosis as 'Epilepsy' and the doctor's first name is 'Lisa'.
select
  p.patient_id,
  p.first_name AS patient_first_name,
  p.last_name AS patient_last_name,
  ph.specialty AS attending_doctor_specialty
from patients p
  join admissions a ON a.patient_id = p.patient_id
  join doctors ph ON ph.doctor_id = a.attending_doctor_id
WHERE
  ph.first_name = 'Lisa' and
  a.diagnosis = 'Epilepsy'

Alternative Soln
SELECT
  pa.patient_id,
  pa.first_name,
  pa.last_name,
  ph1.specialty
FROM patients AS pa
  JOIN (
    SELECT *
    FROM admissions AS a
      JOIN doctors AS ph ON a.attending_doctor_id = ph.doctor_id
  ) AS ph1 USING (patient_id)
WHERE
  ph1.diagnosis = 'Epilepsy'
  AND ph1.first_name = 'Lisa'



/*All patients who have gone through admissions, can see their medical documents on our site. Those patients are given a temporary password after their first admission. Show the patient_id and temp_password.
The password must be the following, in order:
1. patient_id
2. the numerical length of patient's last_name
3. year of patient's birth_date*/
SELECT
  DISTINCT P.patient_id,
  CONCAT(
    P.patient_id,
    LEN(last_name),
    YEAR(birth_date)
  ) AS temp_password
FROM patients P
  JOIN admissions A ON A.patient_id = P.patient_id

--Each admission costs $50 for patients without insurance, and $10 for patients with insurance. All patients with an even patient_id have insurance. Give each patient a 'Yes' if they have insurance, and a 'No' if they don't have insurance. Add up the admission_total cost for each has_insurance group.
select case when patient_id%2=0 then 'Yes' else 'No' end as has_insurance
,case when patient_id%2=0 then count(patient_id)*10 else count(patient_id)*50 end as cost_after_insurance
from admissions
group by has_insurance;

Alternative Soln
select has_insurance,sum(admission_cost) as admission_total
from
(
   select patient_id,
   case when patient_id % 2 = 0 then 'Yes' else 'No' end as has_insurance,
   case when patient_id % 2 = 0 then 10 else 50 end as admission_cost
   from admissions
)
group by has_insurance


--Show the provinces that has more patients identified as 'M' than 'F'.
select pr.province_name
from patients as pa
  join province_names as pr on pa.province_id = pr.province_id
group by pr.province_name
having
  sum(gender = 'M') > sum(gender = 'F');

Alternative Soln
select pr.province_name
from patients as pa
  join province_names as pr on pa.province_id = pr.province_id
group by pr.province_name
having
  count( case when gender = 'M' then 1 end) > count( case when gender = 'F' then 1 end);


/*We are looking for a specific patient. Pull all columns for the patient who matches the following criteria:
- First_name contains an 'r' after the first two letters
- Identifies their gender as 'F'
- Born in February, May, or December
- Their weight would be between 60kg and 80kg
- Their patient_id is an odd number
- They are from the city 'Kingston'*/

select * from patients
where first_name like '__r%' and gender='F' and month(birth_date) in (2,5,12) and weight between 60 and 80 and patient_id%2<>0 and city='Kingston';

Alternative Soln
SELECT *
FROM patients
WHERE
  first_name LIKE '__r%'
  AND gender = 'F'
  AND MONTH(birth_date) IN (2, 5, 12)
  AND weight BETWEEN 60 AND 80
  AND patient_id % 2 = 1
  AND city = 'Kingston';


--Show the percent of patients that have 'M' as their gender. Round the answer to the nearest hundreth number and in percent form.
SELECT CONCAT(
    ROUND(
      (
        SELECT COUNT(*)
        FROM patients
        WHERE gender = 'M'
      ) / CAST(COUNT(*) as float),
      4
    ) * 100,
    '%'
  ) as percent_of_male_patients
FROM patients;


Alternative Soln
SELECT
  round(100 * avg(gender = 'M'), 2) || '%' AS percent_of_male_patients
FROM
  patients;


--For each day display the total amount of admissions on that day. Display the amount changed from the previous date.

with admission_counts_table as (
    select admission_date
    , count(patient_id) as admission_count
    from admissions
    group by admission_date
)
select admission_date
,admission_count
,admission_count - LAG(admission_count) over(order by admission_date) as admission_count_change 
from admission_counts_table;

Alternative Soln
SELECT
 admission_date,
 count(admission_date) as admission_day,
 count(admission_date) - LAG(count(admission_date)) OVER(ORDER BY admission_date) AS admission_count_change 
FROM admissions
 group by admission_date


--Sort the province names in ascending order in such a way that the province 'Ontario' is always on top.
select province_name
from province_names
order by
  (case when province_name = 'Ontario' then 0 else 1 end),
  province_name

Alternative Soln
select province_name
from province_names
order by
  province_name = 'Ontario' desc,
  province_name