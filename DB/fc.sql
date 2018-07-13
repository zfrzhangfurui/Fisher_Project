-- MySQL dump 10.13  Distrib 5.7.17, for macos10.12 (x86_64)
--
-- Host: localhost    Database: scv
-- ------------------------------------------------------
-- Server version	5.6.35

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `filter_conditions`
--

DROP TABLE IF EXISTS `filter_conditions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `filter_conditions` (
  `settingName` varchar(255) DEFAULT NULL,
  `barrier` varchar(255) DEFAULT NULL,
  `WFA` varchar(255) DEFAULT NULL,
  `raceClass` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `sex` varchar(255) DEFAULT NULL,
  `trackCat` varchar(255) DEFAULT NULL,
  `DOW` varchar(255) DEFAULT NULL,
  `age` varchar(255) DEFAULT NULL,
  `trackCon` varchar(255) DEFAULT NULL,
  `r_tc_long` varchar(45) DEFAULT NULL,
  `jockey` varchar(255) DEFAULT NULL,
  `magin` varchar(255) DEFAULT NULL,
  `finishPos` varchar(255) DEFAULT NULL,
  `priseMoney` varchar(255) DEFAULT NULL,
  `day` varchar(255) DEFAULT NULL,
  `daysBewRaceDay` varchar(255) DEFAULT NULL,
  `dateFrom` varchar(45) DEFAULT NULL,
  `dateTo` varchar(45) DEFAULT NULL,
  `distanceFrom` varchar(255) DEFAULT NULL,
  `distanceTo` varchar(255) DEFAULT NULL,
  `handicap` varchar(255) DEFAULT NULL,
  `leastRaceHorse` varchar(255) DEFAULT NULL,
  `report_on` varchar(255) DEFAULT NULL,
  `same` varchar(255) DEFAULT NULL,
  `date_time` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=big5;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `filter_conditions`
--

LOCK TABLES `filter_conditions` WRITE;
/*!40000 ALTER TABLE `filter_conditions` DISABLE KEYS */;
INSERT INTO `filter_conditions` VALUES ('T2','0','[\"-0.5\",\"2.0\",\"3.0\",\"3.5\",\"4.0\",\"4.5\"]','0','[\"TAS\"]','0','0','0','[\"2+\"]','0','0','0','0','0','0','400','0','\"2000-04-05\"','\"2017-08-01\"','0','0','0','1','\"Barrier\"','{}','2018-03-31 02:28:20'),('0404','[\"1-9\"]','0','[\"OPN\"]','0','0','[\"M\"]','[\"MetroSat\"]','[\"open\"]','0','0','0','[\"0-25\"]','0','0','35','366','\"2001-08-01\"','\"NaN-undefined-aN\"','0','0','[\"OPEN\"]','2','\"WFA\"','{}','2018-04-04 10:05:46'),('T3','[\"1-9\"]','0','[\"95B\",\"90B\",\"85B\",\"80B\",\"OPN\"]','[\"NSW\",\"TAS\"]','0','[\"M\"]','[\"MetroSat\"]','[]','0','0','0','0','0','0','0','0','\"2016-04-05\"','\"2017-08-01\"','0','0','0','3','\"Race Class\"','{\"state\":true,\"trackCat\":true}','2018-04-05 11:27:34'),('same_test','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','1','null','{\"state\":true,\"trackCat\":true}','2018-04-05 11:30:59'),('TEST1','0','0','[\"95B\",\"90B\",\"85B\",\"80B\",\"75B\",\"70B\",\"OPN\",\"LR\",\"G3\",\"G2\",\"G1\"]','[\"NSW\"]','[\"Open\"]','[\"M\"]','[\"MetroSat\"]','[\"open\"]','0','0','0','[\"-10-25\"]','0','0','21','366','\"2007-08-01\"','0','0','0','[\"OPEN\"]','2','\"Race Class\"','{\"trackCond\":true,\"WFA\":true,\"barrier\":true}','2018-04-09 01:01:37'),('Test1','0','0','[\"95B\",\"90B\",\"85B\",\"80B\",\"75B\",\"70B\",\"OPN\",\"LR\",\"G3\",\"G2\",\"G1\"]','[\"NSW\"]','[\"Open\"]','[\"M\"]','[\"MetroSat\"]','[\"open\"]','0','0','0','[\"0-25\"]','0','0','21','366','\"2007-08-01\"','0','0','0','[\"OPEN\"]','2','\"Race Class\"','{\"trackCond\":true,\"WFA\":true,\"barrier\":true}','2018-04-09 01:06:31'),('Test2','0','0','[\"95B\",\"90B\",\"85B\",\"80B\",\"75B\",\"70B\",\"OPN\",\"LR\",\"G3\",\"G2\",\"G1\"]','0','0','0','0','0','0','0','0','0','0','0','0','0','\"2007-08-01\"','\"NaN-undefined-aN\"','0','0','0','1','\"Race Class\"','{\"trackcCond\":true,\"WFA\":false,\"barrier\":false}','2018-04-09 02:18:14'),('0416','0','0','[\"95B\",\"90B\",\"85B\",\"80B\",\"75B\",\"LR\",\"G3\",\"G1\",\"G2\",\"OPN\"]','[\"NSW\"]','[\"Open\"]','[\"M\"]','[\"MetroSat\"]','[\"open\",\"5+\",\"4+\",\"3+\"]','[\"G\"]','0','0','[\"0-25\"]','0','0','22','43','\"2013-01-01\"','0','0','0','[\"OPEN\"]','2','\"Race Class\"','{}','2018-04-16 03:55:10'),('0416_1','0','0','[\"95B\",\"90B\",\"85B\",\"80B\",\"75B\",\"LR\",\"G3\",\"G1\",\"G2\",\"OPN\"]','0','[\"Open\"]','[\"M\"]','[\"MetroSat\"]','[\"open\",\"5+\",\"4+\",\"3+\"]','[\"G\"]','0','0','[\"0-25\"]','0','0','22','43','\"2008-01-01\"','0','0','0','[\"OPEN\"]','2','\"Race Class\"','{}','2018-04-16 12:30:57'),('wfa','0','0','0','0','[\"Open\"]','0','0','[\"2+\",\"4+\",\"5+\",\"open\",\"3+\"]','0','0','0','[\"0-25\"]','0','[\"22\"]','43','0','\"2000-08-01\"','0','0','0','[\"OPEN\"]','2','\"WFA\"','{}','2018-04-20 01:38:18'),('111111','0','0','0','0','0','0','0','0','[\"F\",\"G\"]','[\"FIRM 1\",\"FIRM 2\",\"GOOD 3\"]','0','0','0','0','0','0','0','0','0','0','0','2','null','{}','2018-05-13 07:30:02');
/*!40000 ALTER TABLE `filter_conditions` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-05-21 21:31:30
