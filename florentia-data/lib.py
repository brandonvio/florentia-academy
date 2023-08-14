"""
This script generates a random schedule for a semester. The schedule is stored in a dictionary
"""
import random

# Constants
COURSE_ID_RANGE = list(range(100, 181))
TEACHER_ID_RANGE = list(range(100, 181))
PERIODS = list(range(8))
SEMESTER_ID = 1
NUM_COURSES = 10


# Randomly select 10 courses
selected_courses = [random.choice(COURSE_ID_RANGE) for _ in range(NUM_COURSES)]
course_period_combinations = [(course, period) for course in selected_courses for period in PERIODS]

# Dictionary to ensure a teacher doesn't teach on the same period
period_teacher_mapping = {period: set() for period in PERIODS}

# Create course schedule
course_schedule = []

for course, period in course_period_combinations:
    available_teachers = set(TEACHER_ID_RANGE) - period_teacher_mapping[period]
    if available_teachers:
        selected_teacher = random.choice(list(available_teachers))
        period_teacher_mapping[period].add(selected_teacher)
        schedule_entry = {
            "PK": semester_schedule_pk(SEMESTER_ID),
            "SK": semester_schedule_sk(course, period, selected_teacher)
        }
        course_schedule.append(schedule_entry)

# Print the generated schedule
for entry in course_schedule:
    print(entry)
