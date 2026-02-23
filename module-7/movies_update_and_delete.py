# ----------------------------------------------
# Author: Amanda Brock
# Date: February 22, 2026
# Assignment: Module 7.2
# Purpose of Code: Displays films with genre + studio names then does three other things:
# 1. inserts a new film
# 2. updates alien to horror
# 3. deletes gladiator
# ----------------------------------------------

import mysql.connector
from mysql.connector import errorcode
from dotenv import dotenv_values
from pathlib import Path


def show_films(cursor, title):
    print(f"\n-- {title} --")

    query = """
        SELECT
            film.film_name AS Name,
            film.film_director AS Director,
            genre.genre_name AS Genre,
            studio.studio_name AS Studio
        FROM film
        INNER JOIN genre ON film.genre_id = genre.genre_id
        INNER JOIN studio ON film.studio_id = studio.studio_id
        ORDER BY film.film_id;
    """

    cursor.execute(query)
    films = cursor.fetchall()

    for film in films:
        print(f"Film Name: {film[0]}")
        print(f"Director: {film[1]}")
        print(f"Genre Name ID: {film[2]}")
        print(f"Studio Name: {film[3]}\n")


def main():
    try:
        env_path = Path(__file__).with_name(".env")
        secrets = dotenv_values(env_path)

        config = {
            "user": secrets["USER"],
            "password": secrets["PASSWORD"],
            "host": secrets["HOST"],
            "database": secrets["DATABASE"],
            "raise_on_warnings": True
        }

        db = mysql.connector.connect(**config)
        cursor = db.cursor()

        # 1) Display films
        show_films(cursor, "DISPLAYING FILMS")

        # 2) Insert a new film (only if it doesn't already exist)
        check_query = """
            SELECT film_id FROM film
            WHERE film_name = %s
              AND film_director = %s
              AND film_releaseDate = %s
            LIMIT 1;
        """
        check_values = ("Inception", "Christopher Nolan", "2010")
        cursor.execute(check_query, check_values)

        if cursor.fetchone() is None:
            insert_query = """
                INSERT INTO film
                    (film_name, film_releaseDate, film_runtime, film_director, studio_id, genre_id)
                VALUES
                    (%s, %s, %s, %s,
                     (SELECT studio_id FROM studio WHERE studio_name = '20th Century Fox' LIMIT 1),
                     (SELECT genre_id FROM genre WHERE genre_name = 'SciFi' LIMIT 1));
            """
            insert_values = ("Inception", "2010", 148, "Christopher Nolan")
            cursor.execute(insert_query, insert_values)
            db.commit()
        else:
            pass
        show_films(cursor, "DISPLAYING FILMS AFTER INSERT")

        # 3) Update Alien to Horror
        update_query = """
            UPDATE film
            SET genre_id = (SELECT genre_id FROM genre WHERE genre_name = 'Horror' LIMIT 1)
            WHERE film_name = 'Alien';
        """
        cursor.execute(update_query)
        db.commit()

        show_films(cursor, "DISPLAYING FILMS AFTER UPDATE")

        # 4) Delete Gladiator
        delete_query = """
            DELETE FROM film
            WHERE film_name = 'Gladiator';
        """
        cursor.execute(delete_query)
        db.commit()

        show_films(cursor, "DISPLAYING FILMS AFTER DELETE")

        cursor.close()
        db.close()

    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            print("Error: Username or password is incorrect.")
        elif err.errno == errorcode.ER_BAD_DB_ERROR:
            print("Error: The database does not exist.")
        else:
            print(err)

    except KeyError as err:
        print(f"Missing .env key: {err}. Check your .env file values.")


if __name__ == "__main__":
    main()
