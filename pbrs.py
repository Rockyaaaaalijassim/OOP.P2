from abc import ABC, abstractmethod
# تعريف الكورسات (Course)
class AbstractCourse(ABC):
    @abstractmethod
    def create_course(self, name, code, credit_hours=3, max_students=25):
        pass

    @abstractmethod
    def enroll_student(self):
        pass

    @abstractmethod
    def show_course(self):
        pass


class Course(AbstractCourse):
    def create_course(self, name, code, credit_hours=3, max_students=25):
        self.name = name
        self.code = code
        self.credit_hours = credit_hours
        self.max_students = max_students
        self.enrolled_students = 0

    def enroll_student(self):
        if self.enrolled_students < self.max_students:
            self.enrolled_students += 1
            return True  # التسجيل ناجح
        else:
            return False  # المادة ممتلئة

    def show_course(self):
        return f"{self.name} ({self.code}), Credit Hours: {self.credit_hours}, Enrolled: {self.enrolled_students}/{self.max_students}"


# تعريف الطلاب (Student)
class Student:
    id_counter = 1  # عدّاد داخلي
    ID_PREFIX = "UOB-"  # رمز ثابت للمعرف

    def __init__(self):
        self.id = None
        self.name = None
        self.classes = []
        self.__grades = {}
        self.max_classes = 5  # الحد الأقصى لعدد المواد

    def set_student(self, name):
        self.id = f"{Student.ID_PREFIX}{Student.id_counter:04d}"  # رقم ثابت متبوع بعداد بصيغة أربعة أرقام
        Student.id_counter += 1  # زيادة العدّاد لكل طالب جديد
        self.name = name
        self.__grades = {1: None, 2: None}

    def enroll_in_class(self, course):
        if len(self.classes) >= self.max_classes:
            return "Error: You have reached the maximum number of classes."
        elif course.code in [c.code for c in self.classes]:
            return f"Error: You are already enrolled in {course.code}."
        else:
            success = course.enroll_student()
            if success:
                self.classes.append(course)
                return f"Successfully enrolled in {course.name}!"
            else:
                return f"Error: {course.name} is full."

    def show_student(self):
        enrolled_courses = ', '.join([course.code for course in self.classes])
        return f"ID: {self.id}, Name: {self.name}, Enrolled Classes: {enrolled_courses}"


# تعريف الجدول (Schedule)
class Schedule:
    def create_schedule(self):
        self.courses = {
            "Sunday": [Course(), Course(), Course(), Course()],
            "Monday": [Course(), Course(), Course(), Course()],
            "Tuesday": [Course(), Course(), Course(), Course()],
            "Wednesday": [Course(), Course(), Course(), Course()]
        }
        self.schedule_times = ["8:30 AM - 10:30 AM", "10:30 AM - 12:30 PM", "12:30 PM - 2:30 PM", "2:30 PM - 4:30 PM"]

        # إعداد أسماء المواد في الجدول
        self.courses["Sunday"][0].create_course("Data Structures", "CS101")
        self.courses["Sunday"][1].create_course("AI", "CS102")
        self.courses["Sunday"][2].create_course("Web Development", "CS103")
        self.courses["Sunday"][3].create_course("Mathematics", "CS104")
        self.courses["Monday"][0].create_course("Machine Learning", "CS105")
        self.courses["Monday"][1].create_course("Cyber Security", "CS106")
        self.courses["Monday"][2].create_course("Cloud Computing", "CS107")
        self.courses["Monday"][3].create_course("Game Development", "CS108")
        self.courses["Tuesday"][0].create_course("Databases", "CS109")
        self.courses["Tuesday"][1].create_course("Networks", "CS110")
        self.courses["Tuesday"][2].create_course("Operating Systems", "CS111")
        self.courses["Tuesday"][3].create_course("Algorithms", "CS112")
        self.courses["Wednesday"][0].create_course("Software Engineering", "CS113")
        self.courses["Wednesday"][1].create_course("Web Design", "CS114")
        self.courses["Wednesday"][2].create_course("Mobile Apps", "CS115")
        self.courses["Wednesday"][3].create_course("Big Data", "CS116")

    def display_schedule(self, day):
        schedule_str = f"Schedule for {day}:\n"
        courses = self.courses.get(day, [])

        if courses:
            for i in range(len(courses)):
                time = self.schedule_times[i]
                course = courses[i]
                schedule_str += f"{time}: {course.show_course()}\n"
        else:
            schedule_str += "No courses available.\n"

        return schedule_str

    def register_student_in_courses(self, student):
        registered = 0
        for day, courses in self.courses.items():
            for course in courses:
                if registered < student.max_classes:
                    result = student.enroll_in_class(course)
                    if "Successfully" in result:
                        registered += 1
                else:
                    break
            if registered >= student.max_classes:
                break
        return f"Student registered in {registered} classes."


# تجربة الكود
student1 = Student()
student1.set_student("Ali")

schedule = Schedule()
schedule.create_schedule()

# عرض جدول يوم الاثنين
print(schedule.display_schedule("Monday"))

# تسجيل الطالب في المواد
result = schedule.register_student_in_courses(student1)
print(result)

# عرض معلومات الطالب
print(student1.show_student())

# عرض جدول يوم الأربعاء
print(schedule.display_schedule("Wednesday"))
