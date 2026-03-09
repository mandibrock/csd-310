#Ryan Barber Amanda Brock Miguel Brazon 3/8/2026
#Group 3 module 10 assignment

import mysql.connector
from mysql.connector import Error
from dotenv import load_dotenv
import os

load_dotenv()

DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_NAME = os.getenv("DB_NAME")

def print_results(cursor,title):
    print("\n" + "=" * 70)
    print(title)
    print("-"*70)

    columns=[col[0] for col in cursor.description]
    rows=cursor.fetchall()

    print("|".join(columns))
    print("-"*70)

    for row in rows:
        print("|".join(str(value) for value in row))

    print(f"\nTotal rows returned: {len(rows)}")
    print("="*70)

try:
    connection = mysql.connector.connect(
        host=DB_HOST,
        user=DB_USER,
        password=DB_PASSWORD,
        database=DB_NAME
    )

    if connection.is_connected():
        print("Connected to Outland Adventures database.\n")

        cursor = connection.cursor()

        #Report 1
        query = """
        SELECT
            order_type,
            COUNT(*) AS total_orders
        FROM CUSTOMER_ORDER
        GROUP BY order_type;
        """
        cursor.execute(query)
        print_results(cursor, "REPORT 1:Equipment Sales vs Rentals")

        #Report 2
        query2="""
        SELECT
            l.region,
            l.location_name,
            COUNT(b.booking_id) AS booking_count
        FROM BOOKING b
        JOIN TRIP t ON b.trip_id = t.trip_id
        JOIN LOCATION l ON t.location_id = l.location_id
        GROUP BY l.region, l.location_name
        ORDER BY l.region, booking_count DESC;
        """

        cursor.execute(query2)
        print_results(cursor, "REPORT 2: Trip Booking by Location")

        #Report 3
        query3="""
        SELECT
            iu.unit_id,
            p.product_name,
            iu.serial_number,
            iu.acquired_date,
            iu.`condition`
        FROM INVENTORY_UNIT iu
        JOIN PRODUCT p ON iu.product_id = p.product_id
        WHERE iu.acquired_date < (CURDATE() - INTERVAL 5 YEAR)
        ORDER BY iu.acquired_date;
        """

        cursor.execute(query3)
        print_results(cursor,"REPORT 3: Inventory Older Than Five Years")

except Error as e:
    print("Error while connecting to MySQL", e)

finally:
    if 'cursor' in locals() and cursor:
          cursor.close()

    if 'connection' in locals() and connection.is_connected():
          connection.close()
          print("MySQL connection is closed")


