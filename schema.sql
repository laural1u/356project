CREATE TABLE MadisonCourses(
                        uuid            char(36),
                        name            varchar(100) not null,
                        number          int not null,

                        PRIMARY KEY (uuid),
                        CONSTRAINT chk_num CHECK (number > 0)
);
load data infile '/var/lib/mysql-files/26-Education/UWM/courses.csv' ignore into table MadisonCourses
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines;
CREATE INDEX idx_name ON MadisonCourses(name);

CREATE TABLE Subjects(
                        code                    char(3),
                        name                    varchar(50) not null,
                        abbreviation            varchar(50) not null,

                        PRIMARY KEY (code)
);
load data infile '/var/lib/mysql-files/26-Education/UWM/subjects.csv' ignore into table Subjects
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines;
CREATE INDEX idx_abbr ON MadisonCourses(abbreviation);

CREATE TABLE Rooms(
                        uuid            char(36),
                        facility_code   varchar(10) not null,
                        room_code       varchar(10) not null,

                        PRIMARY KEY (uuid)
);
load data infile '/var/lib/mysql-files/26-Education/UWM/rooms.csv' ignore into table Rooms
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines;
CREATE INDEX idx_abbr ON MadisonCourses(abbreviation);

CREATE TABLE Schedules(
                        uuid            char(36),
                        start_time      int not null,
                        end_time        int not null,
                        mon             tinyint not null,
                        tues            tinyint not null,
                        wed             tinyint not null,
                        thurs           tinyint not null,
                        fri             tinyint not null,
                        sat             tinyint not null,
                        sun             tinyint not null,

                        PRIMARY KEY (uuid)
);
load data infile '/var/lib/mysql-files/26-Education/UWM/schedules.csv' ignore into table Schedules
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines
     (uuid, start_time, end_time, @mon, @tues, @wed, @thurs, @fri, @sat, @sun)
     set 
        mon = if(@mon = 'True', 1, 0),
        tues = if(@tues = 'True', 1, 0),
        wed = if(@wed = 'True', 1, 0),
        thurs = if(@thurs = 'True', 1, 0),
        fri = if(@fri = 'True', 1, 0),
        sat = if(@sat = 'True', 1, 0),
        sun = if(@sun = 'True', 1, 0);

CREATE TABLE Instructors(
                        id              int,
                        name            varchar(50) not null,

                        PRIMARY KEY (id)
);
load data infile '/var/lib/mysql-files/26-Education/UWM/instructors.csv' ignore into table Instructors
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines;

CREATE TABLE Grades(
                        course_offering_uuid    char(36),
                        section_number          int,
                        a_count                 int not null,
                        ab_count                int not null,
                        b_count                 int not null,
                        bc_count                int not null,
                        c_count                 int not null,
                        d_count                 int not null,
                        f_count                 int not null,
                        s_count                 int not null,

                        PRIMARY KEY (course_offering_uuid, section_number)
);   --treat as relation couts
load data infile '/var/lib/mysql-files/26-Education/UWM/grade_distributions.csv' ignore into table Grades
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines;

CREATE TABLE Teachings (
        instructor_id           int,
        section_uuid            char(36),

        PRIMARY KEY (instructor_id, section_uuid)
);   -- treat as relation teaches
load data infile '/var/lib/mysql-files/26-Education/UWM/teachings.csv' ignore into table Teachings
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines;

CREATE TABLE SubjectMemberships (
        subject_code            char(3),
        course_offering_uuid    char(36),

        PRIMARY KEY (subject_code, course_offering_uuid)
);
load data infile '/var/lib/mysql-files/26-Education/UWM/subject_memberships.csv' ignore into table SubjectMemberships
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines;

CREATE TABLE Offerings(
                        uuid            char(36),
                        course_uuid     char(36) not null,
                        term_code       int not null,
                        name            varchar(50) not null,

                        PRIMARY KEY (uuid)
);
load data infile '/var/lib/mysql-files/26-Education/UWM/course_offerings.csv' ignore into table Offerings
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines;

CREATE TABLE Sections(
                        uuid                    char(36),
                        course_offering_uuid    char(36) not null,
                        section_type            char(3) not null,
                        number                  int not null,
                        room_uuid               char(36) not null,
                        schedule_uuid           char(36) not null,

                        PRIMARY KEY (uuid)
);   -- treat as relation has_details
load data infile '/var/lib/mysql-files/26-Education/UWM/sections.csv' ignore into table Sections
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines;

