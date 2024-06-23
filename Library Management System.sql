use bits_library;

--making employee
select * from employee;
CREATE TABLE EMPLOYEE (
  ID INTEGER PRIMARY KEY,
  NAME varchar(65) NOT NULL,
  DOB DATE NOT NULL,
  PHNO CHAR(10) UNIQUE NOT NULL,
  AGE INTEGER NOT NULL
);
 
--inserting sample values in employee
INSERT INTO EMPLOYEE VALUES (1, 'John Smith', '1990-05-15', '1234567890', 31);
INSERT INTO EMPLOYEE VALUES (2, 'Jane Doe', '1985-09-20', '2345678901', 36);
INSERT INTO EMPLOYEE VALUES (3, 'Michael Johnson', '1988-11-25', '3456789012', 33);
INSERT INTO EMPLOYEE VALUES (4, 'Emily Brown', '1995-03-10', '4567890123', 27);
INSERT INTO EMPLOYEE VALUES (5, 'Daniel Wilson', '1992-07-08', '5678901234', 29);

--making admin
create table ADMIN(
	ID INTEGER PRIMARY KEY,
    NAME varchar(65) NOT NULL,
    PHNO CHAR(10) UNIQUE NOT NULL
);

--inserting sample values in admin
INSERT INTO ADMIN VALUES (1, 'Admin1', '9876543210');
INSERT INTO ADMIN VALUES (2, 'Admin2', '8765432109');
INSERT INTO ADMIN VALUES (3, 'Admin3', '7654321098');
INSERT INTO ADMIN VALUES (4, 'Admin4', '6543210987');
INSERT INTO ADMIN VALUES (5, 'Admin5', '5432109876');

--making member
CREATE TABLE MEMBER (
    ID INT NOT NULL AUTO_INCREMENT,
    FIRSTNAME VARCHAR(65),
    LASTNAME VARCHAR(65),
    PHNO VARCHAR(10),
    AGE INT,
    TYPE VARCHAR(65),
    PRIMARY KEY (ID)
);

--inserting sample values in member
INSERT INTO MEMBER (ID, FIRSTNAME, LASTNAME, PHNO, AGE, TYPE) VALUES
(1, 'John' ,'Doe', '1234567890', 30, 'Yearly'),
(2, 'Jane','Smith', '0987654321', 25, 'Monthly');

--making membership
select * from member;
CREATE TABLE MEMBERSHIP (
    TYPE VARCHAR(65),
    PRICE INT NOT NULL,
    PRIMARY KEY (TYPE)
);
--inserting sample values in membership
INSERT INTO MEMBERSHIP VALUES ('Yearly', 1500);
INSERT INTO MEMBERSHIP VALUES ('Monthly',150);


--making library
CREATE TABLE LIBRARY (
    NAME VARCHAR(65) PRIMARY KEY,
    PHNO CHAR(10) UNIQUE NOT NULL,
    CITY VARCHAR(65) NOT NULL,
    STATE VARCHAR(65) NOT NULL,
    PINCODE INT NOT NULL
);
INSERT INTO LIBRARY VALUES ('Central Library', '8530680326', 'Hyderabad', 'Telangana', 50001);

--making author
CREATE TABLE AUTHOR (
    AUTHOR_ID INTEGER PRIMARY KEY,
    NAME VARCHAR(65) NOT NULL
);
--inserting sample values in author
INSERT INTO AUTHOR VALUES (1, 'Jane Austen');
INSERT INTO AUTHOR VALUES (2, 'J.K. Rowling');
INSERT INTO AUTHOR VALUES (3, 'Agatha Christie');
INSERT INTO AUTHOR VALUES (4, 'R.L. Stine');
INSERT INTO AUTHOR VALUES (5, 'Ruskin Bond');

--making book
CREATE TABLE BOOK (
    BOOKID INTEGER PRIMARY KEY,
    AUTHORID INTEGER NOT NULL,
    NAME VARCHAR(65) NOT NULL,
    PRICE INTEGER NOT NULL,
    RACK_NO INTEGER NOT NULL,
    SHELF_NO INTEGER NOT NULL,
    STATUS VARCHAR(65) NOT NULL
);
--inserting sample values in book
INSERT INTO BOOK (BOOKID, AUTHORID, NAME, PRICE, RACK_NO, SHELF_NO, STATUS) VALUES
(1, 1, 'Book 1', 20, 1, 1, 'Available'),
(2, 2, 'Book 2', 25, 2, 2, 'Available'),
(3, 3, 'Book 3', 30, 3, 3, 'Available'),
(4, 4, 'Book 4', 35, 4, 4, 'Available'),
(5, 5, 'Book 5', 40, 5, 5, 'Available');
select * from book;


--making publisher
CREATE TABLE PUBLISHER (
    CODE INTEGER PRIMARY KEY,
    NAME VARCHAR(65) NOT NULL,
    COUNTRY VARCHAR(65) NOT NULL
);
--inserting sample values in publisher
INSERT INTO PUBLISHER (CODE, NAME, COUNTRY) VALUES
(1, 'Publisher A', 'Country A'),
(2, 'Publisher B', 'Country B'),
(3, 'Publisher C', 'Country C'),
(4, 'Publisher D', 'Country D'),
(5, 'Publisher E', 'Country E');



