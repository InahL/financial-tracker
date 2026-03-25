const categories = {"hotel": 1, "groceries": 2, "entertainment": 3, "hobbies": 4}
const userId = 2;
function get_expense_form_data(){
    //get form data
    const expenseName = document.getElementById("expenseName").value.trim();
    const cost = document.getElementById("cost").value.trim();
    const category = document.getElementById("category").value;
    return {
        "expenseName": expenseName, "amount": cost, "categoryID": categories[category]
    }
}

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

function display_expenses(expenses) {
    const container = document.getElementById("expensesList");
    // container.innerHTML = ""; // clear old content

    if (expenses.length === 0) {
        container.innerHTML = "<p>No expenses found.</p>";
        return;
    }

    // expenses.forEach(exp => {
    //     const item = document.createElement("div");
    //     item.classList.add("expense-item");

    //     item.innerHTML = `
    //         <p><strong>${exp.expenseName}</strong> — $${exp.amount}</p>
    //         <p>Category: ${exp.CategoryName}</p>
    //         <p>Date: ${exp.timestamp}</p>
    //         <button onclick="delete_expense(${exp.expenseID})">Delete</button>
    //         <hr>
    //     `;

    //     container.appendChild(item);
    // });
}

function delete_expense(expenseId) {
    fetch(`/index/expense/${expenseId}`, {
        method: 'DELETE'
    })
    .then(response => response.json())
    .then(result => {
        alert(result.message);
        load_expenses(); // refresh list
    })
    .catch(error => console.error("Delete failed:", error));
}


//insert data to db
document.addEventListener("DOMContentLoaded", function(){
    load_expenses();
    
    const insertButton = document.getElementById("insert");
    insertButton.addEventListener("click", function(){
        const data = get_expense_form_data();
        if (data){
            fetch(`/index/user/${userId}`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            })
            .then (response => response.json())
            .then(response => {
                alert(response.message);
                document.getElementById("insert_expense").reset();
                load_expenses();
            })
            .catch(error => {
                console.error("Insert failed:"+ error);
                alert("Insert failed.");
            })
        }
    })
})