CREATE DATABASE  IF NOT EXISTS `4050_test` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `4050_test`;
-- MySQL dump 10.13  Distrib 8.0.38, for Win64 (x86_64)
--
-- Host: localhost    Database: 4050_test
-- ------------------------------------------------------
-- Server version	8.0.39

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `activitylog`
--

DROP TABLE IF EXISTS `activitylog`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activitylog` (
  `activity_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `activity_type` varchar(50) DEFAULT NULL,
  `details` text,
  `timestamp` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`activity_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `activitylog_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activitylog`
--

LOCK TABLES `activitylog` WRITE;
/*!40000 ALTER TABLE `activitylog` DISABLE KEYS */;
INSERT INTO `activitylog` VALUES (1,1,'Login','SysAdmin logged in successfully.','2024-11-04 23:33:22'),(2,2,'Task Update','Updated Backend Development task progress.','2024-11-04 23:33:22'),(3,3,'Project Status Update','Updated the status of the Database Migration project.','2024-11-04 23:33:22'),(4,4,'Task Comment','Added comment to Penetration Testing task.','2024-11-04 23:33:22'),(5,5,'Document Upload','Uploaded UI Mockup to Website Redesign project.','2024-11-04 23:33:22');
/*!40000 ALTER TABLE `activitylog` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comments` (
  `comment_id` int NOT NULL AUTO_INCREMENT,
  `comment_text` text NOT NULL,
  `entity_type` enum('task','project') NOT NULL,
  `entity_id` int NOT NULL,
  `task_id` int DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `project_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`comment_id`),
  KEY `task_id` (`task_id`),
  KEY `user_id` (`user_id`),
  KEY `project_id` (`project_id`),
  CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`task_id`),
  CONSTRAINT `comments_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `comments_ibfk_3` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comments`
--

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
INSERT INTO `comments` VALUES (1,'Initial network upgrade is complete and performing well.','task',1,1,1,NULL,'2024-11-04 23:33:22'),(2,'Found some security gaps during the audit, will address them next.','task',2,2,1,NULL,'2024-11-04 23:33:22'),(3,'Backend API structure is finalized, development is ready to start.','task',3,3,2,NULL,'2024-11-04 23:33:22'),(4,'UI design is complete and awaiting review.','task',7,7,5,NULL,'2024-11-04 23:33:22'),(5,'SEO optimization is yielding positive results so far.','task',8,8,2,NULL,'2024-11-04 23:33:22'),(6,'Firewall installation was completed ahead of schedule.','task',11,11,1,NULL,'2024-11-04 23:33:22'),(7,'Penetration testing is scheduled to begin next week.','task',12,12,4,NULL,'2024-11-04 23:33:22'),(8,'Test','project',8,NULL,8,NULL,'2024-11-04 23:35:21'),(9,'Test again','project',8,NULL,6,NULL,'2024-11-04 23:37:27'),(10,'Test 3','project',8,NULL,3,NULL,'2024-11-04 23:39:34');
/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents`
--

DROP TABLE IF EXISTS `documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `documents` (
  `document_id` int NOT NULL AUTO_INCREMENT,
  `document_name` varchar(100) NOT NULL,
  `document_path` varchar(255) NOT NULL,
  `project_id` int DEFAULT NULL,
  `task_id` int DEFAULT NULL,
  `uploaded_by` int DEFAULT NULL,
  `uploaded_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`document_id`),
  KEY `project_id` (`project_id`),
  KEY `task_id` (`task_id`),
  KEY `uploaded_by` (`uploaded_by`),
  CONSTRAINT `documents_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`),
  CONSTRAINT `documents_ibfk_2` FOREIGN KEY (`task_id`) REFERENCES `tasks` (`task_id`),
  CONSTRAINT `documents_ibfk_3` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents`
--

LOCK TABLES `documents` WRITE;
/*!40000 ALTER TABLE `documents` DISABLE KEYS */;
INSERT INTO `documents` VALUES (1,'Network Diagram','/documents/network_diagram.pdf',1,1,1,'2024-11-04 23:33:22'),(2,'Security Audit Report','/documents/security_audit_report.pdf',1,2,1,'2024-11-04 23:33:22'),(3,'Backend API Documentation','/documents/backend_api_docs.pdf',2,3,2,'2024-11-04 23:33:22'),(4,'UI Mockup','/documents/ui_mockup.pdf',5,7,5,'2024-11-04 23:33:22'),(5,'Firewall Configuration Guide','/documents/firewall_config_guide.pdf',7,11,1,'2024-11-04 23:33:22');
/*!40000 ALTER TABLE `documents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `notification_id` int NOT NULL AUTO_INCREMENT,
  `user_id` int DEFAULT NULL,
  `message` text,
  `is_read` tinyint(1) DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`notification_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `projects` (
  `project_id` int NOT NULL AUTO_INCREMENT,
  `project_name` varchar(100) NOT NULL,
  `description` text,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `owner_id` int DEFAULT NULL,
  `percent_complete` decimal(5,2) DEFAULT NULL,
  `created_by` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`project_id`),
  KEY `created_by` (`created_by`),
  KEY `owner_id` (`owner_id`),
  CONSTRAINT `projects_ibfk_1` FOREIGN KEY (`created_by`) REFERENCES `users` (`user_id`),
  CONSTRAINT `projects_ibfk_2` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `projects`
--

LOCK TABLES `projects` WRITE;
/*!40000 ALTER TABLE `projects` DISABLE KEYS */;
INSERT INTO `projects` VALUES (1,'Infrastructure Overhaul','Upgrade company IT infrastructure','2024-07-01','2024-10-01','In Progress',3,75.00,6,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(2,'Mobile App Development','Develop a mobile application for e-commerce','2024-10-01','2025-03-01','Not Started',3,0.00,6,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(3,'Database Migration','Migrate legacy data to the new system','2024-08-15','2024-11-15','In Progress',4,50.00,6,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(4,'Website Redesign','Redesign the corporate website for better UX','2024-07-15','2024-10-30','In Progress',4,40.00,7,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(5,'ERP Implementation','Implement a new ERP system for the company','2024-09-01','2025-01-01','Not Started',5,0.00,7,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(6,'Cloud Migration','Migrate services to a cloud infrastructure','2024-08-01','2024-12-01','In Progress',5,60.00,7,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(7,'Cybersecurity Enhancement','Enhance company’s cybersecurity measures','2024-07-01','2024-12-01','In Progress',5,45.00,7,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(8,'Test',NULL,'2024-11-15','2024-11-29','Not Started',3,0.00,6,'2024-11-04 23:34:21','2024-11-04 23:34:21'),(9,'Test2',NULL,'2024-11-15','2024-11-29','Not Started',3,0.00,6,'2024-11-05 05:08:54','2024-11-05 05:08:54');
/*!40000 ALTER TABLE `projects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `role_id` int NOT NULL AUTO_INCREMENT,
  `role_name` varchar(50) NOT NULL,
  `description` text,
  PRIMARY KEY (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'SysAdmin','System Administrator responsible for infrastructure'),(2,'Manager1','Manages a specific team or project'),(3,'Manager2','Manages another specific team or project'),(4,'User','Regular user with limited access');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tasks`
--

DROP TABLE IF EXISTS `tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tasks` (
  `task_id` int NOT NULL AUTO_INCREMENT,
  `task_name` varchar(100) NOT NULL,
  `description` text,
  `owner_id` int DEFAULT NULL,
  `rank` int DEFAULT NULL,
  `priority` varchar(10) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `percent_complete` decimal(5,2) DEFAULT NULL,
  `estimated_days` int DEFAULT NULL,
  `actual_days` int DEFAULT NULL,
  `next_task_id` int DEFAULT NULL,
  `project_id` int DEFAULT NULL,
  `assigned_to` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`task_id`),
  KEY `project_id` (`project_id`),
  KEY `assigned_to` (`assigned_to`),
  KEY `owner_id` (`owner_id`),
  KEY `next_task_id` (`next_task_id`),
  CONSTRAINT `tasks_ibfk_1` FOREIGN KEY (`project_id`) REFERENCES `projects` (`project_id`),
  CONSTRAINT `tasks_ibfk_2` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`user_id`),
  CONSTRAINT `tasks_ibfk_3` FOREIGN KEY (`owner_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `tasks_ibfk_4` FOREIGN KEY (`next_task_id`) REFERENCES `tasks` (`task_id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tasks`
--

LOCK TABLES `tasks` WRITE;
/*!40000 ALTER TABLE `tasks` DISABLE KEYS */;
INSERT INTO `tasks` VALUES (1,'Network Infrastructure Assessment','Assess the current state of network infrastructure',3,1,'High','2024-07-01','2024-07-15','2024-07-15','Completed',100.00,15,15,NULL,1,8,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(2,'Hardware Acquisition','Purchase new hardware for infrastructure upgrade',3,2,'Medium','2024-07-16','2024-08-01','2024-08-01','In Progress',75.00,16,12,NULL,1,8,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(3,'Firewall Configuration','Set up firewalls to secure the network',3,3,'High','2024-08-02','2024-08-20','2024-08-20','In Progress',50.00,18,9,NULL,1,9,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(4,'Server Installation','Install new servers for network support',3,4,'High','2024-08-21','2024-09-10','2024-09-10','Not Started',0.00,20,0,NULL,1,9,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(5,'Network Optimization','Optimize network for better performance',3,5,'Medium','2024-09-11','2024-09-25','2024-09-25','Not Started',0.00,14,0,NULL,1,10,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(6,'Network Testing','Test the new infrastructure setup',3,6,'High','2024-09-26','2024-10-01','2024-10-01','Not Started',0.00,5,0,NULL,1,10,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(7,'UI/UX Design','Design user interface for the mobile app',3,1,'High','2024-10-01','2024-10-15','2024-10-15','Completed',100.00,15,15,NULL,2,11,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(8,'Frontend Framework Setup','Setup frontend framework for the app',3,2,'Medium','2024-10-16','2024-10-30','2024-10-30','In Progress',40.00,14,6,NULL,2,11,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(9,'API Development','Develop API for backend functionality',3,3,'High','2024-10-31','2024-11-15','2024-11-15','Not Started',0.00,15,0,NULL,2,12,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(10,'Database Integration','Integrate the app with database',3,4,'High','2024-11-16','2024-12-01','2024-12-01','Not Started',0.00,15,0,NULL,2,12,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(11,'Mobile App Testing','Test the mobile application for bugs',3,5,'Medium','2024-12-02','2025-01-15','2025-01-15','Not Started',0.00,45,0,NULL,2,13,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(12,'Deployment Prep','Prepare app for app store deployment',3,6,'Low','2025-01-16','2025-03-01','2025-03-01','Not Started',0.00,45,0,NULL,2,14,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(13,'Data Cleanup','Clean and organize legacy data',4,1,'High','2024-08-15','2024-09-01','2024-09-01','Completed',100.00,15,15,NULL,3,8,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(14,'Schema Redesign','Redesign database schema',4,2,'High','2024-09-02','2024-09-20','2024-09-20','In Progress',60.00,18,10,NULL,3,9,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(15,'Data Transfer Preparation','Prepare data for migration',4,3,'High','2024-09-21','2024-10-15','2024-10-15','In Progress',25.00,24,6,NULL,3,9,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(16,'Data Transfer','Execute data transfer to new database',4,4,'Medium','2024-10-16','2024-11-01','2024-11-01','Not Started',0.00,16,0,NULL,3,10,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(17,'Database Testing','Test the integrity of transferred data',4,5,'High','2024-11-02','2024-11-15','2024-11-15','Not Started',0.00,13,0,NULL,3,11,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(18,'User Research','Conduct user research for redesign',4,1,'High','2024-07-15','2024-07-30','2024-07-30','Completed',100.00,15,15,NULL,4,11,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(19,'Design Wireframes','Create initial wireframes',4,2,'Medium','2024-08-01','2024-08-15','2024-08-15','In Progress',75.00,14,10,NULL,4,11,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(20,'Prototype Development','Develop website prototype',4,3,'High','2024-08-16','2024-09-01','2024-09-01','In Progress',50.00,16,8,NULL,4,12,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(21,'Content Strategy','Create a strategy for website content',4,4,'Low','2024-09-02','2024-09-20','2024-09-20','Not Started',0.00,18,0,NULL,4,13,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(22,'SEO and Optimization','Optimize for search engines',4,5,'Medium','2024-09-21','2024-10-15','2024-10-15','Not Started',0.00,24,0,NULL,4,14,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(23,'Requirements Gathering','Gather ERP requirements',5,1,'High','2024-09-01','2024-09-10','2024-09-10','Completed',100.00,9,9,NULL,5,8,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(24,'Vendor Selection','Select ERP vendor',5,2,'Medium','2024-09-11','2024-09-20','2024-09-20','In Progress',40.00,9,4,NULL,5,8,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(25,'System Configuration','Configure ERP system',5,3,'High','2024-09-21','2024-10-15','2024-10-15','Not Started',0.00,24,0,NULL,5,9,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(26,'Data Migration to ERP','Migrate data to ERP',5,4,'High','2024-10-16','2024-11-10','2024-11-10','Not Started',0.00,25,0,NULL,5,10,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(27,'Training and Support','Provide training on ERP usage',5,5,'Medium','2024-11-11','2025-01-01','2025-01-01','Not Started',0.00,50,0,NULL,5,10,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(28,'Service Assessment','Identify services to migrate to cloud',5,1,'High','2024-08-01','2024-08-15','2024-08-15','Completed',100.00,14,14,NULL,6,12,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(29,'Cloud Provider Selection','Select cloud provider for migration',5,2,'Medium','2024-08-16','2024-08-31','2024-08-31','In Progress',50.00,15,8,NULL,6,12,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(30,'Data Migration to Cloud','Migrate data to cloud storage',5,3,'High','2024-09-01','2024-10-15','2024-10-15','Not Started',0.00,44,0,NULL,6,13,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(31,'Security Configuration','Set up security protocols on cloud',5,4,'High','2024-10-16','2024-11-15','2024-11-15','Not Started',0.00,30,0,NULL,6,14,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(32,'Testing and Validation','Ensure all systems function in cloud',5,5,'Medium','2024-11-16','2024-12-01','2024-12-01','Not Started',0.00,15,0,NULL,6,8,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(33,'Vulnerability Assessment','Identify security vulnerabilities',5,1,'High','2024-07-01','2024-07-15','2024-07-15','Completed',100.00,14,14,NULL,7,9,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(34,'Firewall Upgrades','Upgrade firewalls for better security',5,2,'Medium','2024-07-16','2024-07-30','2024-07-30','In Progress',50.00,14,7,NULL,7,9,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(35,'Intrusion Detection System','Implement IDS for threat detection',5,3,'High','2024-08-01','2024-08-31','2024-08-31','Not Started',0.00,30,0,NULL,7,10,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(36,'Employee Training','Train employees on security protocols',5,4,'Medium','2024-09-01','2024-09-15','2024-09-15','Not Started',0.00,14,0,NULL,7,11,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(37,'Regular Security Audits','Schedule regular audits',5,5,'Low','2024-09-16','2024-12-01','2024-12-01','Not Started',0.00,75,0,NULL,7,12,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(38,'Test','',3,NULL,'High','2024-11-15','2024-11-20','2024-11-29','Not Started',0.00,NULL,NULL,NULL,8,8,'2024-11-04 23:35:10','2024-11-04 23:35:10');
/*!40000 ALTER TABLE `tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teams`
--

DROP TABLE IF EXISTS `teams`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `teams` (
  `team_id` int NOT NULL AUTO_INCREMENT,
  `team_name` varchar(100) NOT NULL,
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`team_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teams`
--

LOCK TABLES `teams` WRITE;
/*!40000 ALTER TABLE `teams` DISABLE KEYS */;
INSERT INTO `teams` VALUES (1,'Development Team','Handles all development tasks','2024-11-04 23:33:22','2024-11-04 23:33:22'),(2,'QA Team','Responsible for testing and quality assurance','2024-11-04 23:33:22','2024-11-04 23:33:22'),(3,'SysAdmin Team','Manages system infrastructure and network security','2024-11-04 23:33:22','2024-11-04 23:33:22'),(4,'Design Team','Handles UI/UX and graphic design tasks','2024-11-04 23:33:22','2024-11-04 23:33:22'),(5,'Operations Team','Responsible for daily operations and support','2024-11-04 23:33:22','2024-11-04 23:33:22'),(6,'Security Team','Handles security audits and measures','2024-11-04 23:33:22','2024-11-04 23:33:22');
/*!40000 ALTER TABLE `teams` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `user_id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `role_id` int DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `roles` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'sysadmin1','sysadmin1@example.com','password123','Hank','SysAdmin',1,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(2,'sysadmin2','sysadmin2@example.com','password123','Sarah','SysAdmin',1,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(3,'manager1a','manager1a@example.com','password123','Frank','Manager1',2,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(4,'manager1b','manager1b@example.com','password123','Joel','Manager1',2,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(5,'manager1c','manager1c@example.com','password123','Sally','Manager1',2,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(6,'manager2a','manager2a@example.com','password123','Grace','Manager2',3,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(7,'manager2b','manager2b@example.com','password123','Manuel','Manager2',3,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(8,'user1','user1@example.com','password123','John','Doe',4,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(9,'user2','user2@example.com','password123','Jane','Smith',4,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(10,'user3','user3@example.com','password123','Bill','Williams',4,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(11,'user4','user4@example.com','password123','Mike','Johnson',4,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(12,'user5','user5@example.com','password123','Emily','Davis',4,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(13,'user6','user6@example.com','password123','Tom','Miller',4,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(14,'user7','user7@example.com','password123','Laura','Wilson',4,'2024-11-04 23:33:22','2024-11-04 23:33:22'),(15,'testuser1','test@test.com','scrypt:32768:8:1$ysV0D8EqIULWXy9n$18e269378bd5ba584ec6b49d6a3eafe43f677fe542358e72255ba979f1b84401c9a482e7da8ae9357b773cfec73ad7967ce827b6d8795981535b1873e619cd44',NULL,NULL,4,'2024-11-04 23:47:10','2024-11-04 23:47:10');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-11-05 19:32:48
