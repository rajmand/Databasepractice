DROP TABLE IF EXISTS student_address CASCADE;

CREATE TABLE public.student_address
(
    address_id INT PRIMARY KEY NOT NULL,
    student_id INT NOT NULL,
    address text COLLATE pg_catalog."default",
	CONSTRAINT fk_address
      FOREIGN KEY(student_id) 
	  REFERENCES student(student_id)
);

ALTER TABLE public.student_address OWNER TO postgres;

CREATE SEQUENCE student_address_id_seq AS INT
OWNED BY public.student_address.address_id;
