TRUNCATE PUBLIC.exam_result CASCADE;
DO $$
BEGIN
FOR counter IN 1..1000000 LOOP
INSERT INTO exam_result(	
	student_id, 
	subject_id,
	mark
) VALUES (	
	floor(random() * 100000 + 1)::int,
	floor(random() * 1000 + 1)::int,
	floor(random() * 5 + 1)::int
	
);
END LOOP;
END;
$$
;
COMMIT;