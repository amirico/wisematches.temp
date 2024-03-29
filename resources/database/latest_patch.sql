#29.07.14
UPDATE store_order
SET paymentAmount = 0
WHERE paymentAmount IS NULL;

UPDATE store_order
SET refundAmount = 0
WHERE refundAmount IS NULL;

ALTER TABLE `billiongoods`.`store_order`
CHANGE COLUMN `paymentAmount` `paymentAmount` DECIMAL(10, 4) NOT NULL DEFAULT 0,
CHANGE COLUMN `refundAmount` `refundAmount` DECIMAL(10, 4) NOT NULL DEFAULT 0;

ALTER TABLE `billiongoods`.`store_order_log`
ADD COLUMN `amount` DECIMAL NULL DEFAULT NULL
AFTER `parcelState`;

ALTER TABLE `billiongoods`.`store_order_log`
CHANGE COLUMN `amount` `refundAmount` DECIMAL(10, 0) NULL DEFAULT NULL;

ALTER TABLE `billiongoods`.`store_order`
CHANGE COLUMN `refundId` `refundId` VARCHAR(255) NULL DEFAULT NULL;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('290714');

#07.07.14
CREATE TABLE `billiongoods`.`store_order_parcel` (
  `id`                    BIGINT       NOT NULL AUTO_INCREMENT,
  `orderId`               BIGINT       NOT NULL,
  `number`                INT          NOT NULL,
  `state`                 INT          NOT NULL,
  `exceptedResume`        DATETIME     NULL,
  `commentary`            VARCHAR(255) NULL,
  `refundToken`           VARCHAR(45)  NULL,
  `chinaMailTracking`     VARCHAR(45)  NULL,
  `internationalTracking` VARCHAR(45)  NULL,
  `timestamp`             DATETIME     NOT NULL,
  PRIMARY KEY (`id`)
);

ALTER TABLE `billiongoods`.`store_order_parcel`
ADD INDEX `order_idx` (`orderId` ASC);
ALTER TABLE `billiongoods`.`store_order_parcel`
ADD CONSTRAINT `order`
FOREIGN KEY (`orderId`)
REFERENCES `billiongoods`.`store_order` (`id`)
  ON DELETE CASCADE
  ON UPDATE NO ACTION;

ALTER TABLE `billiongoods`.`store_order`
CHANGE COLUMN `created` `created` DATETIME NOT NULL
AFTER `buyer`,
CHANGE COLUMN `shipmentType` `shipmentType` TINYINT(4) NOT NULL
AFTER `amount`,
CHANGE COLUMN `discount` `discountAmount` DECIMAL(10, 4) NOT NULL DEFAULT '0.0000'
AFTER `discountCoupon`,
CHANGE COLUMN `token` `token` VARCHAR(20) NULL DEFAULT NULL
AFTER `closed`,
CHANGE COLUMN `shipment` `shipmentAmount` DECIMAL(10, 4) NOT NULL,
CHANGE COLUMN `coupon` `discountCoupon` VARCHAR(10) NULL,
ADD COLUMN `paymentAmount` DECIMAL(10, 4) NULL
AFTER `paymentId`,
ADD COLUMN `refundId` VARCHAR(20) NULL
AFTER `paymentAmount`,
ADD COLUMN `refundAmount` DECIMAL(10, 4) NULL
AFTER `refundId`;

ALTER TABLE `billiongoods`.`store_order`
CHANGE COLUMN `created` `created` DATETIME NOT NULL
AFTER `refundToken`,
CHANGE COLUMN `shipped` `shipped` DATETIME NULL DEFAULT NULL
AFTER `created`,
CHANGE COLUMN `closed` `closed` DATETIME NULL DEFAULT NULL
AFTER `shipped`,
ADD COLUMN `processed` DATETIME NULL DEFAULT NULL
AFTER `closed`,
ADD COLUMN `finished` DATETIME NULL DEFAULT NULL
AFTER `processed`;

ALTER TABLE `billiongoods`.`store_order`
DROP COLUMN `finished`,
CHANGE COLUMN `processed` `processed` DATETIME NULL DEFAULT NULL
AFTER `created`,
CHANGE COLUMN `closed` `finished` DATETIME NULL DEFAULT NULL;

ALTER TABLE `billiongoods`.`store_order`
ADD COLUMN `started` DATETIME NULL DEFAULT NULL
AFTER `created`;

