--Madison

CREATE TABLE MadisonCourses(
                        uuid	        varchar(36),
			name            varchar(50),
                        number	        int,
                        PRIMARY KEY (uuid)
);

CREATE TABLE offerings(
                        uuid	        varchar(36),
			course_uuid	varchar(36),
			term_code	int,
			name            varchar(50),
                        PRIMARY KEY (uuid, course_uuid),
                        FOREIGN KEY (uuid) REFERENCES MadisonCourses(uuid)
);

CREATE TABLE subjects(
			code	                int,
                        course_offering_uuid	varchar(36),
			name                    varchar(50),
                        abbreviation            varchar(50),
                        PRIMARY KEY (code),
                        FOREIGN KEY (course_offering_uuid) REFERENCES offerings(course_uuid)
);

CREATE TABLE sections(
                        uuid	                varchar(36),
			course_offering_uuid	varchar(36),
			section_type            varchar(5),
			number                  int,
                        room_uuid               varchar(36),
                        schedule_uuid           varchar(36),
                        PRIMARY KEY (uuid, course_offering_uuid, schedule_uuid),
                        FOREIGN KEY (uuid, course_offering_uuid) REFERENCES offerings(uuid, course_uuid)
);

CREATE TABLE instructors(
                        instructor_id	varchar(10),
			section_uuid	varchar(36),
                        name            varchar(36),
                        PRIMARY KEY (instructor_id, section_uuid),
                        FOREIGN KEY (section_uuid) REFERENCES sections(schedule_uuid)
);


CREATE TABLE schedules(
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
                        PRIMARY KEY (uuid),
                        FOREIGN KEY (uuid) REFERENCES MadisonCourses(uuid)
);

CREATE TABLE rooms(
			uuid	        varchar(36),
                        facility_code	varchar(10),
			room_code       varchar(10),
                        PRIMARY KEY (uuid),
                        FOREIGN KEY (uuid) REFERENCES MadisonCourses(uuid)
);

CREATE TABLE grades(
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
                        PRIMARY KEY (course_offering_uuid),
                        FOREIGN KEY (course_offering_uuid) REFERENCES offerings(course_uuid)
);

--OpenCourse

CREATE TABLE OpenCourses(
			code_module	                varchar(3),
                        code_presentation	        varchar(5),
			module_presentation_length      varchar(10),
                        PRIMARY KEY (code_module, code_presentation)
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

/*
CREATE TABLE studentAssessment(
                        id_assessment                   int,
                        id_student                      int,
                        date_submitted                  int,
                        is_banked                       int,
                        score                           int,
                        PRIMARY KEY (id_assessment),
                        FOREIGN KEY (code_module, code_presentation) REFERENCES OpenCourses(code_module, code_presentation)
);

*/
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
                        PRIMARY KEY (id_student),
                        FOREIGN KEY (id_student) REFERENCES StudentInfo(id_student)
);


CREATE TABLE Vle(
                        code_module	                varchar(3),
                        code_presentation	        varchar(5),
                        id_site                         int,
                        activity_type                   varchar(10),
                        week_from                       int,
                        week_to                         int,
                        PRIMARY KEY (id_site),
                        FOREIGN KEY (code_module, code_presentation) REFERENCES OpenCourses(code_module, code_presentation)
);

CREATE TABLE StudentVle(
                        code_module	                varchar(3),
                        code_presentation	        varchar(5),
                        id_student                      int,
                        id_site                         int,
                        date                            int,
                        sum_click                       int,
                        PRIMARY KEY (id_student, id_site),
                        FOREIGN KEY (id_student) REFERENCES StudentInfo(id_student),
                        FOREIGN KEY (id_site) REFERENCES Vle(id_site)
);