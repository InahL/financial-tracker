cat >setup_expenses_app.sh << 'EOF'
#!/usr/bin/env bash
sudo chmod +x "$0"   # makes itself executable
set -euo pipefail

# === Setup a full-stack app expense tracker on AWS EC2 instance with Docker Compose ==
# - Backend: Python, Flask + SQLite (Python 3.11-slim in Docker)
# - Frontend: JS/HTML/CSS
# - Orchestration: docker compose

APP_DIR="$HOME/financial-tracker"

print_step() {
  echo
  echo "=============================================="
  echo "[Step] $1"
  echo "=============================================="
}

print_note() {
  echo "[Note] $1"
}

# 1) Install Docker and Docker Compose plugin
print_step "Installing Docker and Docker Compose plugin"
sudo dnf install docker -y
sudo systemctl enable --now docker
sudo systemctl start docker

# Add current user to docker group (effective after re-login)
sudo usermod -aG docker "$USER" || true
print_note "If you want to run 'docker' without sudo in new terminals, log out and back in. This script will continue using sudo."

# 2) Create project structure
print_step "Creating project structure at $APP_DIR"
mkdir -p "$APP_DIR" "$APP_DIR/static" "$APP_DIR/templates"

# 3) Write backend files (Python, Flask + SQLite)
print_step "Writing backend files"
cat > "$APP_DIR/requirements.txt" << 'FILE'
Flask==3.1.3
flask-cors==6.0.2
requests==2.32.5
FILE

cat > "$APP_DIR/create_schema.py" << 'FILE'
import sqlite3

# create sqlite schema: this script will create an empty sqlite schema in the parent directory of the app
# to populate the table run the insert_test_data.py after running this script
def create_schema(data_path: str="expenses.db"):
    conn = sqlite3.connect(data_path)
    cursor = conn.cursor()

    sql = """
        DROP TABLE IF EXISTS expense;
        DROP TABLE IF EXISTS category;
        DROP TABLE IF EXISTS user;

        CREATE TABLE IF NOT EXISTS user (
            userID      INTEGER PRIMARY KEY AUTOINCREMENT,
            username    VARCHAR(45) NOT NULL UNIQUE,
            password    VARCHAR(45) NOT NULL
        );

        CREATE TABLE IF NOT EXISTS category (
            categoryID      INTEGER PRIMARY KEY AUTOINCREMENT,
            categoryName    TEXT NOT NULL UNIQUE,
            description     TEXT
        );

        CREATE TABLE IF NOT EXISTS expense (
            expenseID   INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp       DATE NOT NULL,
            expenseName     VARCHAR(45),
            amount          DECIMAL(10,2) NOT NULL,
            categoryID      INTEGER NOT NULL,
            userID          INTEGER NOT NULL,
            FOREIGN KEY (categoryID)    REFERENCES category(categoryID),
            FOREIGN KEY (userID)        REFERENCES user(userID)
        );


    """
    cursor.executescript(sql)
    conn.commit()
    conn.close()
    print(f"Schema created successfully in '{data_path}'")

create_schema(data_path="expenses.db")

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
FILE

cat > "$APP_DIR/app.py" << 'FILE'
from flask import Flask, jsonify, request, render_template
from flask_cors import CORS
from datetime import date
from model import ExpenseModel
from service import ExpenseService

app = Flask(__name__)
CORS(app)
model = ExpenseModel()
service = ExpenseService()

@app.route('/index', methods = ['GET'])
def get_expenses():
    data = model.get_all_expenses()
    return jsonify(data), 200

@app.route('/index/user/<int:userId>', methods=['GET'])
def show_expense_page(userId):
    return render_template('index.html', userId=userId)

@app.route('/index/user/<int:userId>', methods = ['POST'])
def insert_expense(userId) -> int:
    data = request.get_json()

    expenseName = data.get('expenseName')
    amount = data.get('amount')
    categoryId = data.get('categoryID')
    timestamp = date.today().isoformat()

    expenseId = model.insert_expense(expenseName=expenseName,
                                     amount=amount,
                                     categoryID=categoryId,
                                     userID=userId,
                                     timestamp = timestamp)

    return jsonify({"message": "expense added.", "expenseId": expenseId}), 201

@app.route('/index/user/<int:userId>/expenses', methods=['GET'])
def get_user_expenses(userId):
    data = model.get_expenses_by_user(userId)
    #return render_template('index.html', expenses=data, userId=userId)
    return jsonify(data), 200

