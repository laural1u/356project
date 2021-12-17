CREATE TABLE Courses (
        name            varchar(50),

        PRIMARY KEY (name)
)

--Madison

CREATE TABLE MadisonCourses(
                        uuid	        varchar(36),
			name            varchar(50),
                        number	        int,

                        PRIMARY KEY (uuid),
                        FOREIGN KEY (name) REFERENCES Courses(name)
);

CREATE TABLE Offerings(
                        uuid	        varchar(36),
			course_uuid	varchar(36),
			term_code	int,
			name            varchar(50),

                        PRIMARY KEY (uuid),
                        FOREIGN KEY (course_uuid) REFERENCES MadisonCourses(uuid)
);

CREATE TABLE Subjects(
			code	                int,
			name                    varchar(50),
                        abbreviation            varchar(50),

                        PRIMARY KEY (code)
);

CREATE TABLE Sections(
                        uuid	                varchar(36),
			course_offering_uuid	varchar(36),
			section_type            varchar(5),
			number                  int,
                        room_uuid               varchar(36),
                        schedule_uuid           varchar(36),

                        PRIMARY KEY (uuid),
                        FOREIGN KEY (course_offering_uuid) REFERENCES Offerings(uuid),
                        FOREIGN KEY (room_uuid) REFERENCES rooms(uuid),
                        FOREIGN KEY (schedule_uuid) REFERENCES Schedules(uuid)
);

CREATE TABLE Instructors(
                        id              varchar(10),
                        name            varchar(36),

                        PRIMARY KEY (id)
);


CREATE TABLE Schedules(
			uuid	        varchar(36),
                        start_time	int,
			end_time	int,
                        mon             tinyint(1),
                        tues            tinyint(1),
                        wed             tinyint(1),
                        thurs           tinyint(1),
                        fri             tinyint(1),
                        sat             tinyint(1),
                        sun             tinyint(1),

                        PRIMARY KEY (uuid)
);

CREATE TABLE Rooms(
			uuid	        varchar(36),
                        facility_code	varchar(10),
			room_code       varchar(10),

                        PRIMARY KEY (uuid),
);

CREATE TABLE Grades(
			course_offering_uuid	varchar(36),
                        section_number	        int,
			a_count	                int,
                        ab_count	        int,
                        b_count	                int,
                        bc_count	        int,
                        c_count	                int,
                        d_count	                int,
                        f_count	                int,
                        s_count	                int,

                        PRIMARY KEY (course_offering_uuid, section_number),
                        FOREIGN KEY (course_offering_uuid) REFERENCES Offerings(uuid)
);      -- treat this table as relation counts

CREATE TABLE Teachings (
        instructor_id,
        section_uuid,

        PRIMARY KEY (instructor_id, section_uuid),
        FOREIGN KEY (instructor_id) REFERENCES Instructors(id),
        FOREIGN KEY (section_uuid) REFERENCES Sections(uuid)
)       -- treat this table as relation teaches

CREATE TABLE SubjectMemberships (
        subject_code,
        course_offering_uuid,

        PRIMARY KEY (subject_code, course_offering_uuid),
        FOREIGN KEY (subject_code) REFERENCES Subjects(code),
        FOREIGN KEY (course_offering_uuid) REFERENCES Offerings(uuid)
)       -- treat this table as relation offers

CREATE TABLE has_details (
        course_uuid,
        course_offering_uuid,
        section_uuid,
        room_uuid,
        schedule_uuid,

        PRIMARY KEY (course_uuid, course_offering_uuid, section_uuid, room_uuid, schedule_uuid)
        FOREIGN KEY (course_uuid, course_offering_uuid) REFERENCES Offerings(course_id, uuid),
        FOREIGN KEY (section_uuid, room_uuid, schedule_uuid) REFERENCES Sections(uuid, room_uuid, schedule_uuid)
)       -- inner join Sections and Offerings on course_offering_uuid to get this table

--OpenCourse

CREATE TABLE OpenCourses(
			code_module	                varchar(3),
                        code_presentation	        varchar(5),
			module_presentation_length      varchar(10),

                        PRIMARY KEY (code_module, code_presentation),
                        FOREIGN KEY (code_module) REFERENCES Courses(name)
);

