TRUNCATE PUBLIC.student CASCADE;
DO $$
BEGIN
FOR counter IN 1..100000 LOOP
INSERT INTO PUBLIC.student(	
	name, 
	surname, 
	birth_date, 
	phone_number,
	primary_skill, 
	created, 
	updated
) VALUES (	
	concat('firstName', counter % 3000),
	(CASE (RANDOM()*4)::INT
		WHEN 0 THEN concat('lastName', counter % 7000)
		WHEN 1 THEN ''
		WHEN 2 THEN null		
        WHEN 3 THEN 'A'
		WHEN 4 THEN 'B.'		
		end
		)::text,
	
	
	NOW() - '1 year'::INTERVAL * ROUND(RANDOM() * 100),
	regexp_replace(CAST (random() AS text),'^0\.(\d{3})(\d{3})(\d{4}).*$','\1\2\3'),	
	(CASE (RANDOM()*4)::INT
			WHEN 0 THEN 'JAVA-8'
			WHEN 1 THEN '.NET 4.5'
			WHEN 2 THEN 'Javascript'
			WHEN 3 THEN 'React'
			WHEN 4 THEN 'Vue.JS'
			end
			)::text,	
	NOW(),
	NOW()
);
END LOOP;
END;
$$
;
COMMIT;