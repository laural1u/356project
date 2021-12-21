import mysql.connector

# cnx = mysql.connector.connect(
#     user="root", password="***", host="127.0.0.1", database="c455li"
# )

cnx = mysql.connector.connect(
    user="c455li",
    password="***",
    host="marmoset04.shoshin.uwaterloo.ca",
    database="db356_c455li",
)

if cnx.is_connected():
    print("database Connected")
else:
    print("database Not connected")

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
                print("it should have children")
                return

    def add_child(self, child):
        self.children.append(child)


class FunctionNode(Node):
    def __init__(self, title, query, value_names):
        self.query = query
        self.value_names = value_names
        super().__init__(title)

    def enter(self):
        values = {}
        for value_name in self.value_names:
            print("what is " + value_name + "?")
            values[value_name.replace(" ", "_")] = input()
        print(self.query % values)
        print(values)
        exe_query = self.query % values
        cursor.execute(exe_query)
        cnx.commit()

        print("Success!")
        cnx.commit()


select_course = OptionNode("main menu", "please select a course to modify")

open_course = OptionNode("open course")
select_course.add_child(open_course)
madixon_course = OptionNode("madixon course")
select_course.add_child(madixon_course)

open_course_course = OptionNode("course")
open_course.add_child(open_course_course)

oc_upload = FunctionNode(
    "Upload a course",
    (
        " update OpenCourses set module_presentation_length = %(length)s"
        ' where code_module = "%(module_code)s" '
        'and code_presentation = "%(presentation_code)s";'
    ),
    ("module code", "presentation code", "length"),
)
open_course.add_child(oc_upload)

open_course_course.add_child(oc_upload)
open_course_assessment = OptionNode("assessment")
open_course_VLE = OptionNode("VLE")
open_course_student_info = OptionNode("student info")
open_course_student_registration = OptionNode("student registration")
open_course_student_assessment = OptionNode("student assessment")
open_course_student_VLE = OptionNode("student VLE")

open_course.add_child(open_course_course)
open_course.add_child(open_course_assessment)
open_course.add_child(open_course_VLE)
open_course.add_child(open_course_student_info)
open_course.add_child(open_course_student_registration)
open_course.add_child(open_course_student_assessment)
open_course.add_child(open_course_student_VLE)


select_course.enter()
cnx.close()

print("Bye")