CREATE TABLE Assessments(
			code_module	                varchar(3),
                        code_presentation	        varchar(5),
                        id_assessment                   int,
                        assessment_type                 varchar(5),
                        date                            int,
                        weight                          int,

                        PRIMARY KEY (id_assessment),
                        FOREIGN KEY (code_module, code_presentation) REFERENCES OpenCourses(code_module, code_presentation)
);

CREATE TABLE StudentAssessment(
                        id_assessment                   int,
                        id_student                      int,
                        date_submitted                  int,
                        is_banked                       tinyint(1),
                        score                           int,

                        PRIMARY KEY (id_assessment, id_student),
                        FOREIGN KEY (id_assessment) REFERENCES Assessments(id_assessment),
                        FOREIGN KEY (id_student) REFERENCES StudentInfo(id_student)
);

CREATE TABLE has_grade(
                        code_module	                varchar(3),
                        code_presentation	        varchar(5),
                        id_assessment                   int,
                        id_student                      int,
                        date_submitted                  int,
                        is_banked                       tinyint(1),
                        score                           int,

                        PRIMARY KEY (code_module, code_presentation, id_assessment, id_student),
                        FOREIGN KEY (code_module, code_presentation) REFERENCES OpenCourses(code_module, code_presentation),
                        FOREIGN KEY (id_assessment, id_student) REFERENCES StudentAssessment(id_assessment, id_student)
);      -- inner join StudentAssessment and Assessments on id_assessment to get this table

CREATE TABLE StudentInfo(
                        code_module	                varchar(3),
                        code_presentation	        varchar(5),
                        id_student                      int,
                        gender                          char(1),
                        region                          varchar(20),
                        highest_education               varchar(30),
                        imd_band                        varchar(15),
                        age_band                        varchar(15),
                        num_of_prev_attempts            int,
                        studied_credits                 int,

                        PRIMARY KEY (id_student),
                        FOREIGN KEY (code_module, code_presentation) REFERENCES OpenCourses(code_module, code_presentation)
);

CREATE TABLE StudentRegistration(
                        code_module	                varchar(3),
                        code_presentation	        varchar(5),
                        id_student                      int,
                        date_registration               int,
                        date_unregistration             int,

                        PRIMARY KEY (id_student, code_module, code_presentation),
                        FOREIGN KEY (id_student) REFERENCES StudentInfo(id_student),
                        FOREIGN KEY (code_module, code_presentation) REFERENCES OpenCourses(code_module, code_presentation)
);      -- treat this table as relation registers


CREATE TABLE Vle(
                        code_module	                varchar(3),
                        code_presentation	        varchar(5),
                        id_site                         int,
                        activity_type                   varchar(10),
                        week_from                       int,
                        week_to                         int,

                        PRIMARY KEY (id_site, code_module, code_presentation),
                        FOREIGN KEY (code_module, code_presentation) REFERENCES OpenCourses(code_module, code_presentation)
);      -- treat this table as relation has_vle as well

CREATE TABLE StudentVle(
                        code_module	                varchar(3),
                        code_presentation	        varchar(5),
                        id_student                      int,
                        id_site                         int,
                        date                            int,
                        sum_click                       int,

                        PRIMARY KEY (id_student, id_site, code_module, code_presentation),
                        FOREIGN KEY (id_student) REFERENCES StudentInfo(id_student),
                        FOREIGN KEY (id_site, code_module, code_presentation) REFERENCES Vle(id_site, code_module, code_presentation)
);      -- treat this table as relation clicks

-- Coursera

CREATE TABLE CourseraCourses (
        name                    varchar(50),
        institution             varchar(20),
        course_url              varchar(50),
        course_id               varchar(20),

        PRIMARY KEY (course_id),
        FOREIGN KEY (name) REFERENCES Courses(name)
)

CREATE TABLE Reviews (
        reviews,
        reviewers,
        date_reviews,
        rating,
        course_id,

        PRIMARY KEY (reviewers, date_reviews, course_id),
        FOREIGN KEY (course_id) REFERENCES CourseraCourses(course_id)
)       -- treat this table as relation has_review