ALTER TABLE `billiongoods`.`store_order_parcel`
CHANGE COLUMN `timestamp` `tbr_timestamp` DATETIME NOT NULL,
ADD COLUMN `created` DATETIME NOT NULL
AFTER `internationalTracking`,
ADD COLUMN `started` DATETIME NULL DEFAULT NULL
AFTER `created`,
ADD COLUMN `processed` DATETIME NULL DEFAULT NULL
AFTER `started`,
ADD COLUMN `shipped` DATETIME NULL DEFAULT NULL
AFTER `processed`,
ADD COLUMN `finished` DATETIME NULL DEFAULT NULL
AFTER `shipped`;

ALTER TABLE `billiongoods`.`store_order_parcel`
DROP COLUMN `tbr_timestamp`;

ALTER TABLE `billiongoods`.`store_order`
DROP COLUMN `tracking`;

INSERT INTO store_order_parcel
(orderId, number, state, chinaMailTracking, internationalTracking, created)
  SELECT
    id,
    cast(referenceTracking AS UNSIGNED),
    0,
    chinaMailTracking,
    internationalTracking,
    created
  FROM store_order
  WHERE referenceTracking <> '' AND referenceTracking NOT LIKE "%,%";

INSERT INTO store_order_parcel
(orderId, number, state, chinaMailTracking, internationalTracking, created)
  SELECT
    id,
    cast(SUBSTRING_INDEX(referenceTracking, ',', 1) AS UNSIGNED),
    0,
    SUBSTRING_INDEX(chinaMailTracking, ',', 1),
    SUBSTRING_INDEX(internationalTracking, ',', 1),
    created
  FROM store_order
  WHERE referenceTracking <> '' AND referenceTracking LIKE "%,%";

INSERT INTO store_order_parcel
(orderId, number, state, chinaMailTracking, internationalTracking, created)
  SELECT
    id,
    cast(SUBSTRING_INDEX(referenceTracking, ',', -1) AS UNSIGNED),
    0,
    SUBSTRING_INDEX(chinaMailTracking, ',', -1),
    SUBSTRING_INDEX(internationalTracking, ',', -1),
    created
  FROM store_order
  WHERE referenceTracking <> '' AND referenceTracking LIKE "%,%";

UPDATE store_order AS s, store_order_log AS l
SET s.started = l.timestamp
WHERE s.id = l.orderId AND l.orderState = 2;
UPDATE store_order AS s, store_order_log AS l
SET s.processed = l.timestamp
WHERE s.id = l.orderId AND l.orderState = 3;
UPDATE store_order AS s, store_order_log AS l
SET s.shipped = l.timestamp
WHERE s.id = l.orderId AND l.orderState IN (4, 5);
UPDATE store_order AS s, store_order_log AS l
SET s.finished = l.timestamp
WHERE s.id = l.orderId AND l.orderState IN (6, 8, 9);

UPDATE store_order_parcel AS p, store_order AS s
SET p.state = 0, p.created = s.created, p.started = s.started
WHERE p.orderId = s.id AND s.state = 3;
UPDATE store_order_parcel AS p, store_order AS s
SET p.state = 2, p.shipped = s.shipped
WHERE p.orderId = s.id AND s.state = 5;
UPDATE store_order_parcel AS p, store_order AS s
SET p.state = 1, p.shipped = s.shipped
WHERE p.orderId = s.id AND s.state = 4;
UPDATE store_order_parcel AS p, store_order AS s
SET p.state = 3
WHERE p.orderId = s.id AND s.state = 7;
UPDATE store_order_parcel AS p, store_order AS s
SET p.state = 4, p.finished = s.finished
WHERE p.orderId = s.id AND s.state = 8;
UPDATE store_order_parcel AS p, store_order AS s
SET p.state = 5, p.finished = s.finished
WHERE p.orderId = s.id AND s.state = 9;

ALTER TABLE `billiongoods`.`store_order_item`
ADD COLUMN `parcelId` BIGINT(20) NULL DEFAULT NULL
AFTER `number`;

ALTER TABLE `billiongoods`.`store_order_log`
CHANGE COLUMN `timestamp` `timestamp` DATETIME NOT NULL
AFTER `commentary`,
ADD COLUMN `parcelId` BIGINT(20) NULL DEFAULT NULL
AFTER `orderState`,
ADD COLUMN `parcelState` TINYINT(4) NULL DEFAULT NULL
AFTER `parcelId`;

