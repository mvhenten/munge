ALTER TABLE feed ADD COLUMN blacklist tinyint(2) NOT NULL DEFAULT '0';
ALTER TABLE feed add synchronized timestamp;