CREATE TABLE MadisonCourses(
                        uuid            char(36),
                        name            varchar(50),
                        number          int,

                        PRIMARY KEY (uuid)
);
load data infile '/var/lib/mysql-files/26-Education/UWM/courses.csv' ignore into table MadisonCourses
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines;

CREATE TABLE Subjects(
                        code                    char(3),
                        name                    varchar(50),
                        abbreviation            varchar(50),

                        PRIMARY KEY (code)
);
load data infile '/var/lib/mysql-files/26-Education/UWM/subjects.csv' ignore into table Subjects
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines;

CREATE TABLE Rooms(
                        uuid            char(36),
                        facility_code   varchar(10),
                        room_code       varchar(10),

                        PRIMARY KEY (uuid)
);
load data infile '/var/lib/mysql-files/26-Education/UWM/rooms.csv' ignore into table Rooms
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines;

CREATE TABLE Schedules(
                        uuid            char(36),
                        start_time      int,
                        end_time        int,
                        mon             tinyint,
                        tues            tinyint,
                        wed             tinyint,
                        thurs           tinyint,
                        fri             tinyint,
                        sat             tinyint,
                        sun             tinyint,

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
                        name            varchar(36),

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
                        a_count                 int,
                        ab_count                int,
                        b_count                 int,
                        bc_count                int,
                        c_count                 int,
                        d_count                 int,
                        f_count                 int,
                        s_count                 int,

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
                        course_uuid     char(36),
                        term_code       int,
                        name            varchar(50),

                        PRIMARY KEY (uuid)
);
load data infile '/var/lib/mysql-files/26-Education/UWM/course_offerings.csv' ignore into table Offerings
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines;

CREATE TABLE Sections(
                        uuid                    char(36),
                        course_offering_uuid    char(36),
                        section_type            char(3),
                        number                  int,
                        room_uuid               char(36),
                        schedule_uuid           char(36),

                        PRIMARY KEY (uuid)
);   -- treat as relation has_details
load data infile '/var/lib/mysql-files/26-Education/UWM/sections.csv' ignore into table Sections
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines;

-- create view teaches as (
--      select distinct Instructors.name as instructor_name, Offerings.name as offer_name, Sections.number as section from
--           Instructors inner join Teachings on (Instructors.id = Teachings.instructor_id)
--                       inner join Sections on (Teachings.section_uuid = Sections.uuid)
--                       inner join Offerings on (Sections.course_offering_uuid = Offerings.uuid)
-- );

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
                        module_presentation_length      int,

                        PRIMARY KEY (code_module, code_presentation)
);
load data infile '/var/lib/mysql-files/26-Education/OU/courses.csv' ignore into table OpenCourses
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines;

CREATE TABLE Assessments(
                        code_module                     char(3),
                        code_presentation               char(5),
                        id_assessment                   int,
                        assessment_type                 char(4),
                        date                            int,
                        weight                          int,

                        PRIMARY KEY (id_assessment)
);
load data infile '/var/lib/mysql-files/26-Education/OU/assessments.csv' ignore into table Assessments
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines;

CREATE TABLE StudentAssessment(
                        id_assessment                   int,
                        id_student                      int,
                        date_submitted                  int,
                        is_banked                       tinyint,
                        score                           int,

                        PRIMARY KEY (id_assessment, id_student)
);
load data infile '/var/lib/mysql-files/26-Education/OU/studentAssessment.csv' ignore into table StudentAssessment
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines
     (id_assessment, id_student, date_submitted, @is_banked, score)
     set is_banked = if(@is_banked='True', 1, 0);

CREATE TABLE StudentInfo(
                        code_module                     char(3),
                        code_presentation               char(5),
                        id_student                      int,
                        gender                          char(1),
                        region                          varchar(20),
                        highest_education               varchar(30),
                        imd_band                        varchar(15),
                        age_band                        varchar(15),
                        num_of_prev_attempts            int,
                        studied_credits                 int,

                        PRIMARY KEY (id_student)
);
load data infile '/var/lib/mysql-files/26-Education/OU/studentInfo.csv' ignore into table StudentInfo
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
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
     lines terminated by '\n'
     ignore 1 lines
     (code_module, code_presentation, id_student, date_registration, @date_unregistration)
     set date_unregistration = ifnull(null, @date_unregistration);

CREATE TABLE Vle(
                        id_site                         int,
                        code_module                     char(3),
                        code_presentation               char(5),
                        activity_type                   varchar(10),
                        week_from                       int,
                        week_to                         int,

                        PRIMARY KEY (id_site, code_module, code_presentation)
);
load data infile '/var/lib/mysql-files/26-Education/OU/vle.csv' ignore into table Vle
     fields terminated by ','
     enclosed by '"'
     lines terminated by '\n'
     ignore 1 lines
     (id_site, code_module, code_presentation, activity_type, @week_from, @week_to)
     set
        week_from = ifnull(null, @week_from),
        week_to = ifnull(null, @week_to);
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