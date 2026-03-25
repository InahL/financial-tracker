from flask import Flask, jsonify, request, render_template
from flask_cors import CORS
from datetime import date
from model import ExpenseModel

app = Flask(__name__)
CORS(app)
model = ExpenseModel()

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

    amount = data.get('amount')
    expenseName = data.get('expenseName')
    categoryId = data.get('categoryID')
    timestamp = date.today().isoformat()

    expenseId = model.insert_expense(expenseName=expenseName,
                                     amount=amount,
                                     categoryID=categoryId,
                                     userID=userId,
                                     timestamp = timestamp)

    return jsonify({"message": "expense added.", "expenseId": expenseId}), 201

@app.route('/index/expense/<int:expenseId>', methods = ['DELETE'])
def delete_expense(expenseId) -> dict:
    deleted = model.delete_expense(expenseId)
    if deleted:
        return jsonify({"message": "Expense deleted"}), 200
    return jsonify({"Error": "Expense not found"}), 404

if __name__ == "__main__":
    app.run(debug = True)