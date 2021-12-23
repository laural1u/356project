import mysql.connector
from tabulate import tabulate


# cnx = mysql.connector.connect(
#     user="root", password="ece356-", host="127.0.0.1", database="c455li"
# )

cnx = mysql.connector.connect(
    user="c455li",
    password="ECE356-c455li",
    host="marmoset04.shoshin.uwaterloo.ca",
    database="db356_c455li",
)

if cnx.is_connected():
    print("database Connected")
else:
    print("error!")

cursor = cnx.cursor()


class Node:
    def __init__(self, title):
        self.title = title

    def enter(self):
        pass


class OptionNode(Node):
    def __init__(self, title, prompt="please select an option"):
        self.prompt = prompt
        self.children = []
        super().__init__(title)

    def enter(self):
        while True:
            print()
            print("<<<" + self.title + ">>>")
            print(self.prompt)
            if len(self.children) != 0:
                for i, c in enumerate(self.children):
                    print(str(i) + " : " + c.title)
                print(str(len(self.children)) + " : " + "exit")

                try:
                    cmd = int(input())
                    if 0 <= cmd < len(self.children):
                        self.children[cmd].enter()
                    elif cmd == len(self.children):
                        break
                    else:
                        print("error input, please try again")
                except ValueError:
                    print("error input, please try again")
            else:
                print("under construction")
                return

    def add_child(self, child):
        self.children.append(child)

    def create_option_child(self, title, prompt="please select an option"):
        child = OptionNode(title, prompt)
        self.children.append(child)
        return child


class FunctionNode(Node):
    def __init__(self, title, query, value_names, result_names=None):
        self.query = query
        self.value_names = value_names
        if result_names != None:
            self.result_names = tuple([rn.replace("_", " ") for rn in result_names])
        else:
            self.result_names = None
        super().__init__(title)

    def enter(self):
        values = {}
        for value_name in self.value_names:
            print("what is " + value_name.replace("_", " ") + "?")
            values[value_name.replace(" ", "_")] = input()
            # values[value_name.replace(" ", "_")] = "1"
        print(self.query % values)
        print(values)
        exe_query = self.query % values
        cursor.execute(exe_query)

        if self.result_names == None:
            # cnx.commit()
            print("affected rows = {}".format(cursor.rowcount))
            print("Success!")
        else:
            print("here is the result")
            res = []
            try:
                for c in cursor:
                    res.append([str(v) for v in c])
            except mysql.connector.errors.InterfaceError:
                print("no result")
            if len(res) > 1:
                print(tabulate(res, headers=self.result_names, tablefmt="orgtbl"))
            elif len(res) == 1:
                res = [self.result_names, res[0]]
                res = [*zip(*res)]
                print(tabulate(res, headers=["field", "value"], tablefmt="orgtbl"))
            else:
                print("no result")


