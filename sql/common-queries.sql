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


-- queries

SELECT count(afi.`read`), af.account_id, f.title
FROM account_feed af
RIGHT JOIN feed f
    ON af.feed_uuid = f.uuid
LEFT JOIN account_feed_item afi
    ON afi.feed_uuid = af.feed_uuid
    AND afi.account_id = af.account_id
    AND afi.read = 0
WHERE af.account_id = 3
GROUP BY f.uuid
;

SELECT count(afi.`read`) AS unread, f.*
FROM account_feed af
RIGHT JOIN feed f
    ON af.feed_uuid = f.uuid
LEFT JOIN (
    SELECT *
    FROM account_feed_item
    WHERE `read` = 0
) afi
    ON afi.account_id = af.account_id
    AND afi.feed_uuid = af.feed_uuid
WHERE af.account_id = 3
GROUP BY f.uuid
ORDER BY unread DESC, f.title DESC
;


SELECT af.account_id, f.title, unread_items
FROM account_feed af
RIGHT JOIN feed f
    ON af.feed_uuid = f.uuid
WHERE unread_items = (
    SELECT COUNT(1)
    FROM account_feed_items
    WHERE
)
WHERE af.account_id = 3
GROUP BY f.uuid
;

-- get all feed_items for given feed uuid and account uuid

SELECT fi.*, f.title, f.description, afi.`read`, afi.starred
FROM feed_item fi
LEFT JOIN feed f
    ON f.uuid = fi.uuid
LEFT JOIN account_feed_item afi
    ON afi.feed_uuid = fi.feed_uuid
WHERE fi.feed_uuid = UNHEX('F93779986CADE1398B54598459118A4D')
;
