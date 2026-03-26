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