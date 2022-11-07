CREATE OR REPLACE FUNCTION avg_mark_for_subject(in TEXT)
RETURNS NUMERIC AS $BODY$
    SELECT AVG(exam_result.mark)
    FROM subject, exam_result
    WHERE subject.subject_name = $1
    AND subject.subject_id = exam_result.subject_id;
$BODY$ LANGUAGE sql;
