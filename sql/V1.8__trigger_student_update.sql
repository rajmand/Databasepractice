CREATE OR REPLACE FUNCTION update_student() RETURNS TRIGGER AS
$$
BEGIN
    UPDATE student set updated = current_timestamp
    where student_id  = NEW.student_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_student_trigger AFTER UPDATE ON student
    FOR ROW
    WHEN (pg_trigger_depth() = 0)
EXECUTE PROCEDURE update_student();