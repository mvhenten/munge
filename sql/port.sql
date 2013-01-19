CREATE TABLE `account_feed` (
  `account_id` int(10) unsigned NOT NULL,
  `feed_uuid` binary(16) NOT NULL,
  PRIMARY KEY (`account_id`,`feed_uuid`) ,
  KEY `account_key` (`account_id`),
  CONSTRAINT `account_fk` FOREIGN KEY (`account_id`) REFERENCES `account` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


CREATE TABLE `account_feed_item` (
  `account_id` int(10) unsigned NOT NULL,
  `feed_item_uuid` binary(16) NOT NULL,
  `feed_uuid` binary(16) NOT NULL,
  `read` tinyint(2) NOT NULL DEFAULT '0',
  `starred` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`account_id`,`feed_uuid`, `feed_item_uuid`),
  KEY `feed_uuid_fk` (`feed_uuid`),
  KEY `read_idx` (`read`),
  KEY `star_idx` (`starred`),
  CONSTRAINT `feed_uuid_fk` FOREIGN KEY (`feed_uuid`) REFERENCES `feed` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `feed` ADD KEY `uuid_key` (`uuid`);

INSERT INTO `account_feed` ( `account_id`, `feed_uuid` ) (
    SELECT account_id, uuid FROM feed
);

INSERT INTO `account_feed_item` ( `account_id`, `feed_uuid`, `feed_item_uuid`, `read`) (
    SELECT fi.account_id, f.uuid, fi.`uuid`, `read`
    FROM feed_item fi
    LEFT JOIN feed f ON f.id = fi.feed_id
);

; DELETE FROM `feed` WHERE account != 3;

ALTER TABLE `feed` DROP KEY `account_uuid_idx`;
ALTER TABLE `feed` DROP  FOREIGN KEY `account_id_fk`;
ALTER TABLE `feed` DROP KEY `account_id_fk`;
ALTER TABLE `feed` DROP COLUMN `account_id`;


ALTER TABLE `feed_item` DROP KEY `account_feed_uuid`;
ALTER TABLE `feed_item` DROP FOREIGN KEY `item_account_id_fk`;
ALTER TABLE `feed_item` DROP KEY  `account_id_fk`;
ALTER TABLE `feed_item` DROP KEY  `read_idx`;
ALTER TABLE `feed_item` DROP KEY  `star_idx`;

; possibly
; DELETE FROM `feed_item` WHERE `account_id` != '';

ALTER TABLE `feed_item` DROP COLUMN `account_id`;
ALTER TABLE `feed_item` DROP COLUMN `read`;
ALTER TABLE `feed_item` DROP COLUMN `starred`;

ALTER TABLE `feed_item` ADD COLUMN `feed_uuid` binary(16) NULL;

UPDATE `feed_item` fi
LEFT JOIN `feed` f
ON f.id = fi.feed_id
SET `feed_uuid` = f.`uuid`;

ALTER TABLE `feed_item` DROP FOREIGN KEY `feed_id_fk`;
ALTER TABLE `feed_item` DROP KEY `feed_id_fk`;
ALTER TABLE `feed_item` ADD KEY `feed_uuid_key` (`feed_uuid`); 
ALTER TABLE `feed_item` ADD CONSTRAINT
ALTER TABLE `feed_item` DROP COLUMN `feed_id`;
FOREIGN KEY `feed_uuid_key` (`feed_uuid`) REFERENCES `feed` (`uuid`);

ALTER TABLE `feed_item` DROP COLUMN `id`;
ALTER TABLE `feed` DROP COLUMN `id`;

ALTER TABLE `feed` DROP KEY `uuid_key`;

ALTER TABLE `feed` ADD CONSTRAINT PRIMARY KEY (`uuid`);
ALTER TABLE `feed_item` ADD CONSTRAINT PRIMARY KEY (`uuid`);

ALTER TABLE `feed_item` ADD COLUMN `poster_image` varchar(2048) NOT NULL DEFAULT '';
