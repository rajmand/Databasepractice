CREATE OR REPLACE FUNCTION avg_mark_for_user(user_id INT)
RETURNS NUMERIC AS $BODY$
    SELECT AVG(exam_result.mark)
    FROM exam_result
    WHERE exam_result.student_id = user_id;    
$BODY$ LANGUAGE sql;
