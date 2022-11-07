package model;

public class Subject {
    private int id;
    private String subjectName;
    private String tutor;

    public Subject() {
    }

    public Subject(int id, String subjectName, String tutor) {
        this.id = id;
        this.subjectName = subjectName;
        this.tutor = tutor;
    }


    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getSubjectName() {
        return subjectName;
    }

    public void setSubjectName(String subjectName) {
        this.subjectName = subjectName;
    }

    public String getTutor() {
        return tutor;
    }

    public void setTutor(String tutor) {
        this.tutor = tutor;
    }
}
