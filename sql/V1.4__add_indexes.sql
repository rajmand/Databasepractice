-- CREATING INDEXES
-- Creating hash indexes
CREATE INDEX student_name_idx
ON student USING HASH (name);

CREATE INDEX student_surname_idx
ON student USING HASH (surname);

CREATE INDEX student_skill_idx
ON student USING HASH (primary_skill);

CREATE INDEX subject_name_idx
ON subject USING HASH (subject_name);

CREATE INDEX subject_tutor_idx
ON subject USING HASH (tutor);

-- Creating btree indexes
CREATE INDEX student_name_b_tree_idx
ON student(name);

CREATE INDEX student_birth_date_b_tree_idx
ON student(birth_date);

CREATE INDEX student_created_b_tree_idx
ON student(created);

CREATE INDEX student_updated_b_tree_idx
ON student(updated);

CREATE INDEX exam_result_mark_b_tree_idx
ON exam_result(mark);

-- Creating gist indexes
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS btree_gist;
CREATE INDEX student_surname_gist_idx ON student USING gist(surname);
CREATE INDEX student_phonenumber_gist_idx ON student USING gist(phone_number);

-- Creating gin indexes
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX student_surname_gin_idx ON student USING gin (surname gin_trgm_ops);
CREATE INDEX student_phonenumber_gin_idx ON student USING gin (phone_number gin_trgm_ops);