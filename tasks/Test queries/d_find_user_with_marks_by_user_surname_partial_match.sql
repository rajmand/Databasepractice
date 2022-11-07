select s."name", s.surname , er.mark from
              student s join exam_result er on s.student_id  = er.student_id
where surname like '%lastName3000%'