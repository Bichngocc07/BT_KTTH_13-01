-- 1. TẠO DATABASE & BẢNG USERS
DROP DATABASE IF EXISTS SocialNetworkDB;
CREATE DATABASE SocialNetworkDB;
USE SocialNetworkDB;

DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at DATETIME
);

-- 2. XÓA TRIGGER / PROCEDURE CŨ (NẾU CÓ)
DROP TRIGGER IF EXISTS tg_check_user_before_insert;
DROP PROCEDURE IF EXISTS add_user;

DELIMITER //

-- 3. TRIGGER BEFORE INSERT
-- KIỂM TRA EMAIL & USERNAME
CREATE TRIGGER tg_check_user_before_insert
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    -- Kiểm tra email hợp lệ (phải chứa @ và .)
    IF NEW.email NOT LIKE '%@%.%' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email không hợp lệ!';
    END IF;

    -- Kiểm tra username chỉ chứa chữ, số, underscore
    IF NEW.username NOT REGEXP '^[A-Za-z0-9_]+$' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Username chỉ được chứa chữ cái, số và dấu gạch dưới!';
    END IF;
END//

-- 4. STORED PROCEDURE THÊM USER AN TOÀN
CREATE PROCEDURE add_user (
    IN p_username VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_created_at DATETIME
)
BEGIN
    INSERT INTO users (username, email, created_at)
    VALUES (p_username, p_email, p_created_at);
END//

DELIMITER ;

-- 5. KIỂM THỬ PROCEDURE & TRIGGER
-- 5.1 Dữ liệu hợp lệ (THÀNH CÔNG)
CALL add_user('nguyen_an', 'an@gmail.com', NOW());
CALL add_user('user_01', 'user01@example.com', NOW());

SELECT * FROM users;

