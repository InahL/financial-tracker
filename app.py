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
    app.run(debug = True)