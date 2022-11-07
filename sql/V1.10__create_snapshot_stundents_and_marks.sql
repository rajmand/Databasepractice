CREATE TABLE students_snapshot as
SELECT student.name AS student_name, student.surname AS student_surname, subject.subject_name, exam_result.mark
from  student, subject, exam_result
WHERE student.student_id = exam_result.student_id
AND exam_result.subject_id = subject.subject_id;
