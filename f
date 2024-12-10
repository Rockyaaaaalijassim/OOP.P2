from abc import ABC, abstractmethod
import datetime

# Abstract Role Interface
class Role(ABC):
    @abstractmethod
    def role_actions(self):
        pass

# Course Class
class Course:
    def __init__(self):
        self.enrolled_students = {}
        self.max_students = 25
        self.override_requests = []  # Track enrollment override requests
        self.attendance = {}  # Track attendance for students
        self.exam_dates = None  # Store exam schedule (midterm, final)
        self.student_counter = 0  # For unique access code generation

    def create_course(self, name, code, credit_hours=3, priority="Normal"):
        self.name = name
        self.code = code
        self.credit_hours = credit_hours
        self.priority = priority

    def enroll_student(self, student):
        if len(self.enrolled_students) < self.max_students:
            self.student_counter += 1
            access_code = f"{student.student_id}-{self.student_counter}"  # Generate unique code
            self.enrolled_students[student.student_id] = {
                "grades": {"quizzes": 0, "assignments": 0, "reports": 0, "final": 0},
                "access_code": access_code,
            }
            self.attendance[student.student_id] = 0  # Initialize attendance
            return f"Student {student.name} successfully enrolled in {self.name}. Access Code: {access_code}"
        return f"Course {self.name} is full. Request override to join."

    def drop_student(self, student_id):
        if student_id in self.enrolled_students:
            del self.enrolled_students[student_id]
            del self.attendance[student_id]
            return f"Student {student_id} dropped from {self.name}."
        return "Student not found in this course."

    def show_course(self):
        return f"{self.name} ({self.code}) | Priority: {self.priority} | Enrolled: {len(self.enrolled_students)}/{self.max_students}"

    def show_grades(self, student_id):
        if student_id in self.enrolled_students:
            grades = self.enrolled_students[student_id]["grades"]
            return grades
        return "Student not found in this course."

    def set_grades(self, student_id, quizzes, assignments, reports, final):
        if student_id in self.enrolled_students:
            self.enrolled_students[student_id]["grades"] = {
                "quizzes": quizzes,
                "assignments": assignments,
                "reports": reports,
                "final": final,
            }
            return "Grades updated successfully."
        return "Student not found in this course."

    def set_exam_schedule(self, exam_type, date):
        if not self.exam_dates:
            self.exam_dates = {}
        self.exam_dates[exam_type] = date
        return f"{exam_type} exam scheduled for {date}"

# Schedule Class
class Schedule:
    def __init__(self):
        self.courses = {
            "Sunday": [
                ("8:30 AM - 10:30 AM", Course()),
                ("10:30 AM - 12:30 PM", Course()),
                ("12:30 PM - 2:30 PM", Course())
            ],
            "Monday": [
                ("8:30 AM - 10:30 AM", Course()),
                ("10:30 AM - 12:30 PM", Course()),
                ("12:30 PM - 2:30 PM", Course())
            ],
            "Tuesday": [
                ("8:30 AM - 10:30 AM", Course()),
                ("10:30 AM - 12:30 PM", Course()),
                ("12:30 PM - 2:30 PM", Course())
            ],
            "Wednesday": [
                ("8:30 AM - 10:30 AM", Course()),
                ("10:30 AM - 12:30 PM", Course()),
                ("12:30 PM - 2:30 PM", Course())
            ]
        }
        self._initialize_courses()

    def _initialize_courses(self):
        self.courses["Sunday"][0][1].create_course("Data Structures", "CS101", priority="High")
        self.courses["Sunday"][1][1].create_course("AI", "CS102")
        self.courses["Sunday"][2][1].create_course("Cyber Security", "CS103")
        self.courses["Monday"][0][1].create_course("Machine Learning", "CS201")
        self.courses["Monday"][1][1].create_course("Networks", "CS202")
        self.courses["Monday"][2][1].create_course("Web Development", "CS203")
        self.courses["Tuesday"][0][1].create_course("Databases", "CS301")
        self.courses["Tuesday"][1][1].create_course("Cloud Computing", "CS302")
        self.courses["Tuesday"][2][1].create_course("Software Engineering", "CS303")
        self.courses["Wednesday"][0][1].create_course("Operating Systems", "CS401")
        self.courses["Wednesday"][1][1].create_course("Computer Architecture", "CS402")
        self.courses["Wednesday"][2][1].create_course("Data Science", "CS403")

    def display_schedule(self, day=None):
        if day:
            if day not in self.courses:
                return "Invalid day."
            schedule_str = f"Schedule for {day}:\n"
            for time_slot, course in self.courses[day]:
                schedule_str += f"{time_slot}: {course.show_course() if course else 'No Course'}\n"
            return schedule_str
        else:
            schedule_str = "Full Schedule:\n"
            for day, day_courses in self.courses.items():
                schedule_str += f"{day}:\n"
                for time_slot, course in day_courses:
                    schedule_str += f"{time_slot}: {course.show_course() if course else 'No Course'}\n"
            return schedule_str

