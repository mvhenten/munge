-- hex uuid from feed table
SELECT hex(uuid), title FROM feed ORDER BY title;

-- unhex
SELECT fi.title
FROM feed_item fi
WHERE fi.feed_uuid = unhex('2CA7173A7EC61538AF35D6BBC4D1EFBA')
;

-- select titles + counts per account
SELECT f.title, COUNT( fi.uuid ) - SUM( afi.`read` ) AS unread
FROM account_feed af
LEFT JOIN feed f
    ON af.feed_uuid = f.uuid
LEFT JOIN feed_item fi
    ON fi.feed_uuid = f.uuid
LEFT JOIN account_feed_item afi
    ON afi.feed_item_uuid = fi.uuid
WHERE af.account_id = 3
GROUP BY af.feed_uuid
ORDER BY unread DESC, f.title ASC
;

-- create rows in account_feed_item marking
-- feeds read
INSERT INTO account_feed_item ( account_id, feed_uuid, feed_item_uuid )
SELECT 3 AS account_id, fi.feed_uuid, fi.uuid
FROM  feed_item fi
    LEFT JOIN account_feed_item afi
    ON afi.feed_item_uuid = fi.uuid
    AND afi.account_id = 3
WHERE fi.feed_uuid = unhex('2CA7173A7EC61538AF35D6BBC4D1EFBA')
AND afi.feed_uuid IS NULL

-- mark all rows read
-- using update
UPDATE account_feed_item
SET `read` = 1
WHERE feed_uuid = unhex('2CA7173A7EC61538AF35D6BBC4D1EFBA')
AND account_id = 3
;
