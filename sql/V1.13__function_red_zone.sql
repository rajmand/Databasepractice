CREATE OR REPLACE FUNCTION get_red_zone_students()
RETURNS TABLE(student_id INT,
              student_name TEXT,
              student_surname text,
              average_mark numeric
              ) AS
$func$
BEGIN
    RETURN QUERY (
        SELECT st.student_id, st.name, st.surname
        FROM student AS st, exam_result AS res
        WHERE res.mark <= 3
        AND st.student_id = res.student_id
        GROUP BY st.student_id HAVING COUNT (*) >= 2
    );
END
$func$ LANGUAGE plpgsql;
