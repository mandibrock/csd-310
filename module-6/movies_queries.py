# ----------------------------------------------
# Author: Amanda Brock
# Date: February 15, 2026
# Assignment: Module 6.2
# Purpose of Code: 
# ----------------------------------------------

from pathlib import Path
import mysql.connector
from mysql.connector import errorcode
from dotenv import dotenv_values


def print_title(title):
    print(f"\n-- {title} --")


def main():
    # Load .env from the same folder as this script
    env_path = Path(__file__).with_name(".env")
    secrets = dotenv_values(env_path)

    config = {
        "user": secrets["USER"],
        "password": secrets["PASSWORD"],
        "host": secrets["HOST"],
        "database": secrets["DATABASE"],
        "raise_on_warnings": True
    }

    try:
        db = mysql.connector.connect(**config)
        cursor = db.cursor()

        # ---------------- QUERY 1 ----------------
        print_title("DISPLAYING Studio RECORDS")
        cursor.execute("SELECT studio_id, studio_name FROM studio")
        studios = cursor.fetchall()
        for studio in studios:
            print(f"Studio ID: {studio[0]}")
            print(f"Studio Name: {studio[1]}\n")

        # ---------------- QUERY 2 ----------------
        print_title("DISPLAYING Genre RECORDS")
        cursor.execute("SELECT genre_id, genre_name FROM genre")
        genres = cursor.fetchall()
        for genre in genres:
            print(f"Genre ID: {genre[0]}")
            print(f"Genre Name: {genre[1]}\n")

        # ---------------- QUERY 3 ----------------
        print_title("DISPLAYING Short Film RECORDS")
        cursor.execute("SELECT film_name, film_runtime FROM film WHERE film_runtime < 120")
        films = cursor.fetchall()
        for film in films:
            print(f"Film Name: {film[0]}")
            print(f"Run Time: {film[1]}\n")

        # ---------------- QUERY 4 ----------------
        print_title("DISPLAYING Director RECORDS in Order")
        cursor.execute("SELECT film_name, film_director FROM film ORDER BY film_director")

        films = cursor.fetchall()
        for film in films:
            print(f"Film Name: {film[0]}")
            print(f"Director: {film[1]}\n")

    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            print("The supplied username or password are invalid")
        elif err.errno == errorcode.ER_BAD_DB_ERROR:
            print("The specified database does not exist")
        else:
            print(err)

    finally:
        try:
            cursor.close()
            db.close()
        except:
            pass


if __name__ == "__main__":
    main()
