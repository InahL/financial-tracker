import sqlite3

# create sqlite schema: this script will create an empty sqlite schema in the parent directory of the app
# to populate the table run the insert_test_data.py after running this script
def create_schema(data_path: str="../expenses.db"):
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
            CategoryName    TEXT NOT NULL UNIQUE,
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

create_schema()

