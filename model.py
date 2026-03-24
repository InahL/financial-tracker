import sqlite3

class ExpenseModel:
    def __init__(self, db_path="expenses.db"):
        self.conn = sqlite3.connect(db_path)
        self.conn.row_factory = sqlite3.Row
        self.cursor = self.conn.cursor()

    def get_all_expenses(self):
        sql = """
        SELECT 
            e.expenseID,
            e.expenseName,
            e.amount,
            e.timestamp,
            c.categoryName,
            u.userID,
            u.username
        FROM expense e
        JOIN category c ON e.categoryID = c.categoryID
        JOIN user u ON e.userID = u.userID
        """
        self.cursor.execute(sql)
        rows = self.cursor.fetchall()
        return [dict(row) for row in rows]

    def insert_expense(self, expenseName, amount, categoryID, userID, timestamp):
        sql = """
        INSERT INTO expense (expenseName, amount, categoryID, userID, timestamp)
        VALUES (?, ?, ?, ?, ?)
        """
        self.cursor.execute(sql, (expenseName, amount, categoryID, userID, timestamp))
        self.conn.commit()
        return self.cursor.lastrowid

    def delete_expense(self, expenseID):
        sql = "DELETE FROM expense WHERE expenseID = ?"
        self.cursor.execute(sql, (expenseID,))
        self.conn.commit()
        return self.cursor.rowcount

    def __del__(self):
        self.cursor.close()
        self.conn.close()