@app.route('/index/expense/<int:expenseId>', methods = ['DELETE'])
def delete_expense(expenseId) -> dict:
    deleted = model.delete_expense(expenseId)
    if deleted:
        return jsonify({"message": "Expense deleted"}), 200
    return jsonify({"Error": "Expense not found"}), 404

@app.route('/index/expense/<int:expenseId>', methods = ['PUT'])
def update_expense(expenseId):
    data = request.get_json()

    expenseName = data.get('expenseName')
    amount = data.get('amount')
    categoryId = data.get('categoryID')

    updated = model.update_expense(expenseID=expenseId,
                                     expenseName=expenseName,
                                     amount=amount,
                                     categoryID=categoryId
                                   )
    if updated:
        return jsonify({"message": "Expense updated"}), 200
    return jsonify({"error": "Expense not found"}), 404

@app.route('/index/user/<int:userId>/summary', methods=['GET'])
def get_user_category_summary(userId):
    data = service.get_category_summary_for_user(userId)
    return jsonify(data), 200

@app.route('/index/user/<int:userId>/monthly', methods=['GET'])
def get_monthly_totals(userId):
    data = model.get_monthly_totals_for_user(userId)
    return jsonify(data), 200

if __name__ == "__main__":
    app.run(debug = True, host="0.0.0.0", port=5000)
FILE

cat > "$APP_DIR/model.py" << 'FILE'
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
FILE

cat > "$APP_DIR/service.py" << 'FILE'
from model import ExpenseModel

class ExpenseService:
    def __init__(self):
        self.model = ExpenseModel()

    def get_category_summary_for_user(self, user_id):
        expenses = self.model.get_expenses_by_user(user_id)

        totals = {}
        grand_total = 0

        for exp in expenses:
            category = exp["categoryName"]
            amount = float(exp["amount"])

            totals[category] = totals.get(category, 0) + amount
            grand_total += amount

        result = []
        for category, total in totals.items():
            percentage = 0 if grand_total == 0 else round((total / grand_total) * 100, 2)
            result.append({
                "category": category,
                "total": round(total, 2),
                "percentage": percentage
            })

        return result
FILE

# ======================================================
# 4) Write frontend files (JavaScript app + HTML/CSS)
print_step "Writing frontend files"

cat > "$APP_DIR/static/script.js" << 'FILE'
const categories = {"accommodation": 1, "groceries": 2, "entertainment": 3, "hobbies": 4}
let editingExpenseId = null;
let expenseChart = null;
let monthlyChart = null;

// hard coded userId for demo purposes
const userId = 1;

function get_expense_form_data(){
    //get form data
    const expenseName = document.getElementById("expenseName").value.trim();
    const cost = document.getElementById("cost").value.trim();
    const category = document.getElementById("category").value;
    return {
        "expenseName": expenseName, "amount": cost, "categoryID": categories[category]
    }
}

// fetch expenses per user id from backend
function load_expenses() {
    fetch(`/index/user/${userId}/expenses`)
    .then(response => response.json())
    .then(data => {
        display_expenses(data);
    })
    .catch(error => {
        console.error("Failed to load expenses:", error);
    });
}

// display expenses in web page
function display_expenses(expenses) {
    const tbody = document.getElementById("expensesTableBody");
    tbody.innerHTML = "";

    if (expenses.length === 0) {
        const row = document.createElement("tr");
        row.innerHTML = `<td colspan="5">No expenses found.</td>`;
        tbody.appendChild(row);
        return;
    }

    expenses.forEach(exp => {
        const row = document.createElement("tr");

        row.innerHTML = `
            <td>${exp.expenseName}</td>
            <td>$${exp.amount}</td>
            <td>${exp.categoryName}</td>
            <td>${exp.timestamp}</td>
            <td>
                <button class="btn-update"
                    onclick='show_update_form(${exp.expenseID}, "${exp.expenseName}", "${exp.amount}", "${exp.categoryName}")'>
                    Update

                </button>
                <button class="btn-danger"
                    onclick="delete_expense(${exp.expenseID})">
                    Delete
                </button>
            </td>
        `;

        tbody.appendChild(row);
    });
}

// delete an expense fetch route to backend
function delete_expense(expenseId) {
    fetch(`/index/expense/${expenseId}`, {
        method: 'DELETE'
    })
    .then(response => response.json())
    .then(result => {
        alert(result.message);
        load_expenses(); // refresh list
        load_chart();
        load_monthly_chart()
    })
    .catch(error => console.error("Delete failed:", error));
}


// function to populate the form to update an expense
function show_update_form(expenseId, expenseName, amount, categoryName) {
    document.getElementById("expenseName").value = expenseName;
    document.getElementById("cost").value = amount;
    document.getElementById("category").value = categoryName.toLowerCase();

    editingExpenseId = expenseId;

    document.getElementById("insert").textContent = "Update Expense";
}

