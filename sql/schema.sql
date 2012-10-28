/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `email` varchar(254) DEFAULT NULL,
  `password` varchar(42) NOT NULL,
  `verification` varchar(42) NOT NULL,
  `verified` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,
  `created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
INSERT INTO `account` VALUES (1,'mvhenten@tty.nl','{SSHA}KT4YUtso4IxjwdRFFB3yAtFV6zDrv0so','','0000-00-00 00:00:00','2012-10-09 08:13:03'),(2,'test@ischen.nl','{SSHA}75sedvBEZPrJr6avd4+F4T6sX19lGE9H','','0000-00-00 00:00:00','2012-10-28 21:23:49');
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feed` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `account_id` int(10) unsigned NOT NULL,
  `link` varchar(2048) NOT NULL,
  `title` varchar(512) NOT NULL DEFAULT '',
  `description` varchar(4096) NOT NULL DEFAULT '',
  `updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,
  `created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `uuid` binary(16) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `account_uuid_idx` (`account_id`,`uuid`),
  KEY `index_updated` (`updated`),
  KEY `account_id_fk` (`account_id`),
  CONSTRAINT `account_id_fk` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feed_item` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `feed_id` int(10) unsigned NOT NULL,
  `account_id` int(10) unsigned NOT NULL,
  `uuid` binary(16) NOT NULL,
  `link` varchar(2048) NOT NULL,
  `title` varchar(512) NOT NULL DEFAULT '',
  `description` varchar(4096) NOT NULL DEFAULT '',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `read` tinyint(2) NOT NULL DEFAULT '0',
  `starred` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `account_feed_uuid` (`uuid`,`account_id`),
  KEY `account_id_fk` (`account_id`),
  KEY `feed_id_fk` (`feed_id`),
  KEY `read_idx` (`read`),
  KEY `star_idx` (`starred`),
  CONSTRAINT `feed_id_fk` FOREIGN KEY (`feed_id`) REFERENCES `feed` (`id`),
  CONSTRAINT `item_account_id_fk` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