# Student Class
class Student(Role):
    def __init__(self, student_id, name):
        self.student_id = student_id
        self.name = name
        self.enrolled_courses = []
        self.payment_status = False
        self.installment_balance = 1000  # Example total fee
        self.payment_plan = "One-time"  # Default plan
        self.last_payment_date = None  # Track last payment date

    def enroll_in_course(self, course):
        if len(self.enrolled_courses) >= 5:
            return "You cannot enroll in more than 5 courses."
        if self.payment_status:
            result = course.enroll_student(self)
            if "successfully" in result:
                self.enrolled_courses.append(course)
            return result
        return "You need to make payment before enrolling in courses."

    def drop_course(self, course):
        if course in self.enrolled_courses:
            result = course.drop_student(self.student_id)
            if "dropped" in result:
                self.enrolled_courses.remove(course)
            return result
        return "You are not enrolled in this course."

    def view_grades(self, course):
        return course.show_grades(self.student_id)

    def make_payment(self, amount):
        if self.payment_plan == "One-time" and amount >= self.installment_balance:
            self.installment_balance = 0
            self.payment_status = True
            return f"Payment completed for {self.name}."
        elif self.payment_plan == "Monthly":
            if amount >= 100:  # Monthly installment
                self.installment_balance -= amount
                if self.installment_balance <= 0:
                    self.payment_status = True
                return f"Partial payment of {amount} accepted. Remaining balance: {self.installment_balance}"
            else:
                return "Minimum installment payment is 100."
        return "Payment not sufficient."

    def set_payment_plan(self, plan):
        if plan in ["One-time", "Monthly"]:
            self.payment_plan = plan
            return f"Payment plan set to {plan}."
        return "Invalid payment plan."

    def set_last_payment_date(self, payment_date):
        self.last_payment_date = payment_date

    def role_actions(self):
        return (
            "1. Enroll in a course\n"
            "2. Drop a course\n"
            "3. View grades\n"
            "4. Make payment\n"
            "5. Set payment plan\n"
        )

# Teacher Class
class Teacher(Role):
    def __init__(self, teacher_id, name):
        self.teacher_id = teacher_id
        self.name = name
        self.notifications = []

    def assign_grades(self, course, student_id, quizzes, assignments, reports, final):
        return course.set_grades(student_id, quizzes, assignments, reports, final)

    def notify_students(self, message):
        self.notifications.append(message)
        return f"Notification sent to students: {message}"

    def role_actions(self):
        return (
            "1. Assign grades\n"
            "2. Send schedule notifications\n"
            "3. Set exam schedule\n"
        )

# Role Factory
class RoleFactory:
    @staticmethod
    def get_role(role_type, id, name):
        if role_type.lower() == "student":
            return Student(id, name)
        elif role_type.lower() == "teacher":
            return Teacher(id, name)
        else:
            return None

# Command Line Interface (CLI)
def run_cli():
    print("Welcome to the Student-Teacher Management System!")

    while True:
        role_type = input("Enter role (Student/Teacher) or 'exit' to quit: ").strip().lower()
        if role_type == "exit":
            break
        elif role_type not in ["student", "teacher"]:
            print("Invalid role. Try again.")
            continue

        id = input("Enter ID: ").strip()
        name = input("Enter Name: ").strip()

        role = RoleFactory.get_role(role_type, id, name)
        if role:
            print(f"\n{role.name} ({role.teacher_id if role_type == 'teacher' else role.student_id})\n")
            while True:
                print(role.role_actions())
                choice = input("Choose an action: ").strip()
                if choice == '1':
                    if isinstance(role, Student):
                        course_name = input("Enter course name to enroll: ").strip()
                        for day, day_courses in Schedule().courses.items():
                            for time, course in day_courses:
                                if course.name == course_name:
                                    print(role.enroll_in_course(course))
                                    break
                    elif isinstance(role, Teacher):
                        course_code = input("Enter course code: ").strip()
                        student_id = input("Enter student ID: ").strip()
                        quizzes = int(input("Enter quiz score: "))
                        assignments = int(input("Enter assignment score: "))
                        reports = int(input("Enter report score: "))
                        final = int(input("Enter final exam score: "))
                        print(role.assign_grades(course_code, student_id, quizzes, assignments, reports, final))
                elif choice == '2':
                    if isinstance(role, Student):
                        course_name = input("Enter course name to drop: ").strip()
                        for day, day_courses in Schedule().courses.items():
                            for time, course in day_courses:
                                if course.name == course_name:
                                    print(role.drop_course(course))
                                    break
                    elif isinstance(role, Teacher):
                        message = input("Enter notification message: ").strip()
                        print(role.notify_students(message))
                elif choice == '3':
                    if isinstance(role, Teacher):
                        exam_type = input("Enter exam type (midterm/final): ").strip()
                        exam_date = input("Enter exam date (YYYY-MM-DD): ").strip()
                        print(role.set_exam_schedule(exam_type, exam_date))
                    else:
                        print("Invalid choice.")
                elif choice == '4':
                    if isinstance(role, Student):
                        amount = float(input("Enter payment amount: "))
                        print(role.make_payment(amount))
                elif choice == '5':
                    if isinstance(role, Student):
                        plan = input("Enter payment plan (One-time/Monthly): ").strip()
                        print(role.set_payment_plan(plan))
                else:
                    print("Invalid choice. Try again.")
        else:
            print("Error: Invalid role")

run_cli()