//+++++++++++++++++++++++++++++++++++Begin event listener for insert, delete or update expense ++++++++++++++++++++++++++++++++++++++++++++++++++
document.addEventListener("DOMContentLoaded", function () {
    load_expenses();
    load_chart();
    load_monthly_chart();

    const insertButton = document.getElementById("insert");
    insertButton.addEventListener("click", function () {
        const data = get_expense_form_data();

        if (editingExpenseId !== null) {
            fetch(`/index/expense/${editingExpenseId}`, {
                method: "PUT",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify(data)
            })
            .then(response => response.json())
            .then(response => {
                alert(response.message);
                document.getElementById("insert_expense").reset();
                editingExpenseId = null;
                insertButton.textContent = "Insert Expense";
                load_expenses();
                load_chart();
                load_monthly_chart();
            })
            .catch(error => {
                console.error("Update failed:", error);
                alert("Update failed.");
            });
        } else {
            fetch(`/index/user/${userId}`, {
                method: "POST",
                headers: {
                    "Content-Type": "application/json"
                },
                body: JSON.stringify(data)
            })
            .then(response => response.json())
            .then(response => {
                alert(response.message);
                document.getElementById("insert_expense").reset();
                load_expenses();
                load_chart();
                load_monthly_chart();
            })
            .catch(error => {
                console.error("Insert failed:", error);
                alert("Insert failed.");
            });
        }
    });
});
//+++++++++++++++++++++++++++++++++++End event listener for insert, delete or update expense ++++++++++++++++++++++++++++++++++++++++++++++++++

//++++++++++++++++++++++++++++++++++Begin chart displays on dashboard ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//Chart data fetch from backend
function load_chart() {
    fetch(`/index/user/${userId}/summary`)
        .then(response => response.json())
        .then(data => {
            render_chart(data);
        })
        .catch(error => {
            console.error("Failed to load chart data:", error);
        });
}

// Pie chart
function render_chart(summaryData) {
    const ctx = document.getElementById("expenseChart").getContext("2d");

    const labels = summaryData.map(item => item.category);
    const percentages = summaryData.map(item => item.percentage);

    if (expenseChart) {
        expenseChart.destroy();
    }

    expenseChart = new Chart(ctx, {
        type: 'pie',
        data: {
            labels: labels,
            datasets: [{
                label: 'Expense % by Category',
                data: percentages
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
                legend: {
                    position: 'bottom'
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return `${context.label}: ${context.raw}%`;
                        }
                    }
                }
            }
        }
    });
}

//display monthly chart
function load_monthly_chart() {
    fetch(`/index/user/${userId}/monthly`)
        .then(response => response.json())
        .then(data => {
            render_monthly_chart(data);
        })
        .catch(error => {
            console.error("Failed to load monthly chart:", error);
        });
}