UPDATE store_order_item AS i, store_order_parcel AS p
SET i.parcelId = p.id
WHERE p.orderId = i.orderId;

ALTER TABLE `billiongoods`.`store_order`
DROP COLUMN `exceptedResume`,
DROP COLUMN `internationalTracking`,
DROP COLUMN `chinaMailTracking`,
DROP COLUMN `referenceTracking`;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('070714');

#10.06.14
ALTER TABLE `billiongoods`.`store_product`
ADD COLUMN `stockSoldCount` INT(11) NOT NULL DEFAULT '0'
AFTER `stockArrivalDate`;

ALTER TABLE `billiongoods`.`service_validation`
ADD COLUMN `osc` INT(11) NULL DEFAULT NULL
AFTER `ord`,
ADD COLUMN `nsc` INT(11) NULL DEFAULT NULL
AFTER `nrd`;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('100614');

#05.06.14
ALTER TABLE `billiongoods`.`store_product`
ADD COLUMN `restriction` SMALLINT(6) NULL
AFTER `state`;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('050614');

#08.05.14
ALTER TABLE `billiongoods`.`store_showcase`
DROP COLUMN `uri`;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('080514');

#11.04.14
UPDATE store_product
SET stockLeftovers = 0
WHERE stockLeftovers IS NULL;

ALTER TABLE `billiongoods`.`store_product`
CHANGE COLUMN `stockLeftovers` `stockCount` INT(11) NOT NULL DEFAULT 0
AFTER `soldCount`,
CHANGE COLUMN `stockDelivery` `stockShipDays` INT(11) NOT NULL DEFAULT 3,
CHANGE COLUMN `stockRestockDate` `stockArrivalDate` DATE NULL DEFAULT NULL;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('110414');

#08.04.14
ALTER TABLE `billiongoods`.`store_product`
ADD COLUMN `stockDelivery` INT NULL DEFAULT 3
AFTER `soldCount`;

ALTER TABLE `billiongoods`.`service_validation`
ADD COLUMN `odd` INT NULL DEFAULT 3
AFTER `ord`,
ADD COLUMN `ndd` INT NULL DEFAULT 3
AFTER `nrd`;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('080414');

#14.02.14
ALTER TABLE `billiongoods`.`store_order`
ADD COLUMN `phone` VARCHAR(20) NULL DEFAULT NULL
AFTER `city`;

ALTER TABLE `billiongoods`.`privacy_address_record`
CHANGE COLUMN `postcode` `postcode` VARCHAR(10) NULL DEFAULT NULL,
CHANGE COLUMN `region` `region` VARCHAR(145) NULL DEFAULT NULL,
CHANGE COLUMN `city` `city` VARCHAR(145) NULL DEFAULT NULL,
ADD COLUMN `phone` VARCHAR(20) NULL DEFAULT NULL
AFTER `lastName`;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('140214');

#14.02.12
ALTER TABLE `billiongoods`.`store_category`
ADD COLUMN `symbolic` VARCHAR(155) NULL DEFAULT NULL
AFTER `name`;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('140212');

#14.02.10
ALTER TABLE `billiongoods`.`store_product`
ADD COLUMN `encodedName` VARCHAR(155) NOT NULL DEFAULT ''
AFTER `name`;

ALTER TABLE `billiongoods`.`store_product`
CHANGE COLUMN `encodedName` `symbolicName` VARCHAR(155) NOT NULL DEFAULT '';

ALTER TABLE `billiongoods`.`store_product`
CHANGE COLUMN `symbolicName` `symbolicName` VARCHAR(155) NULL DEFAULT NULL;

ALTER TABLE `billiongoods`.`store_product`
CHANGE COLUMN `symbolicName` `symbolic` VARCHAR(155) NULL DEFAULT NULL;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('140210');

#14.01.30
CREATE TABLE `billiongoods`.`privacy_wishlist` (
  `person`  INT(20) NOT NULL,
  `product` INT     NOT NULL,
  PRIMARY KEY (`person`, `product`)
);

ALTER TABLE `billiongoods`.`privacy_wishlist`
CHANGE COLUMN `person` `person` BIGINT(20) NOT NULL;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('140130');