if __name__ == "__main__":
    select_course = OptionNode("main menu", "please select a course to modify")

    ### open course
    open_course = select_course.create_option_child("open course")

    # i
    oc_course = open_course.create_option_child("course")

    oc_course.add_child(
        FunctionNode(
            "Upload a course",
            (
                "insert into OpenCourses VALUES "
                ' ("%(module_code)s", "%(presentation_code)s",  %(length)s);'
            ),
            ("module code", "presentation code", "length"),
        )
    )

    oc_course.add_child(
        FunctionNode(
            "Modify the length of a course",
            (
                "update OpenCourses set module_presentation_length = %(length)s"
                ' where code_module = "%(module_code)s" '
                ' and code_presentation = "%(presentation_code)s";'
            ),
            ("module code", "presentation code", "length"),
        )
    )

    # ii
    oc_assessment = open_course.create_option_child("assessment")

    oc_assessment.add_child(
        FunctionNode(
            "Upload an assessment",
            (
                "insert into assessments VALUES "
                ' ("%(module_code)s", %(presentation_code)s,"%(assessment_id)s",'
                ' "%(assessment_type)s",  %(date)s, %(weight)s);'
            ),
            (
                "module_code",
                "presentation_code",
                "assessment_id",
                "assessment_type",
                "date",
                "weight",
            ),
        )
    )

    oc_assessment.add_child(
        FunctionNode(
            "Modify an assessment",
            (
                'update assessments set assessment_type = "%(assessment_type)s",'
                " date =  %(date)s,"
                " weight= %(weight)s"
                " where id_assessment = %(assessment_id)s;"
            ),
            (
                "assessment id",
                "assessment type",
                "date",
                "weight",
            ),
        )
    )

    oc_assessment.add_child(
        FunctionNode(
            "Delete an assessment",
            "DELETE FROM assessments where id_assessment = %(assessment_id)s;",
            ("assessment id",),
        )
    )

    oc_assessment.add_child(
        FunctionNode(
            "search for assessment",
            (
                "select id_assessment, assessment_type, date, weight from assessments"
                ' where code_module = "%(module_code)s" '
                ' and code_presentation = "%(presentation_code)s";'
            ),
            ("module code", "presentation code"),
            ("assessment id", "assessment type", "date", "weight"),
        )
    )

    # iii
    oc_VLE = open_course.create_option_child("VLE")

    oc_VLE.add_child(
        FunctionNode(
            "Upload a material",
            (
                "insert into VLE VALUES "
                ' (%(site_id)s, "%(module_code)s","%(presentation_code)s",'
                ' "%(activity_type)s",  %(week_from)s, %(week_to)s);'
            ),
            (
                "site_id",
                "module_code",
                "presentation_code",
                "activity_type",
                "week_from",
                "week_to",
            ),
        )
    )

    oc_VLE.add_child(
        FunctionNode(
            "modify a material",
            (
                'update VLE set activity_type = "%(new_activity_type)s",'
                "week_from= %(new_week_from)s,"
                "week_to=%(new_week_to)s"
                ' where id_site = "%(site_id)s" '
                ' and code_module = "%(module_code)s"'
                ' and code_presentation = "%(presentation_code)s";'
            ),
            (
                "site_id",
                "module_code",
                "presentation_code",
                "new_activity_type",
                "new_week_from",
                "new_week_to",
            ),
        )
    )

    oc_VLE.add_child(
        FunctionNode(
            "delete a material",
            (
                "DELETE FROM VLE"
                ' where id_site = "%(site_id)s" '
                ' and code_module = "%(module_code)s"'
                ' and code_presentation = "%(presentation_code)s";'
            ),
            (
                "site_id",
                "module_code",
                "presentation_code",
            ),
        )
    )

    # iv
    oc_student_info = open_course.create_option_child("student info")

    oc_student_info.add_child(
        FunctionNode(
            "add a student",
            (
                "insert into studentinfo VALUES "
                ' ( "%(module_code)s","%(presentation_code)s",'
                '%(student_id)s, "%(gender)s", "%(region)s", "%(highest_education)s",'
                '"%(Index_of_Multiple_Depravation)s", "%(age_band)s",'
                "%(number_of_previous_attempts)s,%(studied_credits)s);"
            ),
            (
                "module_code",
                "presentation_code",
                "student_id",
                "gender",
                "region",
                "highest_education",
                "Index_of_Multiple_Depravation",
                "age_band",
                "number_of_previous_attempts",
                "studied_credits",
            ),
        )
    )

    oc_student_info.add_child(
        FunctionNode(
            "get a student info by student id",
            (
                "select code_module, code_presentation, gender, region, "
                " highest_education, imd_band, age_band, "
                " num_of_prev_attempts, studied_credits from studentinfo"
                " where id_student = %(student_id)s;"
            ),
            ("student_id",),
            (
                "code_module",
                "code_presentation",
                "gender",
                "region",
                "highest_education",
                "Index of Multiple Depravation",
                "age_band",
                "number_of_prev_attempts",
                "studied_credits",
            ),
        )
    )

    oc_student_info.add_child(
        FunctionNode(
            "get all students that taking a course",
            (
                "select id_student, gender, region, "
                " highest_education, imd_band, age_band, "
                " num_of_prev_attempts, studied_credits from studentinfo"
                ' where code_module = "%(module_code)s"'
                ' and code_presentation = "%(presentation_code)s";'
            ),
            ("module_code", "presentation_code"),
            (
                "student_id",
                "gender",
                "region",
                "highest_education",
                "Index of Multiple Depravation",
                "age_band",
                "number_of_prev_attempts",
                "studied_credits",
            ),
        )
    )

    # v
    oc_student_registration = open_course.create_option_child("student registration")

    oc_student_registration.add_child(
        FunctionNode(
            "register a student",
            (
                "insert into studentregistration VALUES "
                ' ( "%(module_code)s","%(presentation_code)s",'
                "%(student_id)s, %(registration_date)s, 99999);"
            ),
            ("module_code", "presentation_code", "student_id", "registration_date"),
        )
    )

    oc_student_registration.add_child(
        FunctionNode(
            "unregister a student",
            (
                "update studentregistration set date_unregistration=%(unregistration_date)s"
                ' where code_module="%(module_code)s"'
                ' and code_presentation="%(presentation_code)s"'
                "and id_student = %(student_id)s;"
            ),
            ("module_code", "presentation_code", "student_id", "unregistration_date"),
        )
    )

    oc_student_registration.add_child(
        FunctionNode(
            "query a student's registration info",
            (
                "select date_registration, date_unregistration from studentregistration"
                ' where code_module="%(module_code)s"'
                ' and code_presentation="%(presentation_code)s"'
                "and id_student = %(student_id)s;"
            ),
            ("module_code", "presentation_code", "student_id"),
            ("date_registration", "date_unregistration"),
        )
    )

    # vi
    oc_student_assessment = open_course.create_option_child("student assessment")
    oc_student_assessment.add_child(
        FunctionNode(
            "upload an assessment grade",
            (
                "insert into studentassessment VALUES "
                ' ( "%(assessment_id)s","%(student_id)s",'
                "%(submitted_date)s, %(is_banked_0_or_1)s, %(score)s);"
            ),
            (
                "assessment_id",
                "student_id",
                "submitted_date",
                "is_banked_0_or_1",
                "score",
            ),
        )
    )

    oc_student_assessment.add_child(
        FunctionNode(
            "get a student's all the assignment grades",
            (
                "select id_assessment, date_submitted, is_banked, score from studentassessment"
                " where id_student = %(student_id)s;"
            ),
            ("student_id",),
            ("assessment_id", "submitted_date", "is_banked_0_or_1", "score"),
        )
    )

    oc_student_assessment.add_child(
        FunctionNode(
            "get a student's current achieved grade",
            """
               WITH assessmentgrade AS (
                    SELECT
                        id_assessment,
                        score
                    FROM
                        studentassessment
                    where
                        id_student = %(student_id)s
                )
                SELECT
                    code_module,
                    code_presentation,
                    sum((weight / 100 * score))/sum(weight) as 'current_grade'
                FROM
                    assessmentgrade
                    left JOIN assessments on assessmentgrade.id_assessment = assessments.id_assessment
                where
                    weight is not null
                    and score is not null
                GROUP BY
                    code_module, code_presentation;""",
            ("student_id",),
            ("module code", "presentation code", "current_grade"),
        )
    )

    oc_student_assessment.add_child(
        FunctionNode(
            "get all the grades of an assignment",
            (
                "select id_student, date_submitted, is_banked, score from studentassessment"
                " where id_assessment  = %(assessment_id)s;"
            ),
            ("assessment_id",),
            ("student_id", "submitted_date", "is_banked_0_or_1", "score"),
        )
    )

    oc_student_assessment.add_child(
        FunctionNode(
            "get a summary of an assignment",
            (
                "select count(score), avg(score), min(score), max(score) from studentassessment"
                " where id_assessment  = %(assessment_id)s;"
            ),
            ("assessment_id",),
            ("#_of_submission", "average", "min", "max"),
        )
    )

    # vii
    oc_student_VLE = open_course.create_option_child("student VLE")

    oc_student_VLE.add_child(
        FunctionNode(
            "add an activity (this should be done by website instead of user)",
            (
                "insert into studentvle VALUES "
                ' ( "%(module_code)s","%(presentation_code)s",'
                "%(student_id)s, %(site_id)s, %(date)s, %(sum_click)s);"
            ),
            (
                "module_code",
                "presentation_code",
                "student_id",
                "site_id",
                "date",
                "sum_click",
            ),
        )
    )

    ### madison course
    madixon_course = select_course.create_option_child("madixon course")
    
    mc_course = madixon_course.create_option_child("Course")

    mc_grade = madixon_course.create_option_child("Grade")
    mc_instructors = madixon_course.create_option_child("Instructors")
    mc_schedule = madixon_course.create_option_child("Schedule")
    mc_room = madixon_course.create_option_child("Room")
    mc_st = madixon_course.create_option_child("Section & teaching")
    mc_subject = madixon_course.create_option_child("Subject")

    select_course.enter()
    cnx.close()

    print("Bye")
