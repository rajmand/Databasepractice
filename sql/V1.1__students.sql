DROP TABLE IF EXISTS student CASCADE;

CREATE TABLE public.student (
    STUDENT_ID INTEGER PRIMARY KEY generated always as identity,
    name text,
    surname text,
    birth_date date,
    phone_number text,
    primary_skill text,
    created date,
    updated date
);


ALTER TABLE public.student OWNER TO postgres;

CREATE SEQUENCE student_id_seq AS INT
OWNED BY student.STUDENT_ID;