#12.27
CREATE TABLE `billiongoods`.`report_mistake` (
  `id`          INT  NOT NULL AUTO_INCREMENT,
  `productId`   INT  NOT NULL,
  `description` TEXT NULL,
  PRIMARY KEY (`id`),
  INDEX `product_idx` (`productId` ASC),
  CONSTRAINT `product`
  FOREIGN KEY (`productId`)
  REFERENCES `billiongoods`.`store_product` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
);

ALTER TABLE `billiongoods`.`report_mistake`
CHANGE COLUMN `description` `description` TEXT NOT NULL,
ADD COLUMN `scope` TINYINT NOT NULL
AFTER `description`;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('1227');

#12.19
ALTER TABLE `billiongoods`.`store_order`
ADD COLUMN `payerName` VARCHAR(255) NULL DEFAULT NULL
AFTER `payer`;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('1219');

#12.10
ALTER TABLE `billiongoods`.`store_order`
CHANGE COLUMN `addressName` `firstName` VARCHAR(120) NULL DEFAULT NULL,
CHANGE COLUMN `addressRegion` `region` VARCHAR(120) NULL DEFAULT NULL,
CHANGE COLUMN `addressCity` `city` VARCHAR(120) NULL DEFAULT NULL,
CHANGE COLUMN `addressPostal` `postcode` VARCHAR(10) NULL DEFAULT NULL,
CHANGE COLUMN `addressStreet` `location` VARCHAR(250) NULL DEFAULT NULL,
ADD COLUMN `lastName` VARCHAR(245) NULL
AFTER `firstName`;

CREATE TABLE `billiongoods`.`privacy_address_book` (
  `id`      BIGINT(20) NOT NULL,
  `primary` INT        NULL,
  PRIMARY KEY (`id`),
  CONSTRAINT `asdf`
  FOREIGN KEY (`id`)
  REFERENCES `billiongoods`.`account_personality` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION
);

ALTER TABLE `billiongoods`.`privacy_address_book`
DROP FOREIGN KEY `asdf`;
ALTER TABLE `billiongoods`.`privacy_address_book`
ADD CONSTRAINT `personality`
FOREIGN KEY (`id`)
REFERENCES `billiongoods`.`account_personality` (`id`)
  ON DELETE CASCADE
  ON UPDATE NO ACTION;

CREATE TABLE `privacy_address_record` (
  `id`          INT(11)      NOT NULL,
  `addressBook` BIGINT(20)   NOT NULL,
  `firstName`   VARCHAR(145) NOT NULL,
  `lastName`    VARCHAR(245) NOT NULL,
  `postcode`    VARCHAR(10)  NOT NULL,
  `region`      VARCHAR(145) NOT NULL,
  `city`        VARCHAR(145) NOT NULL,
  `location`    VARCHAR(250) NOT NULL,
  `primary`     TINYINT(1)   NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `addressBook_idx` (`addressBook`),
  CONSTRAINT `addressBook` FOREIGN KEY (`addressBook`) REFERENCES `privacy_address_book` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
)
  ENGINE =InnoDB
  DEFAULT CHARSET =utf8;

ALTER TABLE `billiongoods`.`privacy_address_record`
DROP COLUMN `primary`;

