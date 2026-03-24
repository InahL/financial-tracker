import sqlite3

# DB in same working directory
conn = sqlite3.connect("expenses.db")
cursor= conn.cursor()

sql = "SELECT * FROM expense"

rows = cursor.execute(sql)
for row in rows:
    print(row)

conn.close()