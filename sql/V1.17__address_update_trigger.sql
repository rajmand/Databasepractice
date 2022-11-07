CREATE OR REPLACE FUNCTION reject_address_update()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO student_address_modified (address_id, address, student_id)
    VALUES (NEW.address, NEW.student_id);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reject_update_trigger
    BEFORE UPDATE
    ON student_address
    FOR EACH ROW
    EXECUTE PROCEDURE reject_address_update();


