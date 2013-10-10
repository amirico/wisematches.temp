# 10.10
ALTER TABLE `billiongoods`.`store_group`
ADD COLUMN `categoryId` INT NULL
AFTER `name`,
ADD INDEX `category_foreign_idx` (`categoryId` ASC);
ALTER TABLE `billiongoods`.`store_group`
ADD CONSTRAINT `category_foreign`
FOREIGN KEY (`categoryId`)
REFERENCES `billiongoods`.`store_category` (`id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

# 9.10
ALTER TABLE `billiongoods`.`store_product`
CHANGE COLUMN `stockSold` `soldCount` INT(11) NOT NULL DEFAULT '0',
CHANGE COLUMN `stockAvailable` `stockLeftovers` INT(11) NULL DEFAULT NULL,
CHANGE COLUMN `restockDate` `stockRestockDate` DATE NULL DEFAULT NULL;

# 8.10
CREATE TABLE `billiongoods`.`service_validation` (
  `id`        INT            NOT NULL AUTO_INCREMENT,
  `productId` INT            NOT NULL,
  `timestamp` DATETIME       NOT NULL,
  `op`        DECIMAL(10, 4) NULL,
  `opp`       DECIMAL(10, 4) NULL,
  `osp`       DECIMAL(10, 4) NULL,
  `ospp`      DECIMAL(10, 4) NULL,
  `np`        DECIMAL(10, 4) NULL,
  `npp`       DECIMAL(10, 4) NULL,
  `nsp`       DECIMAL(10, 4) NULL,
  `nspp`      DECIMAL(10, 4) NULL,
  `oa`        INT            NULL,
  `ord`       DATE           NULL,
  `na`        INT            NULL,
  `nrd`       DATE           NULL,
  `errMsg`    VARCHAR(255)   NULL,
  PRIMARY KEY (`id`));

