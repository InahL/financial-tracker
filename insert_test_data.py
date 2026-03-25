from datetime import date
import sqlite3

# this script adds data to the sqlite db created in the parent directory
# run after running create_schema.py
conn = sqlite3.connect("expenses.db")
cursor = conn.cursor()

# insert test data

sql1 = "INSERT INTO category (categoryName, description) VALUES (?, ?)"
values1 = [ ('hotels', 'full stay bill at hotels'),
            ('groceries','bills from local grocers'),
            ('entertainment', 'movies, shows, streaming'),
            ('hobbies', 'gaming, art supplies, books')
               ]
cursor.executemany(sql1, values1)

sql2 = "INSERT INTO user (username, password) VALUES (?, ?)"
values2 = [("Alice", 'wonderland'),
           ("Madhatter", "teaparty")
            ]
cursor.executemany(sql2, values2)

sql3 = "INSERT INTO expense (timestamp, expenseName, amount, categoryID, userID) VALUES (?, ?, ?, ?, ?)"
values3 = [(date.today().isoformat(), "Provigo", 400.50, 2, 1),
            (date.today().isoformat(), "Cineplex", 30.50, 4, 2),
               (date.today().isoformat(), "Uber Eats", 175.0, 3, 1),
                ]


cursor.executemany(sql3, values3)
conn.commit()
conn.close()

print(f"Schema populated successfully")