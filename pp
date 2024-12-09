from abc import ABC, abstractmethod

class AbstractCourse(ABC):
    @abstractmethod
    def create_course(self, name, code, credit_hours=3, max_students=25, priority="Normal", fee=0, level="Beginner", prerequisites=[]):
        pass

    @abstractmethod
    def enroll_student(self, student):
        pass

    @abstractmethod
    def show_course(self):
        pass

    @abstractmethod
    def add_feedback(self, student, rating, comment):
        pass

    @abstractmethod
    def show_feedback(self):
        pass

class Course(AbstractCourse):
    def create_course(self, name, code, credit_hours=3, max_students=25, priority="Normal", fee=0, level="Beginner", prerequisites=[]):
        self.name = name
        self.code = code
        self.credit_hours = credit_hours
        self.max_students = max_students
        self.priority = priority
        self.fee = fee
        self.level = level
        self.enrolled_students = 0
        self.prerequisites = prerequisites
        self.attendance = {}
        self.waiting_list = []
        self.feedback = []
        self.instructor = None

    def __repr__(self):
        return f"Course({self.name}, Code: {self.code}, Fee: ${self.fee}, Max Students: {self.max_students})"

    def enroll_student(self, student):
        # Check if the student has completed the prerequisites
        if not all(prerequisite in [course.name for course in student.classes] for prerequisite in self.prerequisites):
            return f"You need to complete the prerequisites for {self.name} first."

        if self.enrolled_students < self.max_students:
            self.enrolled_students += 1
            student.classes.append(self)
            return True
        else:
            self.waiting_list.append(student)
            return f"{self.name} is full. You have been added to the waiting list."

    def show_course(self):
        return f"{self.name} ({self.code}), Level: {self.level}, Priority: {self.priority}, Credit Hours: {self.credit_hours}, Fee: ${self.fee}"

    def add_feedback(self, student, rating, comment):
        self.feedback.append({"student": student.name, "rating": rating, "comment": comment})

    def show_feedback(self):
        for feedback in self.feedback:
            print(f"{feedback['student']} rated {feedback['rating']}/5: {feedback['comment']}")

class Student:
    id_counter = 1
    ID_PREFIX = "UOB-"
    def __init__(self):
        self.id = None
        self.name = None
        self.classes = []
        self.__grades = {}
        self.activity_log = []
        self.max_classes = 5
        self.fees_paid = False

    def set_student(self, name):
        self.id = f"{Student.ID_PREFIX}{Student.id_counter:04d}"
        Student.id_counter += 1
        self.name = name
        self.__grades = {}

    def enroll_in_class(self, course):
        if not self.fees_paid:
            return "Error: You cannot enroll in classes until fees are paid."

        if not all(prerequisite in [course.name for course in self.classes] for prerequisite in course.prerequisites):
            return f"You must complete prerequisites for {course.name} before enrolling."

        if len(self.classes) >= self.max_classes:
            return "Error: You have reached the maximum number of classes."
        elif course.code in [c.code for c in self.classes]:
            return f"Error: You are already enrolled in {course.code}."
        else:
            return course.enroll_student(self)

    def log_activity(self, activity):
        self.activity_log.append(activity)

    def show_activity_log(self):
        return "\n".join(self.activity_log)

    def drop_class(self, course_code):
        for course in self.classes:
            if course.code == course_code:
                self.classes.remove(course)
                course.enrolled_students -= 1
                self.log_activity(f"Dropped {course.name}.")
                if course.waiting_list:
                    next_student = course.waiting_list.pop(0)
                    next_student.enroll_in_class(course)
                    next_student.log_activity(f"Enrolled in {course.name} from waiting list.")
                return f"Successfully dropped {course.name}."
        return "Error: Course not found."

    def show_student(self):
        enrolled_courses = ', '.join([course.code for course in self.classes])
        return f"ID: {self.id}, Name: {self.name}, Enrolled Classes: {enrolled_courses}"

    def pay_fees(self, amount):
        if amount >= 300:
            self.fees_paid = True
            return f"Fees of ${amount} have been paid by {self.name}."
        else:
            return "Error: Insufficient fee amount. Minimum fee is $300."

    def show_grades(self):
        if not self.__grades:
            return "No grades available."
        return "\n".join([f"{course.name}: {grade}" for course, grade in self.__grades.items()])

    def set_grade(self, course, grade):
        self.__grades[course] = grade

    def check_duplicate_enrollment(self, course):
        if any(c.code == course.code for c in self.classes):
            return f"You are already enrolled in {course.name}."
        return None

    def list_all_courses(self):
        all_courses = []
        for day, courses in self.schedule.courses.items():
            for course in courses:
                all_courses.append(course.show_course())
        return "\n".join(all_courses)

    def total_fee(self):
        total = sum(course.fee for course in self.classes)
        return f"Total fees for enrolled courses: ${total}"

    def completed_courses(self):
        completed = [f"{course.name}: {grade}" for course, grade in self.__grades.items()]
        return "\n".join(completed) if completed else "No completed courses."

