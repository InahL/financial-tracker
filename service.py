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