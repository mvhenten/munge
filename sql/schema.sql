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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_feed` (
  `account_id` int(10) unsigned NOT NULL,
  `feed_uuid` binary(16) NOT NULL,
  PRIMARY KEY (`account_id`,`feed_uuid`),
  KEY `account_key` (`account_id`),
  KEY `feed_uuid_key` (`feed_uuid`),
  CONSTRAINT `account_feed_ibfk_1` FOREIGN KEY (`feed_uuid`) REFERENCES `feed` (`uuid`),
  CONSTRAINT `account_fk` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_feed_item` (
  `account_id` int(10) unsigned NOT NULL,
  `feed_item_uuid` binary(16) NOT NULL,
  `feed_uuid` binary(16) NOT NULL,
  `read` tinyint(2) NOT NULL DEFAULT '0',
  `starred` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`account_id`,`feed_uuid`,`feed_item_uuid`),
  KEY `feed_uuid_fk` (`feed_uuid`),
  KEY `read_idx` (`read`),
  KEY `star_idx` (`starred`),
  CONSTRAINT `feed_uuid_fk` FOREIGN KEY (`feed_uuid`) REFERENCES `feed` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feed` (
  `link` varchar(2048) NOT NULL,
  `title` varchar(512) NOT NULL DEFAULT '',
  `description` varchar(4096) NOT NULL DEFAULT '',
  `updated` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP,
  `created` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `uuid` binary(16) NOT NULL,
  PRIMARY KEY (`uuid`),
  KEY `index_updated` (`updated`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feed_item` (
  `uuid` binary(16) NOT NULL,
  `link` varchar(2048) NOT NULL,
  `author` varchar(2048) NOT NULL DEFAULT '',
  `title` varchar(512) NOT NULL DEFAULT '',
  `tags` varchar(1024) NOT NULL DEFAULT '',
  `summary` text,
  `content` mediumtext,
  `issued` datetime DEFAULT '0000-00-00 00:00:00',
  `modified` datetime DEFAULT '0000-00-00 00:00:00',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `feed_uuid` binary(16) DEFAULT NULL,
  `poster_image` varchar(2048) NOT NULL DEFAULT '',
  PRIMARY KEY (`uuid`),
  KEY `feed_uuid_key` (`feed_uuid`),
  CONSTRAINT `feed_item_ibfk_1` FOREIGN KEY (`feed_uuid`) REFERENCES `feed` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;
