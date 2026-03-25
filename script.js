const categories = {"hotel": 1, "groceries": 2, "entertainement": 3, "hobbies": 4}
const userId = 1

function get_expense_form_data(){
    //get form data
    const expenseName = document.getElementById("expenseName").value.trim();
    const cost = document.getElementById("cost").value.trim();
    const category = document.getElementById("category").value;
    return {
        "expenseName": expenseName, "cost": cost, "categoryID": categories[category]
    }
}

//insert data to db
document.addEventListener("DOMContentLoaded", function(){
    const insertButton = document.getElementById("insert");
    insertButton.addEventListener("click", function(){
        const data = get_expense_form_data();
        if (data){
            fetch('/index/user/${userId}', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(data)
            })
            .then (respose => respose.json())
            .then(respose => {
                alert(response.message);
                document.getElementById("registrationForm").reset();
            })
            .catch(error => {
                console.error("Insert failed:"+ error);
                alert("Insert failed.");
            })
        }
    })
})