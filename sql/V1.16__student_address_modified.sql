DROP TABLE IF EXISTS student_address_modified CASCADE;

CREATE TABLE public.student_address_modified
(
    address_id INT PRIMARY KEY generated always as identity,
    student_id INT NOT NULL,
    address text COLLATE pg_catalog."default",
	CONSTRAINT fk_address
      FOREIGN KEY(student_id) 
	  REFERENCES student(student_id)
);

ALTER TABLE public.student_address_modified OWNER TO postgres;

CREATE SEQUENCE student_address_modified_id_seq AS INT
OWNED BY public.student_address_modified.address_id;
