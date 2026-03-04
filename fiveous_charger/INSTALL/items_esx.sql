-- Run this in your database if your server uses the `items` table (default ESX)

INSERT INTO `items` (`name`, `label`, `weight`) VALUES
    ('powerbank', 'Power Bank', 50),
    ('carcharger', 'Car Charger', 50)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`), `weight` = VALUES(`weight`);
