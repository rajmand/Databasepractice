TRUNCATE PUBLIC.student_address CASCADE;
DO $$
BEGIN
FOR counter IN 1..100000 LOOP
INSERT INTO public.student_address (
	address_id, 
	student_id, 
	address 
) VALUES (
	nextval('student_address_id_seq'),
	counter,
	concat('address_', counter)
);
END LOOP;
END;
$$
;
COMMIT;