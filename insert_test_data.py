from datetime import date
import sqlite3

# this script adds data to the sqlite db created in the parent directory
# run after running create_schema.py
conn = sqlite3.connect("expenses.db")
cursor = conn.cursor()

# insert test data

sql1 = "INSERT INTO category (categoryName, description) VALUES (?, ?)"
values1 = [ ('accommodation', 'rent, full stay bills at hotels, couch surfing, etc.'),
            ('groceries','bills from local grocers, take out food, restaurants, etc.'),
            ('entertainment', 'movies, shows, streaming, etc.'),
            ('hobbies', 'gaming, art supplies, books')
               ]
cursor.executemany(sql1, values1)

sql2 = "INSERT INTO user (username, password) VALUES (?, ?)"
values2 = [("Alice", 'wonderland'),
           ("Madhatter", "teaparty")
            ]
cursor.executemany(sql2, values2)

sql3 = "INSERT INTO expense (timestamp, expenseName, amount, categoryID, userID) VALUES (?, ?, ?, ?, ?)"
values3 = [('2026-01-03', 'January Rent', 1200.00, 1, 1),
            ('2026-01-06', 'Supermarket Run', 86.40, 2, 1),
            ('2026-01-10', 'Cinema Night', 24.00, 3, 1),
            ('2026-01-14', 'Book Purchase', 18.50, 4, 1),
            ('2026-01-18', 'Groceries Restock', 73.20, 2, 1),
            ('2026-01-23', 'Streaming Subscription', 15.99, 3, 1),
            ('2026-01-27', 'Painting Supplies', 32.75, 4, 1),

            # USER 1 : February 2026
            ('2026-02-02', 'February Rent', 1200.00, 1, 1),
            ('2026-02-05', 'Weekly Groceries', 91.10, 2, 1),
            ('2026-02-09', 'Concert Ticket', 58.00, 3, 1),
            ('2026-02-13', 'Knitting Yarn', 21.40, 4, 1),
            ('2026-02-17', 'Fresh Market', 67.85, 2, 1),
            ('2026-02-22', 'Movie Rental', 12.99, 3, 1),
            ('2026-02-26', 'Board Game', 44.30, 4, 1),

            # USER 1 : March 2026
            ('2026-03-01', 'March Rent', 1200.00, 1, 1),
            ('2026-03-04', 'Groceries', 88.65, 2, 1),
            ('2026-03-08', 'Bowling Night', 29.50, 3, 1),
            ('2026-03-12', 'Craft Materials', 26.80, 4, 1),
            ('2026-03-16', 'Supermarket', 79.95, 2, 1),
            ('2026-03-20', 'Museum Ticket', 17.00, 3, 1),
            ('2026-03-24', 'Puzzle Set', 19.99, 4, 1),

            # USER 2 : January 2026
            ('2026-01-02', 'Apartment Rent', 1450.00, 1, 2),
            ('2026-01-07', 'Grocery Store', 102.35, 2, 2),
            ('2026-01-11', 'Dinner Out', 41.60, 3, 2),
            ('2026-01-15', 'Gym Equipment', 55.00, 4, 2),
            ('2026-01-19', 'Groceries', 76.45, 2, 2),
            ('2026-01-24', 'Arcade Night', 28.90, 3, 2),
            ('2026-01-29', 'Soccer Ball', 22.00, 4, 2),

            # USER 2 : February 2026
            ('2026-02-01', 'Apartment Rent', 1450.00, 1, 2),
            ('2026-02-06', 'Supermarket', 95.80, 2, 2),
            ('2026-02-10', 'Theatre Ticket', 49.50, 3, 2),
            ('2026-02-14', 'Sketchbook', 16.20, 4, 2),
            ('2026-02-18', 'Groceries Restock', 82.10, 2, 2),
            ('2026-02-21', 'Streaming Service', 13.99, 3, 2),
            ('2026-02-25', 'Tennis Racket Grip', 14.75, 4, 2),

            # USER 2 : March 2026
            ('2026-03-03', 'Apartment Rent', 1450.00, 1, 2),
            ('2026-03-06', 'Groceries', 108.45, 2, 2),
            ('2026-03-09', 'Live Show', 63.00, 3, 2),
            ('2026-03-13', 'Video Game', 39.99, 4, 2),
            ('2026-03-17', 'Market Shopping', 84.30, 2, 2),
            ('2026-03-21', 'Coffee with Friends', 18.25, 3, 2),
            ('2026-03-25', 'Basketball Net', 27.50, 4, 2)
                ]


cursor.executemany(sql3, values3)
conn.commit()
conn.close()

print(f"Schema populated successfully")