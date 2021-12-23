WITH studentGrade AS(
    WITH assessmentgrade AS (
        SELECT
            id_assessment,
            id_student,
            score
        FROM
            studentassessment
    )
    SELECT
        assessmentgrade.id_student as 'id_student',
        sum((weight / 100 * score)) / sum(weight) as 'grade'
    FROM
        assessmentgrade
        left JOIN assessments on assessmentgrade.id_assessment = assessments.id_assessment
    where
        weight is not null
        and score is not null
    GROUP BY
        assessmentgrade.id_student
),
studentUsage as (
    select
        id_student,
        sum(sum_click) as 'total_click'
    from
        studentvle
    group by
        id_student
)
select
    studentGrade.id_student as 'id_student',
    grade,
    total_click
FROM
    studentGrade
    INNER JOIN studentUsage ON studentGrade.id_student = studentUsage.id_student
where
    grade is not null
    and total_click is not null;