USE SocialTriggerDB;

DROP TABLE IF EXISTS post_history;

CREATE TABLE post_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    post_id INT,
    old_content TEXT,
    new_content TEXT,
    changed_at DATETIME,
    changed_by_user_id INT,
    CONSTRAINT fk_history_post
        FOREIGN KEY (post_id)
        REFERENCES posts(post_id)
        ON DELETE CASCADE
);

DROP TRIGGER IF EXISTS tg_before_update_post_log;
DROP TRIGGER IF EXISTS tg_after_delete_post_log;

DELIMITER //

CREATE TRIGGER tg_before_update_post_log
BEFORE UPDATE ON posts
FOR EACH ROW
BEGIN
    -- Chỉ ghi lịch sử nếu content thay đổi
    IF OLD.content <> NEW.content THEN
        INSERT INTO post_history (
            post_id,
            old_content,
            new_content,
            changed_at,
            changed_by_user_id
        )
        VALUES (
            OLD.post_id,
            OLD.content,
            NEW.content,
            NOW(),
            OLD.user_id
        );
    END IF;
END//

CREATE TRIGGER tg_after_delete_post_log
AFTER DELETE ON posts
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '01000'
    SET MESSAGE_TEXT = 'Post deleted, history removed by cascade';
END//

DELIMITER ;

SELECT post_id, content FROM posts;

UPDATE posts
SET content = 'Noi dung bai viet da duoc cap nhat lan 1'
WHERE post_id = 1;

UPDATE posts
SET content = 'Noi dung bai viet da duoc cap nhat lan 2'
WHERE post_id = 1;

SELECT * FROM post_history
WHERE post_id = 1
ORDER BY changed_at;

SELECT post_id, like_count FROM posts WHERE post_id = 1;

