

#  Library Management System (LMS)

This project implements a complete **Library Management System** using **MySQL**, covering all major components such as Employees, Members, Books, Authors, Admins, Transactions, and Memberships. It includes advanced features like **stored procedures**, **triggers**, and **referential integrity** via **foreign key constraints**.

---

##  Schema Overview

The system is structured into several relational tables:

### 1. `EMPLOYEE`
Stores employee details.
- `ID`, `NAME`, `DOB`, `PHNO`, `AGE`

### 2. `ADMIN`
Stores administrative staff details.
- `ID`, `NAME`, `PHNO`

### 3. `MEMBER`
Represents library users/members.
- `ID`, `FIRSTNAME`, `LASTNAME`, `PHNO`, `AGE`, `TYPE`

### 4. `MEMBERSHIP`
Stores types of memberships and associated costs.
- `TYPE`, `PRICE`

### 5. `LIBRARY`
Holds the library's metadata.
- `NAME`, `PHNO`, `CITY`, `STATE`, `PINCODE`

### 6. `AUTHOR`
Holds author information.
- `AUTHOR_ID`, `NAME`

### 7. `BOOK`
Manages the book inventory.
- `BOOKID`, `AUTHORID`, `NAME`, `PRICE`, `RACK_NO`, `SHELF_NO`, `STATUS`

### 8. `PUBLISHER`
Information about book publishers.
- `CODE`, `NAME`, `COUNTRY`

### 9. `TRANSACTION`
Tracks book borrow/return records.
- `TransactionID`, `MemberID`, `BookID`, `BORROWDATE`, `DUEDATE`, `fine`

---

## ⚙️ Stored Procedures

###  `AddMember`
Adds a new member and returns their assigned ID.

###  `AddBook`
Adds a new book to the system.

###  `IssueBook`
Handles book issuing to a member, with membership and borrowing constraints.

###  `ReturnBook`
Handles the return of issued books and updates book status and fine if needed.

---

##  Triggers

###  `check_book_limit`
Prevents a member from borrowing more than the allowed number of books based on their membership type:
- **Monthly**: 2 books max
- **Yearly**: 200 books max

###  `calculate_fine`
Calculates a fine of ₹0.50 per day for overdue returns when `DUEDATE` is manually updated to an earlier date.

---

##  Relationships & Constraints

- Foreign key constraints ensure data integrity across:
  - `BOOK.AUTHORID` → `AUTHOR.AUTHOR_ID`
  - `BOOK.AUTHORID` → `PUBLISHER.CODE` *(Note: This constraint appears conflicting and may require schema clarification.)*
  - `TRANSACTION.MemberID` → `MEMBER.ID`
  - `MEMBER.TYPE` → `MEMBERSHIP.TYPE`

---

##  Sample Queries & Usage

### Add a member:
```sql
CALL AddMember('John', 'Mayor', 'Monthly', 24);
```

### Add a book:
```sql
CALL AddBook(7, 'Harry Potter', 2, 800, 1);
```

### Issue a book:
```sql
CALL IssueBook(5, 1);
```

### Return a book:
```sql
CALL ReturnBook(5, 1);
```

---

##  Notes

- Ensure foreign key constraints are added after table creation.
- Triggers are automatically invoked before `INSERT` or `UPDATE` on `TRANSACTION`.
- Data validation (e.g., member existence, book availability) is handled inside procedures.
- Status of books changes between `Available` and `Issued`.

---

##  Dependencies

- MySQL 8.0+
- Proper privileges for trigger and procedure creation

---

##  Setup Instructions

1. Clone the repository.
2. Import the SQL script into your MySQL server.
3. Run the procedures and triggers using the `CALL` commands above.

---

##  Files in this Repo
- `Library management system.sql` — Trigger definitions
- `README.md` — This file 📘

---



##  Authors

- Built by [SNEHAL YUTIKA, AIMAN] as part of a course project at [BIRLA INSTITUTE OF TECHNOLOGY AND SCIENCE, PILANI].

```

