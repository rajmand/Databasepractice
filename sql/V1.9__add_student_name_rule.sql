ALTER TABLE public.student
    ADD CONSTRAINT name_check CHECK (name !~ '[@#$]')
        NOT VALID;