-- Create database if not exists
CREATE DATABASE IF NOT EXISTS 4050_test;

USE 4050_test;

-- Drop tables if they exist (for testing purposes)
DROP TABLE IF EXISTS Notifications;
DROP TABLE IF EXISTS ActivityLog;
DROP TABLE IF EXISTS Documents;
DROP TABLE IF EXISTS Comments;
DROP TABLE IF EXISTS Tasks;
DROP TABLE IF EXISTS Teams;
DROP TABLE IF EXISTS Projects;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Roles;

-- Create tables
CREATE TABLE Roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE Users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    role_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES Roles(role_id)
);

CREATE TABLE Projects (
    project_id INT PRIMARY KEY AUTO_INCREMENT,
    project_name VARCHAR(100) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    status VARCHAR(20),
    owner_id INT,
    percent_complete DECIMAL(5, 2),
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES Users(user_id),
    FOREIGN KEY (owner_id) REFERENCES Users(user_id)
);

CREATE TABLE Teams (
    team_id INT PRIMARY KEY AUTO_INCREMENT,
    team_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE Tasks (
    task_id INT PRIMARY KEY AUTO_INCREMENT,
    task_name VARCHAR(100) NOT NULL,
    description TEXT,
    owner_id INT,
    `rank` INT,
    priority VARCHAR(10),
    start_date DATE,
    end_date DATE,
    due_date DATE,
    status VARCHAR(20),
    percent_complete DECIMAL(5, 2),
    estimated_days INT,
    actual_days INT,
    next_task_id INT,
    project_id INT,
    assigned_to INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES Projects(project_id),
    FOREIGN KEY (assigned_to) REFERENCES Users(user_id),
    FOREIGN KEY (owner_id) REFERENCES Users(user_id),
    FOREIGN KEY (next_task_id) REFERENCES Tasks(task_id)
);

CREATE TABLE Comments (
    comment_id INT PRIMARY KEY AUTO_INCREMENT,
    comment_text TEXT NOT NULL,
    entity_type ENUM('task', 'project') NOT NULL,
    entity_id INT NOT NULL,
    task_id INT,
    user_id INT,
    project_id INT, 
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (task_id) REFERENCES Tasks(task_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

CREATE TABLE Documents (
    document_id INT PRIMARY KEY AUTO_INCREMENT,
    document_name VARCHAR(100) NOT NULL,
    document_path VARCHAR(255) NOT NULL,
    project_id INT,
    task_id INT NULL,
    uploaded_by INT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES Projects(project_id),
    FOREIGN KEY (task_id) REFERENCES Tasks(task_id),
    FOREIGN KEY (uploaded_by) REFERENCES Users(user_id)
);

CREATE TABLE ActivityLog (
    activity_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    activity_type VARCHAR(50),
    details TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

CREATE TABLE Notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Insert test data for Roles
INSERT INTO Roles (role_name, description) VALUES
('SysAdmin', 'System Administrator responsible for infrastructure'),
('Manager1', 'Manages a specific team or project'),
('Manager2', 'Manages another specific team or project'),
('User', 'Regular user with limited access');

-- Insert test data for Users
INSERT INTO Users (username, email, password, first_name, last_name, role_id) VALUES
('sysadmin1', 'sysadmin1@example.com', 'password123', 'Hank', 'SysAdmin', 1),
('sysadmin2', 'sysadmin2@example.com', 'password123', 'Sarah', 'SysAdmin', 1),
('manager1a', 'manager1a@example.com', 'password123', 'Frank', 'Manager1', 2),
('manager1b', 'manager1b@example.com', 'password123', 'Joel', 'Manager1', 2),
('manager1c', 'manager1c@example.com', 'password123', 'Sally', 'Manager1', 2),
('manager2a', 'manager2a@example.com', 'password123', 'Grace', 'Manager2', 3),
('manager2b', 'manager2b@example.com', 'password123', 'Manuel', 'Manager2', 3),
('user1', 'user1@example.com', 'password123', 'John', 'Doe', 4),
('user2', 'user2@example.com', 'password123', 'Jane', 'Smith', 4),
('user3', 'user3@example.com', 'password123', 'Bill', 'Williams', 4),
('user4', 'user4@example.com', 'password123', 'Mike', 'Johnson', 4),
('user5', 'user5@example.com', 'password123', 'Emily', 'Davis', 4),
('user6', 'user6@example.com', 'password123', 'Tom', 'Miller', 4),
('user7', 'user7@example.com', 'password123', 'Laura', 'Wilson', 4);

-- Insert test data for Projects
INSERT INTO Projects (project_name, description, start_date, end_date, status, owner_id, percent_complete, created_by) VALUES
('Infrastructure Overhaul', 'Upgrade company IT infrastructure', '2024-07-01', '2024-10-01', 'In Progress', 3, 75.0, 6),
('Mobile App Development', 'Develop a mobile application for e-commerce', '2024-10-01', '2025-03-01', 'Not Started', 3, 0.0, 6),
('Database Migration', 'Migrate legacy data to the new system', '2024-08-15', '2024-11-15', 'In Progress', 4, 50.0, 6),
('Website Redesign', 'Redesign the corporate website for better UX', '2024-07-15', '2024-10-30', 'In Progress', 4, 40.0, 7),
('ERP Implementation', 'Implement a new ERP system for the company', '2024-09-01', '2025-01-01', 'Not Started', 5, 0.0, 7),
('Cloud Migration', 'Migrate services to a cloud infrastructure', '2024-08-01', '2024-12-01', 'In Progress', 5, 60.0, 7),
('Cybersecurity Enhancement', 'Enhance company’s cybersecurity measures', '2024-07-01', '2024-12-01', 'In Progress', 5, 45.0, 7);

-- Insert test data for Teams
INSERT INTO Teams (team_name, description) VALUES
('Development Team', 'Handles all development tasks'),
('QA Team', 'Responsible for testing and quality assurance'),
('SysAdmin Team', 'Manages system infrastructure and network security'),
('Design Team', 'Handles UI/UX and graphic design tasks'),
('Operations Team', 'Responsible for daily operations and support'),
('Security Team', 'Handles security audits and measures');

-- Insert test data for Tasks
-- Project 1: Infrastructure Overhaul
INSERT INTO Tasks (task_name, description, owner_id, `rank`, priority, start_date, end_date, due_date, status, percent_complete, estimated_days, actual_days, next_task_id, project_id, assigned_to) VALUES
('Network Infrastructure Assessment', 'Assess the current state of network infrastructure', 3, 1, 'High', '2024-07-01', '2024-07-15', '2024-07-15', 'Completed', 100.0, 15, 15, NULL, 1, 8),
('Hardware Acquisition', 'Purchase new hardware for infrastructure upgrade', 3, 2, 'Medium', '2024-07-16', '2024-08-01', '2024-08-01', 'In Progress', 75.0, 16, 12, NULL, 1, 8),
('Firewall Configuration', 'Set up firewalls to secure the network', 3, 3, 'High', '2024-08-02', '2024-08-20', '2024-08-20', 'In Progress', 50.0, 18, 9, NULL, 1, 9),
('Server Installation', 'Install new servers for network support', 3, 4, 'High', '2024-08-21', '2024-09-10', '2024-09-10', 'Not Started', 0.0, 20, 0, NULL, 1, 9),
('Network Optimization', 'Optimize network for better performance', 3, 5, 'Medium', '2024-09-11', '2024-09-25', '2024-09-25', 'Not Started', 0.0, 14, 0, NULL, 1, 10),
('Network Testing', 'Test the new infrastructure setup', 3, 6, 'High', '2024-09-26', '2024-10-01', '2024-10-01', 'Not Started', 0.0, 5, 0, NULL, 1, 10);

-- Project 2: Mobile App Development
INSERT INTO Tasks (task_name, description, owner_id, `rank`, priority, start_date, end_date, due_date, status, percent_complete, estimated_days, actual_days, next_task_id, project_id, assigned_to) VALUES
('UI/UX Design', 'Design user interface for the mobile app', 3, 1, 'High', '2024-10-01', '2024-10-15', '2024-10-15', 'Completed', 100.0, 15, 15, NULL, 2, 11),
('Frontend Framework Setup', 'Setup frontend framework for the app', 3, 2, 'Medium', '2024-10-16', '2024-10-30', '2024-10-30', 'In Progress', 40.0, 14, 6, NULL, 2, 11),
('API Development', 'Develop API for backend functionality', 3, 3, 'High', '2024-10-31', '2024-11-15', '2024-11-15', 'Not Started', 0.0, 15, 0, NULL, 2, 12),
('Database Integration', 'Integrate the app with database', 3, 4, 'High', '2024-11-16', '2024-12-01', '2024-12-01', 'Not Started', 0.0, 15, 0, NULL, 2, 12),
('Mobile App Testing', 'Test the mobile application for bugs', 3, 5, 'Medium', '2024-12-02', '2025-01-15', '2025-01-15', 'Not Started', 0.0, 45, 0, NULL, 2, 13),
('Deployment Prep', 'Prepare app for app store deployment', 3, 6, 'Low', '2025-01-16', '2025-03-01', '2025-03-01', 'Not Started', 0.0, 45, 0, NULL, 2, 14);

-- Project 3: Database Migration
INSERT INTO Tasks (task_name, description, owner_id, `rank`, priority, start_date, end_date, due_date, status, percent_complete, estimated_days, actual_days, next_task_id, project_id, assigned_to) VALUES
('Data Cleanup', 'Clean and organize legacy data', 4, 1, 'High', '2024-08-15', '2024-09-01', '2024-09-01', 'Completed', 100.0, 15, 15, NULL, 3, 8),
('Schema Redesign', 'Redesign database schema', 4, 2, 'High', '2024-09-02', '2024-09-20', '2024-09-20', 'In Progress', 60.0, 18, 10, NULL, 3, 9),
('Data Transfer Preparation', 'Prepare data for migration', 4, 3, 'High', '2024-09-21', '2024-10-15', '2024-10-15', 'In Progress', 25.0, 24, 6, NULL, 3, 9),
('Data Transfer', 'Execute data transfer to new database', 4, 4, 'Medium', '2024-10-16', '2024-11-01', '2024-11-01', 'Not Started', 0.0, 16, 0, NULL, 3, 10),
('Database Testing', 'Test the integrity of transferred data', 4, 5, 'High', '2024-11-02', '2024-11-15', '2024-11-15', 'Not Started', 0.0, 13, 0, NULL, 3, 11);

-- Project 4: Website Redesign
INSERT INTO Tasks (task_name, description, owner_id, `rank`, priority, start_date, end_date, due_date, status, percent_complete, estimated_days, actual_days, next_task_id, project_id, assigned_to) VALUES
('User Research', 'Conduct user research for redesign', 4, 1, 'High', '2024-07-15', '2024-07-30', '2024-07-30', 'Completed', 100.0, 15, 15, NULL, 4, 11),
('Design Wireframes', 'Create initial wireframes', 4, 2, 'Medium', '2024-08-01', '2024-08-15', '2024-08-15', 'In Progress', 75.0, 14, 10, NULL, 4, 11),
('Prototype Development', 'Develop website prototype', 4, 3, 'High', '2024-08-16', '2024-09-01', '2024-09-01', 'In Progress', 50.0, 16, 8, NULL, 4, 12),
('Content Strategy', 'Create a strategy for website content', 4, 4, 'Low', '2024-09-02', '2024-09-20', '2024-09-20', 'Not Started', 0.0, 18, 0, NULL, 4, 13),
('SEO and Optimization', 'Optimize for search engines', 4, 5, 'Medium', '2024-09-21', '2024-10-15', '2024-10-15', 'Not Started', 0.0, 24, 0, NULL, 4, 14);

-- Project 5: ERP Implementation
INSERT INTO Tasks (task_name, description, owner_id, `rank`, priority, start_date, end_date, due_date, status, percent_complete, estimated_days, actual_days, next_task_id, project_id, assigned_to) VALUES
('Requirements Gathering', 'Gather ERP requirements', 5, 1, 'High', '2024-09-01', '2024-09-10', '2024-09-10', 'Completed', 100.0, 9, 9, NULL, 5, 8),
('Vendor Selection', 'Select ERP vendor', 5, 2, 'Medium', '2024-09-11', '2024-09-20', '2024-09-20', 'In Progress', 40.0, 9, 4, NULL, 5, 8),
('System Configuration', 'Configure ERP system', 5, 3, 'High', '2024-09-21', '2024-10-15', '2024-10-15', 'Not Started', 0.0, 24, 0, NULL, 5, 9),
('Data Migration to ERP', 'Migrate data to ERP', 5, 4, 'High', '2024-10-16', '2024-11-10', '2024-11-10', 'Not Started', 0.0, 25, 0, NULL, 5, 10),
('Training and Support', 'Provide training on ERP usage', 5, 5, 'Medium', '2024-11-11', '2025-01-01', '2025-01-01', 'Not Started', 0.0, 50, 0, NULL, 5, 10);

-- Project 6: Cloud Migration
INSERT INTO Tasks (task_name, description, owner_id, `rank`, priority, start_date, end_date, due_date, status, percent_complete, estimated_days, actual_days, next_task_id, project_id, assigned_to) VALUES
('Service Assessment', 'Identify services to migrate to cloud', 5, 1, 'High', '2024-08-01', '2024-08-15', '2024-08-15', 'Completed', 100.0, 14, 14, NULL, 6, 12),
('Cloud Provider Selection', 'Select cloud provider for migration', 5, 2, 'Medium', '2024-08-16', '2024-08-31', '2024-08-31', 'In Progress', 50.0, 15, 8, NULL, 6, 12),
('Data Migration to Cloud', 'Migrate data to cloud storage', 5, 3, 'High', '2024-09-01', '2024-10-15', '2024-10-15', 'Not Started', 0.0, 44, 0, NULL, 6, 13),
('Security Configuration', 'Set up security protocols on cloud', 5, 4, 'High', '2024-10-16', '2024-11-15', '2024-11-15', 'Not Started', 0.0, 30, 0, NULL, 6, 14),
('Testing and Validation', 'Ensure all systems function in cloud', 5, 5, 'Medium', '2024-11-16', '2024-12-01', '2024-12-01', 'Not Started', 0.0, 15, 0, NULL, 6, 8);

-- Project 7: Cybersecurity Enhancement
INSERT INTO Tasks (task_name, description, owner_id, `rank`, priority, start_date, end_date, due_date, status, percent_complete, estimated_days, actual_days, next_task_id, project_id, assigned_to) VALUES
('Vulnerability Assessment', 'Identify security vulnerabilities', 5, 1, 'High', '2024-07-01', '2024-07-15', '2024-07-15', 'Completed', 100.0, 14, 14, NULL, 7, 9),
('Firewall Upgrades', 'Upgrade firewalls for better security', 5, 2, 'Medium', '2024-07-16', '2024-07-30', '2024-07-30', 'In Progress', 50.0, 14, 7, NULL, 7, 9),
('Intrusion Detection System', 'Implement IDS for threat detection', 5, 3, 'High', '2024-08-01', '2024-08-31', '2024-08-31', 'Not Started', 0.0, 30, 0, NULL, 7, 10),
('Employee Training', 'Train employees on security protocols', 5, 4, 'Medium', '2024-09-01', '2024-09-15', '2024-09-15', 'Not Started', 0.0, 14, 0, NULL, 7, 11),
('Regular Security Audits', 'Schedule regular audits', 5, 5, 'Low', '2024-09-16', '2024-12-01', '2024-12-01', 'Not Started', 0.0, 75, 0, NULL, 7, 12);




-- Insert test data for Comments
INSERT INTO Comments (comment_text, task_id, user_id, entity_type, entity_id) VALUES
('Initial network upgrade is complete and performing well.', 1, 1, 'task', 1),
('Found some security gaps during the audit, will address them next.', 2, 1, 'task', 2),
('Backend API structure is finalized, development is ready to start.', 3, 2, 'task', 3),
('UI design is complete and awaiting review.', 7, 5, 'task', 7),
('SEO optimization is yielding positive results so far.', 8, 2, 'task', 8),
('Firewall installation was completed ahead of schedule.', 11, 1, 'task', 11),
('Penetration testing is scheduled to begin next week.', 12, 4, 'task', 12);

-- Insert test data for Documents
INSERT INTO Documents (document_name, document_path, project_id, task_id, uploaded_by) VALUES
('Network Diagram', '/documents/network_diagram.pdf', 1, 1, 1),
('Security Audit Report', '/documents/security_audit_report.pdf', 1, 2, 1),
('Backend API Documentation', '/documents/backend_api_docs.pdf', 2, 3, 2),
('UI Mockup', '/documents/ui_mockup.pdf', 5, 7, 5),
('Firewall Configuration Guide', '/documents/firewall_config_guide.pdf', 7, 11, 1);

-- Insert test data for ActivityLog
INSERT INTO ActivityLog (user_id, activity_type, details) VALUES
(1, 'Login', 'SysAdmin logged in successfully.'),
(2, 'Task Update', 'Updated Backend Development task progress.'),
(3, 'Project Status Update', 'Updated the status of the Database Migration project.'),
(4, 'Task Comment', 'Added comment to Penetration Testing task.'),
(5, 'Document Upload', 'Uploaded UI Mockup to Website Redesign project.');