ALTER TABLE `billiongoods`.`privacy_address_record`
CHANGE COLUMN `id` `id` INT(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `billiongoods`.`privacy_address_book`
CHANGE COLUMN `primary` `primaryAddress` INT(11) NULL;

ALTER TABLE `billiongoods`.`privacy_address_record`
CHANGE COLUMN `street` `location` VARCHAR(250) NOT NULL;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('1210');

#12.09
ALTER TABLE `billiongoods`.`account_personality`
CHANGE COLUMN `email` `email` VARCHAR(150) NULL
AFTER `id`,
CHANGE COLUMN `password` `password` VARCHAR(100) NULL DEFAULT NULL
AFTER `email`,
ADD COLUMN `language` TINYINT NULL
AFTER `username`,
ADD COLUMN `timezone` VARCHAR(245) NULL
AFTER `language`;

ALTER TABLE `billiongoods`.`account_personality`
CHANGE COLUMN `language` `language` CHAR(2) NULL DEFAULT 'RU',
CHANGE COLUMN `timezone` `timezone` VARCHAR(245) NULL DEFAULT 'GMT+00:00';

UPDATE account_personality
SET language = 'RU', timezone = 'GMT+00:00';

ALTER TABLE `billiongoods`.`account_personality`
CHANGE COLUMN `language` `language` CHAR(2) NOT NULL DEFAULT 'RU',
CHANGE COLUMN `timezone` `timezone` VARCHAR(245) NOT NULL DEFAULT 'GMT+00:00';

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('1209');

#12.03
ALTER TABLE `billiongoods`.`store_coupon`
CHANGE COLUMN `reference` `reference` INT(11) NULL DEFAULT NULL;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('1203');

#11.26
ALTER TABLE `billiongoods`.`store_order`
ADD COLUMN `shipped` DATETIME NULL
AFTER `created`;

UPDATE store_order o LEFT JOIN store_order_log l
    ON o.id = l.orderId
SET o.shipped = l.timestamp
WHERE l.orderState = 5;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('1126');

#11.25
ALTER TABLE `billiongoods`.`account_personality`
CHANGE COLUMN `password` `password` VARCHAR(100) NULL,
CHANGE COLUMN `email` `email` VARCHAR(150) NULL;

CREATE TABLE account_UserConnection (
  userId         VARCHAR(255) NOT NULL,
  providerId     VARCHAR(255) NOT NULL,
  providerUserId VARCHAR(255),
  rank           INT          NOT NULL,
  displayName    VARCHAR(255),
  profileUrl     VARCHAR(512),
  imageUrl       VARCHAR(512),
  accessToken    VARCHAR(255) NOT NULL,
  secret         VARCHAR(255),
  refreshToken   VARCHAR(255),
  expireTime     BIGINT,
  PRIMARY KEY (userId, providerId, providerUserId)
);
CREATE UNIQUE INDEX UserConnectionRank ON account_UserConnection (userId, providerId, rank);

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('1125');

#11.12
ALTER TABLE `billiongoods`.`store_order_log`
DROP COLUMN `code`;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('1112');
#11.01
UPDATE store_product_relationship
SET type = 0;

ALTER TABLE `billiongoods`.`store_group`
ADD COLUMN `type` INT(2) NOT NULL DEFAULT 0
AFTER `name`;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('1101');

#10.31
ALTER TABLE `billiongoods`.`store_basket`
ADD COLUMN `coupon` INT(11) NULL
AFTER `updatingTime`;

ALTER TABLE `billiongoods`.`store_order`
ADD COLUMN `discount` DECIMAL(10, 4) NOT NULL DEFAULT 0
AFTER `amount`,
ADD COLUMN `coupon` INT NULL DEFAULT NULL
AFTER `shipmentType`;

ALTER TABLE `billiongoods`.`store_coupon`
DROP COLUMN `id`,
DROP PRIMARY KEY,
ADD PRIMARY KEY (`code`),
DROP INDEX `code_INDEX`,
DROP INDEX `code_UNIQUE`;

ALTER TABLE `billiongoods`.`store_order`
CHANGE COLUMN `coupon` `coupon` VARCHAR(10) NULL DEFAULT NULL;

ALTER TABLE `billiongoods`.`store_basket`
CHANGE COLUMN `coupon` `coupon` VARCHAR(10) NULL DEFAULT NULL;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('1031');

#10.30
ALTER TABLE `billiongoods`.`store_coupon`
CHANGE COLUMN `closure` `closure` DATETIME NULL DEFAULT NULL,
ADD COLUMN `lastUsed` DATETIME NULL DEFAULT NULL
AFTER `closure`;

ALTER TABLE `billiongoods`.`store_coupon`
DROP COLUMN `lastUsed`,
DROP COLUMN `finished`,
DROP COLUMN `started`,
CHANGE COLUMN `created` `creation` DATETIME NOT NULL,
CHANGE COLUMN `amount` `termination` DATETIME NOT NULL,
CHANGE COLUMN `couponType` `amountType` TINYINT(4) NOT NULL,
CHANGE COLUMN `referenceId` `reference` INT(11) NOT NULL,
CHANGE COLUMN `scheduledCount` `utilizedCount` SMALLINT(6) NULL DEFAULT '0',
CHANGE COLUMN `remainingCount` `allocatedCount` SMALLINT(6) NULL DEFAULT '0',
CHANGE COLUMN `closure` `lastUtilization` DATETIME NULL DEFAULT NULL,
ADD INDEX `reference_index` (`reference` ASC),
ADD INDEX `reference_type_index` (`referenceType` ASC);

ALTER TABLE `billiongoods`.`store_coupon`
ADD COLUMN `amount` DOUBLE NOT NULL
AFTER `termination`;

ALTER TABLE `billiongoods`.`store_coupon`
CHANGE COLUMN `termination` `termination` DATETIME NULL;

CREATE TABLE `billiongoods`.`system_version` (
  `version`      INT      NOT NULL,
  `modification` DATETIME NOT NULL
);

ALTER TABLE `billiongoods`.`system_version`
ADD PRIMARY KEY (`version`);

ALTER TABLE `billiongoods`.`system_version`
CHANGE COLUMN `modification` `modification` TIMESTAMP NOT NULL;

INSERT INTO `billiongoods`.`system_version` (`version`) VALUES ('1030');

#10.28
ALTER TABLE `billiongoods`.`store_order_item`
DROP FOREIGN KEY `fk_store_order_item_store_order1`;
ALTER TABLE `billiongoods`.`store_order_item`
ADD CONSTRAINT `fk_store_order_item_store_order1`
FOREIGN KEY (`orderId`)
REFERENCES `billiongoods`.`store_order` (`id`)
  ON DELETE CASCADE
  ON UPDATE NO ACTION;


#10.23
CREATE TABLE `billiongoods`.`store_coupon` (
  `id`             INT         NOT NULL AUTO_INCREMENT,
  `code`           VARCHAR(10) NOT NULL,
  `created`        DATETIME    NOT NULL,
  `amount`         DOUBLE      NOT NULL,
  `couponType`     TINYINT     NOT NULL,
  `referenceId`    INT         NOT NULL,
  `referenceType`  TINYINT     NOT NULL,
  `started`        DATETIME    NULL DEFAULT NULL,
  `finished`       DATETIME    NULL DEFAULT NULL,
  `scheduledCount` SMALLINT    NULL DEFAULT 0,
  `remainingCount` SMALLINT    NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `code_UNIQUE` (`code` ASC),
  INDEX `code_INDEX` (`code` ASC)
);

ALTER TABLE `billiongoods`.`store_coupon`
ADD COLUMN `closure` INT(1) NULL DEFAULT 0
AFTER `remainingCount`;

#10.22
ALTER TABLE `billiongoods`.`store_order`
CHANGE COLUMN `creationTime` `created` DATETIME NOT NULL,
ADD COLUMN `closed` DATETIME NULL
AFTER `created`;

UPDATE store_order
SET state = state - 1
WHERE state > 1;

ALTER TABLE `billiongoods`.`paypal_transaction`
DROP FOREIGN KEY `fk_paypal_transaction_store_order1`;
ALTER TABLE `billiongoods`.`paypal_transaction`
DROP INDEX `fk_paypal_transaction_store_order1_idx`,
ADD INDEX `INDEX_orderId` (`orderId` ASC);

ALTER TABLE `billiongoods`.`store_product`
ADD COLUMN `recommended` INT(1) NOT NULL DEFAULT 0
AFTER `state`,
ADD INDEX `recommended_index` (`recommended` ASC);

# 10.18
ALTER TABLE `billiongoods`.`store_order`
ADD COLUMN `exceptedResume` DATETIME NULL DEFAULT NULL
AFTER `internationalTracking`,
ADD COLUMN `refundId` VARCHAR(45) NULL DEFAULT NULL
AFTER `exceptedResume`;

ALTER TABLE `billiongoods`.`store_order`
CHANGE COLUMN `refundId` `refundToken` VARCHAR(45) NULL DEFAULT NULL;

# 10.14
ALTER TABLE `billiongoods`.`account_personality`
CHANGE COLUMN `lastActivityDate` `lastActivity` DATETIME NULL;

# 10.11
ALTER TABLE `billiongoods`.`store_attribute`
ADD COLUMN `priority` TINYINT NULL DEFAULT 0
AFTER `type`;

UPDATE store_order
SET state = state - 1
WHERE state > 1;

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

ALTER TABLE `billiongoods`.`store_product_property`
CHANGE COLUMN `dvalue` `bvalue` INT(1) NULL DEFAULT NULL;

# 9.10
ALTER TABLE `billiongoods`.`store_product`
CHANGE COLUMN `stockSold` `soldCount` INT(11) NOT NULL DEFAULT '0',
CHANGE COLUMN `stockAvailable` `stockLeftovers` INT(11) NULL DEFAULT NULL,
CHANGE COLUMN `stockArrivalDate` `stockRestockDate` DATE NULL DEFAULT NULL;

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
  PRIMARY KEY (`id`)
);