function render_monthly_chart(data) {
    const canvas = document.getElementById("monthlyChart");
    if (!canvas) {
        console.error("monthlyChart canvas not found");
        return;
    }

    const ctx = canvas.getContext("2d");
    const labels = data.map(item => item.month);
    const totals = data.map(item => Number(item.total));

    if (monthlyChart) {
        monthlyChart.destroy();
    }

    monthlyChart = new Chart(ctx, {
        type: "bar",
        data: {
            labels: labels,
            datasets: [{
                label: "Monthly Spending",
                data: totals
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            devicePixelRatio: window.devicePixelRatio,
            plugins: {
                legend: {
                    labels: {
                        font: {
                            size: 14
                        }
                    }
                }
            } ,
            scales: {
                x: {
                    ticks: {
                        maxRotation: 0,
                        minRotation: 0,
                        padding: 10,
                        stepSize: 20,
                        font: {
                            size: 14
                        }
                    }
                },
                y: {
                    beginAtZero: true,
                    ticks: {
                        padding: 10,
                        stepSize: 50,
                        font: {
                            size: 14
                        }
                    },
                    grid: {
                        drawBorder: true
                    }
                }
            }
        }
    });
}
FILE

cat > "$APP_DIR/static/styles.css" << 'FILE'

h1, h2 {
    text-align: center;
    margin-bottom: 20px;
}

h1 {
    font-weight: 600;
    margin-top: 20px;
}

h2 {
    font-weight: 500;
    color: #333;
}

table {
    width: 100%;        /* still responsive */
    border-collapse: collapse;
}


th, td {
    padding: 10px;
    text-align: left;
}

th {
    background-color: #f4f4f4;
}

tr:nth-child(even) {
    background-color: #f9f9f9;
}

button {
    padding: 8px 14px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 500;
    transition: all 0.2s ease;
    margin-right: 5px;
}

/* Insert button */
.btn-primary {
    background-color: #4CAF50;
    color: white;
}

.btn-primary:hover {
    background-color: #45a049;
}

/* Delete button */
.btn-danger {
    background-color: #e74c3c;
    color: white;
}

.btn-danger:hover {
    background-color: #c0392b;
}

.btn-update {
    background-color: #f39c12; /* orange */
    color: white;
}

.btn-update:hover {
    background-color: #e67e22;
}

.form-container {
    max-width: 800px;   /* same as table */
    margin: 20px auto;  /* center it */
    padding: 0 10px;
}

.form-row {
    display: flex;
    gap: 10px;
    align-items: center;
    flex-wrap: wrap; /* makes it responsive */
}
.form-row input,
.form-row select {
    padding: 8px;
    border: 1px solid #ccc;
    border-radius: 6px;
    font-size: 14px;
    flex: 1; /* makes them evenly sized */
    min-width: 120px;
}

.table-container {
    max-width: 800px;   /* limits width on big screens */
    margin: 0 auto;     /* centers horizontally */
    padding: 0 10px;    /* small padding for mobile */
}

.charts-row {
    display: flex;
    justify-content: center;
    align-items: flex-start;
    gap: 30px;
    margin: 30px auto 60px auto;
    max-width: 900px;
    flex-wrap: wrap;
}

.chart-card {
    text-align: center;
    margin: 0 auto;
}

.chart-card canvas {
    display: block;
    margin: 0 auto;
}

.pie-chart {
    width: 280px;
    height: 280px;
    flex: 0 0 280px;
    padding-bottom: 40px;
}

.bar-chart {
    flex: 1;              /* take remaining space */
    min-width: 500px;    /* ensure it's not too small */
    height: 360px;
}

.form-container {
    max-width: 800px;
    margin: 30px auto 20px auto;
    padding: 0 10px;
}

canvas {
    image-rendering: auto;
}
FILE

cat > "$APP_DIR/templates/index.html" << 'FILE'
<!DOCTYPE html>
<html>
    <head>
        <title>Expense form</title>
        <link rel="stylesheet" href="{{ url_for('static', filename='styles.css') }}">
    </head>
    <body>
        <h1>Your Expense Page</h1>
            <div class="charts-row">
                <div class="chart-card pie-chart">
                    <h2>Expenses by Category</h2>
                    <canvas id="expenseChart"></canvas>
                </div>

                <div class="chart-card bar-chart">
                    <h2>Monthly Spending</h2>
                    <canvas id="monthlyChart"></canvas>
                </div>
            </div>

        <div class="form-container">
            <h2>Insert an expense</h2>
                <form id="insert_expense" class="form-row">

                    <input type="text" id="expenseName" placeholder="Expense name" required><br>

                    <input type="number" step="any" id="cost" placeholder="Amount" required><br>


                    <select id="category" name="category" required>
                            <option value="groceries">Groceries</option>
                            <option value="hobbies">Hobbies</option>
                            <option value="entertainment">Entertainment</option>
                            <option value="accommodation">Accommodation</option>
                        </select>
                    <p>
                    <button type="button" id="insert" class="btn-primary">Insert</button>
                </p>
                </form>
            </div>
            <div class="table-container">
                <h2>All Your Expenses</h2>

                <table id="expensesTable" border="1">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Amount</th>
                            <th>Category</th>
                            <th>Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="expensesTableBody">
                        <!-- Rows will be inserted here -->
                    </tbody>
                </table>
            </div>

            <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
            <script src="{{ url_for('static', filename='script.js') }}"></script>
    </body>
</html>
FILE

cat > "$APP_DIR/Dockerfile" << 'FILE'
FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 5000

CMD ["sh", "-c", "[ ! -f expenses.db ] && python create_schema.py; python app.py"]
FILE

print_step "Building containers (this may take a few minutes)"
cd "$APP_DIR"
sudo docker build -t expenses-backend .

print_step "Done!"

print_step "Running the container..."
sudo docker run -d -p 5000:5000 --name expenses-api expenses-backend

echo
print_note "Verify on the server:"
echo "  curl -I http://localhost    # should return HTTP/1.1 200 OK"

echo
print_note "Manage the app:"
echo "  cd $APP_DIR"

echo
print_note "To update code: edit files under $APP_DIR, then run:"
echo "  sudo docker compose build && sudo docker compose up -d"
EOF