TRUNCATE PUBLIC.subject CASCADE;
DO $$
BEGIN
FOR counter IN 1..1000 LOOP
INSERT INTO public.subject(	
	SUBJECT_NAME, 
	TUTOR
) VALUES (	
	concat('subject', counter),
	concat('tutor', counter % 333)
);
END LOOP;
END;
$$
;
COMMIT;