-- 1. Select all primary skills that contain more than one word (please note that both ‘-‘ and ‘ ’ could be used as a separator).
SELECT DISTINCT primary_skill
FROM student
WHERE primary_skill::text LIKE '% %' OR primary_skill::text LIKE '%-%';

--2. Select all students who do not have a second name (it is absent or consists of only one letter/letter with a dot).
SELECT *
FROM student
WHERE surname = '' OR surname IS NULL OR surname SIMILAR TO '[.]?\w[.]?';

--3. Select number of students passed exams for each subject and order result by a number of student descending.
with passed_exams AS (
	select subject_id, count(*) as number_of_students_passed from exam_result
	where mark > 1
	group by subject_id)
select 
	s.subject_name,
	coalesce(e.number_of_students_passed, 0) as number_of_students_passed
from subject s
left outer join passed_exams e on e.subject_id = s.subject_id
order by number_of_students_passed desc;


-- 4. Select the number of students with the same exam marks for each subject.
WITH same_marks AS (
	select student_id, count(distinct mark) as num_of_distinct_marks from exam_result
	group by student_id)
select count(*) as number_of_students_with_only_one_kind_of_marks
from student s
inner join same_marks s_m on s_m.student_id = s.student_id
where s_m.num_of_distinct_marks = 1;


-- 5. Select students who passed at least two exams for different subjects.
WITH students_by_exams_passed AS (
	select student_id, count(distinct subject_id) as num_of_distinct_subjects from exam_result
	where mark > 1
	group by student_id)
select s.*
from student s
inner join students_by_exams_passed s_m on s_m.student_id = s.student_id
where s_m.num_of_distinct_subjects >= 2;

-- 6. Select students who passed at least two exams for the same subject.
WITH students_by_subjects_by_passed_exams AS (
	select distinct student_id, subject_id, count(*) as number_of_passed_exams from exam_result
	where mark > 1
	group by student_id, subject_id)
select s.*
from student s
inner join students_by_subjects_by_passed_exams s_m on s_m.student_id = s.student_id
where s_m.number_of_passed_exams >= 2;

-- 7. Select all subjects which exams passed only students with the same primary skills.
WITH num_of_distinct_primary_skills_by_passed_exams AS (
	select count(distinct s.primary_skill) num_skills, e.subject_id 
	from exam_result e
	inner join student s on s.student_id = e.student_id
	where mark > 1
	group by e.subject_id)
select s.*
from subject s
inner join num_of_distinct_primary_skills_by_passed_exams n_s on n_s.subject_id = s.subject_id
where n_s.num_skills = 5;

-- 8. Select all subjects which exams passed only students with the different primary skills. It means that all students passed the exam for the one subject must have different primary skill.
WITH num_of_distinct_primary_skills_by_passed_exams 
AS (
	select count(distinct s.primary_skill) num_skills, e.subject_id from exam_result e
	inner join student s on s.student_id = e.student_id
	where mark > 1
	group by e.subject_id
	),
	num_of_students_passed AS (
		select count(student_id) as num_students, subject_id from exam_result
		where mark > 1
		group by subject_id
	)
select s.*
from subject s
inner join num_of_distinct_primary_skills_by_passed_exams n_s on n_s.subject_id = s.subject_id
inner join num_of_students_passed n_s_p on n_s_p.subject_id = s.subject_id
where n_s.num_skills = n_s_p.num_students;

-- 9.1 Select students who do not pass any exam using each of the following operator: Outer join
WITH num_exams_passed_per_student AS (
	select count(distinct exam_result_id) num_exams_passed, student_id from exam_result
	where mark > 1
	group by student_id)
select s.*
from student s
left outer join num_exams_passed_per_student nep on nep.student_id = s.student_id
where coalesce(nep.num_exams_passed, 0) = 0
order by s.student_id;

-- 9.2 Select students who do not pass any exam using each of the following operator: Subquery with ‘not in’ clause
select *
from student
where student_id not in (
	select distinct student_id from exam_result
	where mark > 1
);

-- 9.3 Select students who do not pass any exam using each of the following operator: Subquery with ‘any ‘ clause
WITH student_ids_passed as (select distinct student_id from exam_result where mark > 1)
select *
from student
where student_id = 
ANY (
	select student_id from student 
	except select * from student_ids_passed
	);

-- 10 Select all students whose average mark is bigger than the overall average mark.
with student_average_mark as (
	select avg(mark) as average_mark, student_id  
	from exam_result er
	group by student_id
)
select 
s.student_id,
s.name,
s.surname,
average_mark
from student s
inner join student_average_mark average on average.student_id = s.student_id 
where average.average_mark > (select max(average_mark) from student_average_mark)

-- 11 Select the top 5 students who passed their last exam better than average students.
-- I was not sure top by subject or overal? (solution picking top 5 from overal)
with subject_average as (
	select 
	avg(mark) as average_mark_subject,
	subject_id 
	from exam_result er
	group by subject_id
)
select 
student_id,
er.subject_id,
avg(mark) as stundent_average ,
subject_average.average_mark_subject as subject_average
from exam_result er
inner join subject_average on subject_average.subject_id = er.subject_id 
group by er.subject_id,student_id, subject_average.average_mark_subject
having avg(mark) > subject_average.average_mark_subject
order by subject_id, stundent_average desc
limit 5;

-- 12 Select the biggest mark for each student and add text description for the mark (use COALESCE and WHEN operators)
-- NOTE: exam result fillig from mark 1 to 5. So I have to change the query to it became usable
with student_highest_mark as (
	select 
	student_id,
	max(mark) as highest_mark
	from exam_result er 
	group by student_id 
)
select 
s.student_id ,
s.name,
s.surname,
shm.highest_mark,
case when shm.highest_mark is null then 'not passed'
	 when shm.highest_mark = 1 then 'BAD'
	 when shm.highest_mark = 2 then 'BAD'
	 when shm.highest_mark = 3 then 'AVERAGE'
	 when shm.highest_mark = 4 then 'GOOD'
	 when shm.highest_mark = 5 then 'EXCELLENT'
	 else '-'
	 end as mark_description
from student s
left outer join student_highest_mark shm on shm.student_id = s.student_id 

-- 13 Select the number of all marks for each mark type (‘BAD’, ‘AVERAGE’,…).
select case when mark = 1 then 'BAD'
	 		when mark = 2 then 'BAD'
			when mark = 3 then 'AVERAGE'
			when mark = 4 then 'GOOD'
			else 'EXCELLENT'
			end as mark_description,
			count(*) as mark_count
		from exam_result
		group by mark_description;
