import sqlite3

# this script is intended to test the db entries and tables
conn = sqlite3.connect("../expenses.db")
cursor= conn.cursor()

sql1 = "SELECT * FROM expense"

rows = cursor.execute(sql1)
print("Table expenses:")
for row in rows:
    print(row)

sql2 = "SELECT * FROM category"

rows = cursor.execute(sql2)
print("Table category:")
for row in rows:
    print(row)

sql3 = "SELECT * FROM user"

rows = cursor.execute(sql3)
print("Table user:")
for row in rows:
    print(row)

conn.close()

"""
Output:

Table expenses:
(1, '2026-03-24', 'Provigo', 400.5, 2, 1)
(2, '2026-03-24', 'Cineplex', 30.5, 4, 2)
(3, '2026-03-24', 'Uber Eats', 175, 3, 1)
Table category:
(1, 'hotels', 'full stay bill at hotels')
(2, 'groceries', 'bills from local grocers')
(3, 'entertainment', 'movies, shows, streaming')
(4, 'hobbies', 'gaming, art supplies, books')
Table user:
(1, 'Alice', 'wonderland')
(2, 'Madhatter', 'teaparty')
"""