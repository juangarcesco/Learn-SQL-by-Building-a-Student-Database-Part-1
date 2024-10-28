#!/bin/bash

# Script para insertar datos de courses.csv y students.csv en la base de datos students.db

PSQL="psql -X --username=freecodecamp --dbname=students --no-align --tuples-only -c"
echo $($PSQL "TRUNCATE students, majors, courses, majors_courses") # Borra datos de las tablas para iniciar de cero

# Lee courses.csv y procesa cada línea
cat courses.csv | while IFS="," read MAJOR COURSE
do
  if [[ $MAJOR != "major" ]] # Omite la primera línea (encabezado)
  then
    # Obtiene el ID de la carrera
    MAJOR_ID=$($PSQL "SELECT major_id FROM majors WHERE major='$MAJOR'")

    # Si no encuentra el ID de la carrera
    if [[ -z $MAJOR_ID ]]
    then
      # Inserta la carrera
      INSERT_MAJOR_RESULT=$($PSQL "INSERT INTO majors(major) VALUES('$MAJOR')")
      if [[ $INSERT_MAJOR_RESULT == "INSERT 0 1" ]]
      then
        echo Insertado en majors, $MAJOR
      fi

      # Obtiene el nuevo major_id
      MAJOR_ID=$($PSQL "SELECT major_id FROM majors WHERE major='$MAJOR'")
    fi

    # Obtiene el ID del curso
    COURSE_ID=$($PSQL "SELECT course_id FROM courses WHERE course='$COURSE'")

    # Si no encuentra el ID del curso
    if [[ -z $COURSE_ID ]]
    then
      # Inserta el curso
      INSERT_COURSE_RESULT=$($PSQL "INSERT INTO courses(course) VALUES('$COURSE')")
      if [[ $INSERT_COURSE_RESULT == "INSERT 0 1" ]]
      then
        echo Insertado en courses, $COURSE
      fi

      # Obtiene el nuevo course_id
      COURSE_ID=$($PSQL "SELECT course_id FROM courses WHERE course='$COURSE'")
    fi

    # Inserta en majors_courses
    INSERT_MAJORS_COURSES_RESULT=$($PSQL "INSERT INTO majors_courses(major_id, course_id) VALUES($MAJOR_ID, $COURSE_ID)")
    if [[ $INSERT_MAJORS_COURSES_RESULT == "INSERT 0 1" ]]
    then
      echo Insertado en majors_courses, $MAJOR : $COURSE
    fi
  fi
done

# Lee students.csv y procesa cada línea
cat students.csv | while IFS="," read FIRST LAST MAJOR GPA
do
  if [[ $FIRST != "first_name" ]] # Omite la primera línea (encabezado)
  then
    # Obtiene el ID de la carrera
    MAJOR_ID=$($PSQL "SELECT major_id FROM majors WHERE major='$MAJOR'") 
    
    # Si no encuentra el ID de la carrera
    if [[ -z $MAJOR_ID ]]     
    then
      # Establece el ID a null
      MAJOR_ID=null
    fi   

   # Inserta el estudiante
   INSERT_STUDENT_RESULT=$($PSQL "INSERT INTO students(first_name, last_name, major_id, gpa) VALUES('$FIRST', '$LAST', $MAJOR_ID, $GPA)")
   if [[ $INSERT_STUDENT_RESULT == "INSERT 0 1" ]]
then
  echo "Insertado en students, $FIRST $LAST"
fi
  fi
done
