DROP TABLE IF EXISTS exam_result CASCADE;

CREATE TABLE public.exam_result (
    exam_result_id INT PRIMARY KEY generated always as identity,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    mark INT NOT NULL,
    
    CONSTRAINT fk_student
	FOREIGN KEY(student_id) 
	REFERENCES student(student_id),
	 
	CONSTRAINT fk_subject
	FOREIGN KEY(subject_id) 
	REFERENCES subject(subject_id)
);


ALTER TABLE public.exam_result OWNER TO postgres;

CREATE SEQUENCE exam_result_id_seq AS INT
OWNED BY public.exam_result.exam_result_id;