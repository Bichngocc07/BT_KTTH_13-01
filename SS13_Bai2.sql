USE SocialTriggerDB;

DROP TABLE IF EXISTS likes;

CREATE TABLE likes (
    like_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    post_id INT,
    liked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_likes_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_likes_post
        FOREIGN KEY (post_id)
        REFERENCES posts(post_id)
        ON DELETE CASCADE
);

INSERT INTO likes (user_id, post_id, liked_at) VALUES
(2, 1, '2025-01-10 11:00:00'),
(3, 1, '2025-01-10 13:00:00'),
(3, 1, '2025-01-10 13:00:00'),
(1, 3, '2025-01-11 10:00:00'),
(3, 4, '2025-01-12 16:00:00');

DELIMITER //

-- Trigger: Sau khi thêm like → tăng like_count
CREATE TRIGGER tg_after_insert_like
AFTER INSERT ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
    SET like_count = like_count + 1
    WHERE post_id = NEW.post_id;
END//

-- Trigger: Sau khi xóa like → giảm like_count
CREATE TRIGGER tg_after_delete_like
AFTER DELETE ON likes
FOR EACH ROW
BEGIN
    UPDATE posts
    SET like_count = like_count - 1
    WHERE post_id = OLD.post_id;
END//

DELIMITER ;

DROP VIEW IF EXISTS user_statistics;

CREATE VIEW user_statistics AS
SELECT
    u.user_id,
    u.username,
    u.post_count,
    COALESCE(SUM(p.like_count), 0) AS total_likes
FROM users u
LEFT JOIN posts p ON u.user_id = p.user_id
GROUP BY u.user_id, u.username, u.post_count;

INSERT INTO likes (user_id, post_id, liked_at)
VALUES (2, 4, NOW());

-- Kiểm tra bài viết
SELECT * FROM posts WHERE post_id = 4;

-- Kiểm tra View thống kê
SELECT * FROM user_statistics;

DELETE FROM likes
WHERE user_id = 2 AND post_id = 4
LIMIT 1;

-- Kiểm tra lại
SELECT * FROM posts WHERE post_id = 4;
SELECT * FROM user_statistics;

/* =====================================================
   END FILE
   ===================================================== */
