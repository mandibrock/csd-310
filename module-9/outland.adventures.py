#Python script for outland adventures
#Ryan Barber, Miguel Brazon, Amanda Brock - Group 3, 2/28/26

import mysql.connector
from mysql.connector import errorcode

def main():
    try:
        conn = mysql.connector.connect(
            host="localhost",
            user="outland_user",
            password="outlandpass",
            database="outland_adventures"
        )
        cursor = conn.cursor()

        cursor.execute("SHOW TABLES;")
        tables = [row[0] for row in cursor.fetchall()]

        for table in tables:
            print("\n" + "=" * 60)
            print(f"Table: {table.upper()}")
            print("=" * 60)

            cursor.execute(f"DESCRIBE {table};")
            columns = [row[0] for row in cursor.fetchall()]
            print(" | ".join(columns))
            print("-" * 60)

            cursor.execute(f"SELECT * FROM {table};")
            rows = cursor.fetchall()

            if not rows:
                print("(No rows found)")
            else:
                for r in rows:
                    print(" | ".join(str(x) for x in r))

        cursor.close()
        conn.close()

    except mysql.connector.Error as err:
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
            print("Access denied. Check username/password.")
        elif err.errno == errorcode.ER_BAD_DB_ERROR:
            print("Database does not exist. Try running the SQL script first.")
        else:
            print(f"MySQL Error: {err}")

if __name__ == "__main__":
    main()