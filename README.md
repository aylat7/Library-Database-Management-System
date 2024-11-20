# Library-Database-Management-System

A comprehensive library database for managing members, books, loans, and automated library operations, using PhpMyAdmin software for organization.

## Features

### 1. Member and Book Management
- Tracks member details such as name, email, status, and join date.
- Maintains a catalog of books, including support for multi-author books.

### 2. Loan Processing
- Handles book loans with details like loan date, due date, and return status.
- Automated checks for overdue items and borrowing limits.

### 3. Automation and Integrity
- Includes:
  - **Triggers**: Validates borrowing limits and ensures data integrity.
  - **Stored Procedures**: Simplifies loan creation.
  - **Scheduled Events**: Automatically updates the status of overdue loans.

### 4. Data Views
- Provides simplified views for:
  - Member loan details.
  - Book-author relationships with proper author attribution.

## Database Structure

### Tables
- **Members**: Tracks library members.
- **Membership Types**: Lookup table for membership details.
- **Books**: Stores book information.
- **Authors**: Tracks author details.
- **BookAuthors**: Junction table for books and their authors.
- **Loans**: Tracks book loans.

### Relationships
- One-to-Many: Members to Loans, Books to Loans.
- Many-to-Many: Books and Authors (via BookAuthors table).

## Automation
- **Triggers**: Prevents members from exceeding borrowing limits.
- **Stored Procedures**: Adds new loans efficiently.
- **Functions**: Checks if a member is eligible for borrowing.
- **Events**: Automatically updates overdue loans daily.

