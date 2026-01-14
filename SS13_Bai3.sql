USE SocialTriggerDB;

DROP TRIGGER IF EXISTS tg_before_insert_like_check;
DROP TRIGGER IF EXISTS tg_after_insert_like;
DROP TRIGGER IF EXISTS tg_after_delete_like;
DROP TRIGGER IF EXISTS tg_after_update_like;

DELIMITER //
CREATE TRIGGER tg_before_insert_like_check
BEFORE INSERT ON likes
FOR EACH ROW
BEGIN
    DECLARE v_post_owner INT;

    -- Lấy user_id của bài viết
    SELECT user_id
    INTO v_post_owner
    FROM posts
    WHERE post_id = NEW.post_id;

    -- Nếu user tự like bài của mình → báo lỗi
    IF NEW.user_id = v_post_owner THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Khong duoc like bai viet cua chinh minh';
    END IF;
END//

CREATE TRIGGER tg_after_insert_like
AFTER INSERT ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
    SET like_count = like_count + 1
    WHERE post_id = NEW.post_id;
END//

CREATE TRIGGER tg_after_delete_like
AFTER DELETE ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
    SET like_count = like_count - 1
    WHERE post_id = OLD.post_id;
END//

CREATE TRIGGER tg_after_update_like
AFTER UPDATE ON likes
FOR EACH ROW
BEGIN
    -- Nếu đổi bài viết được like
    IF OLD.post_id <> NEW.post_id THEN
        -- Giảm like ở post cũ
        UPDATE posts
        SET like_count = like_count - 1
        WHERE post_id = OLD.post_id;

        -- Tăng like ở post mới
        UPDATE posts
        SET like_count = like_count + 1
        WHERE post_id = NEW.post_id;
    END IF;
END//

DELIMITER ;

INSERT INTO likes (user_id, post_id) VALUES (2, 1);

SELECT post_id, like_count FROM posts WHERE post_id = 1;

UPDATE likes
SET post_id = 2
WHERE user_id = 2 AND post_id = 1
LIMIT 1;

SELECT post_id, like_count FROM posts WHERE post_id IN (1,2);

DELETE FROM likes
WHERE user_id = 2 AND post_id = 2
LIMIT 1;

SELECT post_id, like_count FROM posts WHERE post_id IN (1,2);

SELECT * FROM user_statistics;