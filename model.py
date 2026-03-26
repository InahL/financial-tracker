import sqlite3
import os

class ExpenseModel:
    def __init__(self):
        base_dir = os.path.dirname(os.path.abspath(__file__))
        self.db_path = os.path.join(base_dir, "expenses.db")
        print("Using DB:", self.db_path)

    def get_connection(self):
        if not os.path.exists(self.db_path):
            raise Exception("Database not found. Run schema first.")

        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        return conn

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
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(sql)
        rows = cursor.fetchall()
        conn.close()
        return [dict(row) for row in rows]

    def insert_expense(self, expenseName, amount, categoryID, userID, timestamp):
        sql = """
        INSERT INTO expense (expenseName, amount, categoryID, userID, timestamp)
        VALUES (?, ?, ?, ?, ?)
        """
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(sql, (expenseName, amount, categoryID, userID, timestamp))
        conn.commit()
        expense_id = cursor.lastrowid
        conn.close()
        return expense_id

    def delete_expense(self, expenseID):
        sql = "DELETE FROM expense WHERE expenseID = ?"
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(sql, (expenseID,))
        conn.commit()
        deleted_count = cursor.rowcount
        conn.close()
        return deleted_count
    
    def get_expenses_by_user(self, userId):
        query = """
        SELECT  
            e.expenseID,
            e.expenseName,
            e.amount,
            e.timestamp,
            c.categoryName
        FROM expense e
        JOIN category c ON e.categoryID = c.categoryID 
        WHERE e.userID = ?
        """
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(query, (userId,))
        rows = cursor.fetchall()
        conn.close()
        return [dict(row) for row in rows]

    def update_expense(self, expenseID, expenseName, amount, categoryID):
        sql = """
        UPDATE expense
        SET expenseName = ?, amount = ?, categoryID = ?
        WHERE expenseID = ?
        """
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(sql, (expenseName, amount, categoryID, expenseID))
        conn.commit()
        updated_count = cursor.rowcount
        conn.close()
        return updated_count

    def get_monthly_totals_for_user(self, user_id):
        query = """
        SELECT 
            strftime('%Y-%m', timestamp) as month,
            SUM(amount) as total
        FROM expense
        WHERE userID = ?
        GROUP BY month
        ORDER BY month
        """
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute(query, (user_id,))
        rows = cursor.fetchall()
        conn.close()

        return [dict(row) for row in rows]