--making transaction
CREATE TABLE TRANSACTION (
    TransactionID INTEGER PRIMARY KEY AUTO_INCREMENT,
    MemberID INTEGER,
    BookID INTEGER,
    BORROWDATE DATE NOT NULL,
    DUEDATE DATE NOT NULL,
     fine DECIMAL(10, 2), 
    FOREIGN KEY (MemberID) REFERENCES MEMBER(ID),
    FOREIGN KEY (BookID) REFERENCES BOOK(BOOKID)
);


DELIMITER //

DELIMITER //
CREATE PROCEDURE IssueBook(IN book_id INT, IN mem_id INT)
BEGIN
    DECLARE book_exists INT;
    DECLARE member_exists INT;
    DECLARE book_issued INT;
    DECLARE member_type VARCHAR(65);
    DECLARE expiry_date DATE;
    DECLARE due_date DATE;

    -- Check if the book exists
    SELECT COUNT(*) INTO book_exists FROM BOOK WHERE BOOKID = book_id;
    IF book_exists = 0 THEN
        SELECT 'The book does not exist in the library' AS Message;
    END IF;

    -- Check if the member exists
    SELECT COUNT(*) INTO member_exists FROM MEMBER WHERE ID = mem_id;
    IF member_exists = 0 THEN
        SELECT 'The user is not a member of the club' AS Message;
    END IF;

    -- Check if the member has already borrowed the book and not returned
    SELECT COUNT(*) INTO book_issued FROM TRANSACTION 
    WHERE MemberID = mem_id AND DUEDATE IS NULL;
    IF book_issued > 0 THEN
        SELECT 'The user already has this book' AS Message;
    END IF;

    -- Check if the due date is crossing the expiry date of the member
    SELECT TYPE INTO member_type FROM MEMBER WHERE ID = mem_id;
    SET expiry_date = DATE_ADD(CURDATE(), INTERVAL 1 MONTH);
    SET due_date = DATE_ADD(CURDATE(), INTERVAL 7 DAY);

    IF member_type = 'Monthly' AND expiry_date < due_date THEN
        SELECT CONCAT('Your membership expiry date ', expiry_date, 
        ' is before due date ', due_date) AS Message;
    ELSEIF member_type = 'Yearly' AND DATE_ADD(CURDATE(), INTERVAL 1 YEAR) < due_date THEN
        SELECT CONCAT('Your membership expiry date ', DATE_ADD(CURDATE(), INTERVAL 1 YEAR), 
        ' is before due date ', due_date) AS Message;
    ELSEIF member_type = 'Lifetime' THEN
        SELECT 'You have lifetime membership' AS Message;
    ELSE
        -- If all checks pass, issue the book
        INSERT INTO TRANSACTION (MemberID, BookID, BORROWDATE, DUEDATE) 
        VALUES (mem_id, book_id, CURDATE(), due_date);
        UPDATE BOOK SET STATUS = 'Issued' WHERE BOOKID = book_id;
        SELECT 'Book issued successfully' AS Message;
        
        CALL check_book_limit;
    END IF;
END//
DELIMITER ;


DELIMITER //

DELIMITER //
DROP PROCEDURE IF EXISTS AddMember //
CREATE PROCEDURE AddMember(
    IN member_firstname VARCHAR(65),
    IN member_lastname VARCHAR(65),
    IN member_type VARCHAR(65),
    IN age INT 
)
BEGIN
    -- Insert the new member
    INSERT INTO MEMBER (FIRSTNAME, LASTNAME, PHNO, AGE, TYPE) 
    VALUES (member_firstname, member_lastname, '', age, member_type);
    
    -- Get the ID of the inserted member
    SELECT LAST_INSERT_ID() INTO @id;
    
    -- Display message to the user
    SELECT CONCAT('Mr/Mrs/Miss. ', member_firstname, ' ', member_lastname, ', your membership id is ', @id) AS message;
END //



select * from member;

DELIMITER //

DROP PROCEDURE IF EXISTS AddBook //

CREATE PROCEDURE AddBook(
    IN book_id INT,
    IN book_name VARCHAR(65),
    IN author_id INT,
    IN price INT,
    IN no_of_books INT
)
BEGIN
    -- Insert the new book
    INSERT INTO BOOK (BOOKID, NAME, AUTHORID, PRICE, RACK_NO, SHELF_NO, STATUS) 
    VALUES (book_id, book_name, author_id, price, 0, 0, 'Available');
    
    -- Display message to the user
    SELECT CONCAT('Book ', book_name, ' added successfully with ID ', book_id) AS message;
END //

DELIMITER ;

DELIMITER //

DROP PROCEDURE IF EXISTS ReturnBook //


DELIMITER //