create view offers as (
     select MadisonCourses.name as course_name, term_code, Subjects.name as subject_name, Offerings.name as offer_name from 
          Subjects inner join SubjectMemberships on (Subjects.code = SubjectMemberships.subject_code)
                   inner join Offerings on (SubjectMemberships.course_offering_uuid = Offerings.uuid)
                   inner join MadisonCourses on (Offerings.course_uuid = MadisonCourses.uuid)
);
---------------------------------------------------------------------------------------------
CREATE TABLE OpenCourses(
                        code_module                     char(3),
                        code_presentation               char(5),
                        module_presentation_length      int not null,

                        PRIMARY KEY (code_module, code_presentation),
                        CONSTRAINT chk_len CHECK (module_presentation_length >= 0)
);
load data infile '/var/lib/mysql-files/26-Education/OU/courses.csv' ignore into table OpenCourses
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\r\n'
     ignore 1 lines;

CREATE TABLE Assessments(
                        code_module                     char(3) not null,
                        code_presentation               char(5) not null,
                        id_assessment                   int,
                        assessment_type                 char(4) not null,
                        date                            int,
                        weight                          int not null,

                        PRIMARY KEY (id_assessment),
                        CONSTRAINT chk_weight_1 CHECK (weight <= 100),
                        CONSTRAINT chk_weight_2 CHECK (weight >= 0)
);
load data infile '/var/lib/mysql-files/26-Education/OU/assessments.csv' ignore into table Assessments
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\r\n'
     ignore 1 lines
     (code_module, code_presentation, id_assessment, assessment_type, @date, weight)
     set date = ifnull(-1, @date);

CREATE TABLE StudentAssessment(
                        id_assessment                   int,
                        id_student                      int,
                        date_submitted                  int not null,
                        is_banked                       tinyint not null,
                        score                           int not null,

                        PRIMARY KEY (id_assessment, id_student)
);
load data infile '/var/lib/mysql-files/26-Education/OU/studentAssessment.csv' ignore into table StudentAssessment
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\r\n'
     ignore 1 lines
     (id_assessment, id_student, date_submitted, @is_banked, @score)
     set 
          is_banked = if(@is_banked='True', 1, 0),
          score = ifnull(0, @score);

-- lost some data
CREATE TABLE StudentInfo(
                        code_module                     char(3) not null,
                        code_presentation               char(5) not null,
                        id_student                      int,
                        gender                          char(1) not null,
                        region                          varchar(20) not null,
                        highest_education               varchar(30) not null,
                        imd_band                        varchar(15),
                        age_band                        varchar(15) not null,
                        num_of_prev_attempts            int not null,
                        studied_credits                 int not null,

                        PRIMARY KEY (id_student)
);
load data infile '/var/lib/mysql-files/26-Education/OU/studentInfo.csv' ignore into table StudentInfo
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\r\n'
     ignore 1 lines;

CREATE TABLE StudentRegistration(
                        code_module                     char(3),
                        code_presentation               char(5),
                        id_student                      int,
                        date_registration               int,
                        date_unregistration             int,

                        PRIMARY KEY (id_student, code_module, code_presentation)
);   -- treate as replation registers
load data infile '/var/lib/mysql-files/26-Education/OU/studentRegistration.csv' ignore into table StudentRegistration
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\r\n'
     ignore 1 lines
     (code_module, code_presentation, id_student, date_registration, @date_unregistration)
     set 
          date_registration = ifnull(99999, @date_registration),
          date_unregistration = ifnull(99999, @date_unregistration);

CREATE TABLE Vle(
                        id_site                         int,
                        code_module                     char(3),
                        code_presentation               char(5),
                        activity_type                   varchar(20) not null,
                        week_from                       int,
                        week_to                         int,

                        PRIMARY KEY (id_site, code_module, code_presentation)
);
load data infile '/var/lib/mysql-files/26-Education/OU/vle.csv' ignore into table Vle
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\r\n'
     ignore 1 lines
     (id_site, code_module, code_presentation, activity_type, @week_from, @week_to)
     set
        week_from = ifnull(-1, @week_from),
        week_to = ifnull(-1, @week_to);
alter table Vle add foreign key (code_module, code_presentation) references OpenCourses(code_module, code_presentation);     -- has invalid key

CREATE TABLE StudentVle(
                        code_module                     char(3),
                        code_presentation            char(5),
                        id_student                      int,
                        id_site                         int,
                        date                            int,
                        sum_click                       int,

                        PRIMARY KEY (id_student, id_site, code_module, code_presentation, date, sum_click)
);   -- treat as relation clicks
load data infile '/var/lib/mysql-files/26-Education/OU/studentVle.csv' ignore into table StudentVle
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines;

create view has_grade as (
     select code_module, code_presentation, id_assessment, id_student, date_submitted, is_banked, score from 
     (Assessments inner join StudentAssessment using (id_assessment))
);
---------------------------------------------------------------------------------------------
create view Courses as (
     select name from (
          (select name from CourseraCourses)
          UNION
          (select name from MadisonCourses)
     ) as T
);