"""
This file contains the model for the DynamoDB table.
"""
from pynamodb.models import Model
from pynamodb.attributes import UnicodeAttribute
from lib import get_course_schedule


class SingleTableModel(Model):
    """
    This class defines the model for the DynamoDB table.
    """
    class Meta:
        """
        This class defines the metadata for the DynamoDB table.
        """
        table_name = "florentia_academy_db"
        region = 'us-west-2'
        host = "http://localhost:8000"
    pk = UnicodeAttribute(hash_key=True)
    sk = UnicodeAttribute(range_key=True)
    data = UnicodeAttribute(null=True)

    def semester_schedule_pk(semester_id):
        return f"SCHEDULE#SEMESTER#{semester_id}"

    def semester_schedule_sk(course_id, period_id, teacher_id):
        return f"COURSE#{course_id}#PERIOD#{period_id}#TEACHER#{teacher_id}"


def seed_students():
    reader = get_reader("students.csv")
    for row in reader:
        id, last, first, dob = row
        student = SingleTableModel(pk=SingleTableModel.semester_schedule_pk(id), sk=SingleTableModel.semester_schedule_sk())
        data = {
            "first": first,
            "last": last,
            "dob": dob
        }
        student.data = json.dumps(data)
        student.save()