DELIMITER //
DELIMITER //
CREATE PROCEDURE ReturnBook(IN book_id INT, IN mem_id INT)
BEGIN
    DECLARE book_exists INT;
    DECLARE member_exists INT;
    DECLARE book_borrowed INT;

    -- Check if the book exists
    SELECT COUNT(*) INTO book_exists FROM BOOK WHERE BOOKID = book_id;
    IF book_exists = 0 THEN
        SELECT 'The book does not exist in the library' AS Message;
    END IF;

    -- Check if the member exists
    SELECT COUNT(*) INTO member_exists FROM MEMBER WHERE ID = mem_id;
    IF member_exists = 0 THEN
        SELECT 'The user is not a member of the club' AS Message;
    END IF;

    -- Check if the book is borrowed by the member
    SELECT COUNT(*) INTO book_borrowed FROM TRANSACTION 
    WHERE MemberID = mem_id AND BookID = book_id AND DUEDATE IS NOT NULL;
    IF book_borrowed = 0 THEN
        SELECT 'The user has not borrowed this book' AS Message;
    END IF;

    -- If all checks pass, mark the book as returned
    UPDATE BOOK SET STATUS = 'Available' WHERE BOOKID = book_id;
    UPDATE TRANSACTION SET DUEDATE = CURDATE()
    WHERE MemberID = mem_id AND BookID = book_id AND DUEDATE IS NOT NULL;
    
    SELECT 'Book returned successfully' AS Message;
END//
DELIMITER ;





drop table transaction;



-- 1. Add foreign key constraint for AUTHORID in BOOK table
ALTER TABLE BOOK
ADD CONSTRAINT FK_AUTHOR
FOREIGN KEY (AUTHORID) REFERENCES AUTHOR(AUTHOR_ID);

-- 2. Add foreign key constraint for PUBLISHERCODE in BOOK table
ALTER TABLE BOOK
ADD CONSTRAINT FK_PUBLISHER
FOREIGN KEY (AUTHORID) REFERENCES PUBLISHER(CODE);
-- 3. Add foreign key constraint for MEMBER_ID in TRANSACTION table
ALTER TABLE TRANSACTION
ADD CONSTRAINT FK_MEMBER_ID
FOREIGN KEY (MemberID) REFERENCES MEMBER(ID);

-- 4. Add foreign key constraint for MEMBERTYPE in MEMBER table
ALTER TABLE MEMBER
ADD CONSTRAINT FK_MEMBERSHIP
FOREIGN KEY (TYPE) REFERENCES MEMBERSHIP(TYPE);

call AddMember('John', 'Mayor', 'Monthly', 24);
call AddMember('James', 'Adama', 'Monthly', 24);
drop trigger bits_library.check_book_limit;
DELIMITER //



CREATE TRIGGER check_book_limit
BEFORE INSERT ON TRANSACTION
FOR EACH ROW
BEGIN
    DECLARE current_books INT;
    DECLARE max_books INT;

    -- Get the current number of books borrowed by the user
    SELECT COUNT(*) INTO current_books
    FROM TRANSACTION
    WHERE MemberID = NEW.MemberID;

    -- Get the maximum number of books allowed to borrow based on membership type
    IF (SELECT TYPE FROM MEMBER WHERE ID = NEW.MemberID) = 'Monthly' THEN
        SET max_books = 2;
    ELSEIF (SELECT TYPE FROM MEMBER WHERE ID = NEW.MemberID) = 'Yearly' THEN
        SET max_books = 200;
    ELSE
        SET max_books = 0; -- Default maximum books to 0 for unknown membership types
    END IF;

    -- Check if the user has reached the maximum book limit
    IF current_books >= max_books THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User has reached the maximum book limit allowed.';
    END IF;
END;
//


DELIMITER ;



DELIMITER //

CREATE TRIGGER calculate_fine
BEFORE UPDATE ON `TRANSACTION`
FOR EACH ROW
BEGIN
    DECLARE late_days INT;
    DECLARE fine DECIMAL(10, 2);
    
    -- If the due date is updated and it's past the original due date, calculate the fine
    IF NEW.DUEDATE <> OLD.DUEDATE AND NEW.DUEDATE < OLD.DUEDATE THEN
        
        SET late_days = DATEDIFF(OLD.DUEDATE, NEW.DUEDATE);
        SET fine = late_days * 0.50; -- Adjust the fine rate as needed
        
        -- Update the fine directly in the transaction being updated
        SET NEW.fine = fine;
    END IF;
END;
//

DELIMITER ;



select * from book;
select * from member;
select * from transaction;


call Addmember('Jane','Smith','Monthly',25);
call Addmember('James','Smith','Monthly',25);

call AddBook(7,'Harry Potter',2,800,1);

call Returnbook(5,1);
call Issuebook(5,1);
call Returnbook(3,1);
call Issuebook (5,1);


UPDATE TRANSACTION
SET BORROWDATE = '2024-04-18',
    DUEDATE = '2024-04-19'
WHERE TransactionID = 1;


show triggers where 'Trigger' = 'check_book_limit';
SET GLOBAL triggers.check_book_limit = ON;



