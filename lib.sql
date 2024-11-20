-- Members table with auto-incrementing ID

CREATE TABLE members (
    member_ID INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    date_joined DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Active',
    INDEX idx_fullname (last_name, first_name)
);

-- MembershipTypes (lookup table)

CREATE TABLE memberType (
    type_ID CHAR(2) PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL UNIQUE,
    membership_duration INT NOT NULL,
    fee DECIMAL(10,2) NOT NULL
);

-- Books table with natural primary key (ISBN)

CREATE TABLE books (
    ISBN CHAR(13) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description LONGTEXT,
    pub_date DATE NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

-- Authors table

CREATE TABLE authors (
    author_ID INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    biography LONGTEXT NULL,
    date_added DATETIME DEFAULT CURRENT_TIMESTAMP
);



-- BookAuthors table with composite primary key

CREATE TABLE bookAuthors (
    ISBN CHAR(13),
    author_ID INT,
    author_order INT NOT NULL,
    PRIMARY KEY (ISBN, author_id),
    FOREIGN KEY (ISBN) REFERENCES books(ISBN) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (author_ID) REFERENCES authors(author_ID) ON DELETE RESTRICT
);

-- Loans table

CREATE TABLE loans (
    loan_ID INT AUTO_INCREMENT PRIMARY KEY,
    member_ID INT,
    ISBN CHAR(13),
    loan_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    due_date DATE NOT NULL,
    returned_date DATETIME NULL,
    FOREIGN KEY (member_ID) REFERENCES members(member_ID) ON DELETE RESTRICT,
    FOREIGN KEY (ISBN) REFERENCES books(ISBN) ON DELETE RESTRICT
);

-- Create view for member loans

CREATE VIEW vMemberLoans AS
SELECT 
    m.first_name,
    m.last_name,
    b.title,
    l.loan_date,
    l.due_date,
    l.returned_date
FROM members m
JOIN loans l ON m.member_ID = l.member_ID
JOIN books b ON l.ISBN = b.ISBN;


-- Create view for book authors

CREATE VIEW vBookAuthors AS
SELECT 
    b.ISBN,
    b.title,
    GROUP_CONCAT(a.name ORDER BY ba.author_order) AS authors
FROM books b
JOIN bookAuthors ba ON b.ISBN = ba.ISBN
JOIN authors a ON ba.author_ID = a.author_ID
GROUP BY b.ISBN, b.title;

-- Create procedure for new loan

DELIMITER //
CREATE PROCEDURE createLoan(
    IN p_member_ID INT,
    IN p_ISBN CHAR(13),
    IN p_durationDays INT
)
BEGIN
    INSERT INTO loans (member_ID, ISBN, due_date)
    VALUES (p_member_ID, p_ISBN, DATE_ADD(CURRENT_DATE, INTERVAL p_durationDays DAY));
END //
DELIMITER ;

-- Create function to check if member can borrow

DELIMITER //
CREATE FUNCTION canBorrow(p_member_ID INT) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE active_loans INT;
    SELECT COUNT(*) INTO active_loans 
    FROM Loans 
    WHERE MemberID = p_MemberID AND ReturnDate IS NULL;
    RETURN active_loans < 5;
END //
DELIMITER ;



-- Create trigger to validate loan

DELIMITER //
CREATE TRIGGER before_loan_insert
BEFORE INSERT ON loans
FOR EACH ROW
BEGIN
    IF NOT CanBorrow(NEW.member_ID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Member has reached maximum number of loans';
    END IF;
END //
DELIMITER ;

-- Create event to check overdue books

CREATE EVENT check_overdue_books
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP
DO
    UPDATE Loans 
    SET Status = 'Overdue'
    WHERE DueDate < CURRENT_DATE AND ReturnDate IS NULL;
