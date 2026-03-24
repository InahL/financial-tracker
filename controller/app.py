from flask import Flask, jsonify, request
from flask_cors import CORS
from model.model import ExpenseModel

app = Flask(__name__)
CORS(app)
model = ExpenseModel()

@app.route('/index/', methods = ['GET'])
def get_expenses():
    data = model.get_all_expenses()
    return jsonify(data), 200

@app.route('/index/<int: userId>', methods = ['POST'])
def insert_expense(userId) -> int:
    data = request.get_json()

    amount = data.get('amount')
    expenseName = data.get('expenseName')
    categoryId = data.get('categoryId')

    expenseId = model.insert_expense(expenseName=expenseName,
                                     amount=amount,
                                     categoryId=categoryId,
                                     userId=userId)

    return jsonify({"message": "expense added.", "expenseId": expenseId}), 201

@app.route('/index/<int: expenseId>', methods = ['DELETE'])
def delete_expense(expenseId) -> dict:
    deleted = model.delete_expense(expenseId)
    if deleted:
        return jsonify({"messsage": "Expense deleted"}), 200
    return jsonify({"Error": "Expense not found"})