class Instructor:
    def __init__(self, name):
        self.name = name

    def mark_attendance(self, course, student, present=True):
        if student.id not in course.attendance:
            course.attendance[student.id] = []
        course.attendance[student.id].append(present)

class Schedule:
    def create_schedule(self):
        self.courses = {
            "Sunday": [Course(), Course(), Course()],
            "Monday": [Course(), Course(), Course()],
            "Tuesday": [Course(), Course(), Course()],
            "Wednesday": [Course(), Course(), Course()]
        }
        self.schedule_times = ["8:30 AM - 10:30 AM", "10:30 AM - 12:30 PM", "12:30 PM - 2:30 PM"]

        self.courses["Sunday"][0].create_course("Data Structures", "CS101", priority="High", level="Beginner", fee=300)
        self.courses["Sunday"][1].create_course("AI", "CS102", prerequisites=["Data Structures"], fee=300)
        self.courses["Monday"][0].create_course("Machine Learning", "CS105", prerequisites=["AI"], fee=300)
        self.courses["Monday"][1].create_course("Cyber Security", "CS106", fee=250)

    def search_courses(self, criteria, value):
        results = []
        for day, courses in self.courses.items():
            for course in courses:
                if getattr(course, criteria) == value:
                    results.append(course)
        return results

    def generate_report(self, course):
        print(f"Report for {course.name}:")
        print(f"Enrolled students: {course.enrolled_students}")
        print(f"Waiting list: {len(course.waiting_list)}")

    def display_schedule(self, day):
        schedule_str = f"Schedule for {day}:\n"
        courses = self.courses.get(day, [])

        if courses:
            for i in range(len(courses)):
                time = self.schedule_times[i]
                course = courses[i]
                schedule_str += f"{time}: {course.show_course()}"
                if course.enrolled_students >= course.max_students:
                    schedule_str += " - Full"
                schedule_str += "\n"
        else:
            schedule_str += "No courses available.\n"

        return schedule_str

    def display_waitlist(self, course):
        if course.waiting_list:
            return [student.name for student in course.waiting_list]
        return "No students are on the waitlist."

# Main Interface
def main_interface():
    access_code = "UOF2024-5"
    user_code = input("Enter access code: ")

    if user_code == access_code:
        print("Access Granted.")
        # Initialize schedule and student
        student1 = Student()
        student1.set_student("Ali")
        schedule = Schedule()
        schedule.create_schedule()

        # Example usage of grades
        student1.set_grade(schedule.courses["Sunday"][0], "A")
        student1.set_grade(schedule.courses["Sunday"][1], "B+")
        student1.set_grade(schedule.courses["Monday"][1], "A-")

        # Display options
        while True:
            print("\n1. Pay Fees")
            print("2. Enroll in Course")
            print("3. Drop a Course")
            print("4. Show Activity Log")
            print("5. Show Grades")
            print("6. Show Courses List")
            print("7. Total Fee")
            print("8. Completed Courses")
            print("9. Exit")
            option = input("Select an option: ")

            if option == "1":
                amount = int(input("Enter fee amount: "))
                print(student1.pay_fees(amount))
            elif option == "2":
                course_code = input("Enter course code: ")
                course = None
                for day, courses in schedule.courses.items():
                    for c in courses:
                        if c.code == course_code:
                            course = c
                            break
                if course:
                    print(student1.enroll_in_class(course))
                else:
                    print("Course not found.")
            elif option == "3":
                course_code = input("Enter course code to drop: ")
                print(student1.drop_class(course_code))
            elif option == "4":
                print(student1.show_activity_log())
            elif option == "5":
                print(student1.show_grades())
            elif option == "6":
                print(student1.list_all_courses())
            elif option == "7":
                print(student1.total_fee())
            elif option == "8":
                print(student1.completed_courses())
            elif option == "9":
                print("Exiting...")
                break
            else:
                print("Invalid option.")
    else:
        print("Access Denied.")

# Running the main interface
if __name__ == "__main__":
    main_interface()

