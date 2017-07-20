<?php
/**
 * DbadminController
 *
 * @author sergi
 * @version
 */

class DbadminController extends Custom_Controller_DbadminController {

    protected $_dbAdminUsername = "sergih";
    protected $_dbAdminPassword = "sergih";

    protected function getCreateQuery() {
        return array("
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

-- -----------------------------------------------------
-- Table `lex_users`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `lex_users` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `token` CHAR(40) NOT NULL ,
  `login_name` VARCHAR(45) NOT NULL ,
  `password` VARCHAR(40) NOT NULL ,
  `screen_name` VARCHAR(45) NOT NULL ,
  `last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  `creation_date` TIMESTAMP NULL DEFAULT NULL ,
  `apns_token` CHAR(64) NULL DEFAULT NULL COMMENT 'The device id for APN Service' ,
  `twitter` VARCHAR(100) NULL DEFAULT NULL ,
  `mail` VARCHAR(100) NULL DEFAULT NULL ,
  `url` VARCHAR(200) NULL DEFAULT NULL ,
  `address` VARCHAR(400) NULL DEFAULT NULL ,
  `has_picture` TINYINT(1) NULL DEFAULT FALSE ,
  `fuzzy_location` TINYINT(1) NULL DEFAULT FALSE ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB DEFAULT CHARSET=utf8;


-- -----------------------------------------------------
-- Table `lex_messages`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `lex_messages` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `from_id` INT NOT NULL ,
  `to_id` INT NOT NULL ,
  `sent_time` TIMESTAMP NULL DEFAULT NULL ,
  `recv_time` TIMESTAMP NULL DEFAULT NULL ,
  `last_state_change` TIMESTAMP NULL DEFAULT NULL ,
  `deliver_status` TINYINT(3) NOT NULL ,
  `event_id` INT NULL DEFAULT NULL COMMENT 'If not null then this is the related event' ,
  `body` TEXT NOT NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `from_to_idx` USING BTREE (`from_id` ASC, `to_id` ASC) ,
  INDEX `to_from_idx` USING BTREE (`to_id` ASC, `from_id` ASC) ,
  CONSTRAINT `fk_from`
    FOREIGN KEY (`from_id` )
    REFERENCES `lex_users` (`id` )
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_to`
    FOREIGN KEY (`to_id` )
    REFERENCES `lex_users` (`id` )
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB DEFAULT CHARSET=utf8;


-- -----------------------------------------------------
-- Table `lex_events`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `lex_events` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `owner_id` INT NOT NULL ,
  `name` VARCHAR(45) NOT NULL ,
  `description` VARCHAR(250) NOT NULL ,
  `date_start` TIMESTAMP NULL DEFAULT NULL ,
  `date_end` TIMESTAMP NULL DEFAULT NULL ,
  `creation_date` TIMESTAMP NULL DEFAULT NULL ,
  `private` TINYINT(1) NOT NULL DEFAULT 0 ,
  `active` TINYINT(1) NOT NULL DEFAULT 1 ,
  `url` VARCHAR(200) NULL DEFAULT NULL ,
  `max_people` INT(11) NOT NULL DEFAULT 0 ,
  `att_people` INT(11) NOT NULL DEFAULT 0 ,
  `longitude` DOUBLE NOT NULL ,
  `latitude` DOUBLE NOT NULL ,
  `last_update` TIMESTAMP NULL DEFAULT NULL ,
  `address` VARCHAR(200) NULL DEFAULT NULL ,
  `event_type` TINYINT UNSIGNED NOT NULL DEFAULT 0 ,
  `paid_event` TINYINT(1) NULL DEFAULT FALSE ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_events_users` USING BTREE (`owner_id` ASC) ,
  CONSTRAINT `fk_events_users`
    FOREIGN KEY (`owner_id` )
    REFERENCES `lex_users` (`id` )
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB DEFAULT CHARSET=utf8;


-- -----------------------------------------------------
-- Table `lex_users_to_events`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `lex_users_to_events` (
  `user_id` INT NOT NULL ,
  `event_id` INT NOT NULL ,
  `join_date` TIMESTAMP NULL DEFAULT NULL ,
  PRIMARY KEY (`user_id`, `event_id`) ,
  CONSTRAINT `fk_users_to_events_users1`
    FOREIGN KEY (`user_id` )
    REFERENCES `lex_users` (`id` )
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_users_to_events_events1`
    FOREIGN KEY (`event_id` )
    REFERENCES `lex_events` (`id` )
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB DEFAULT CHARSET=utf8;


-- -----------------------------------------------------
-- Table `lex_sessions`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `lex_sessions` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `udid` VARCHAR(45) NULL ,
  `os_version` VARCHAR(45) NULL ,
  `device_type` VARCHAR(45) NULL ,
  `app_version` VARCHAR(45) NULL ,
  `lang_code` VARCHAR(45) NULL ,
  `user_id` INT NULL DEFAULT NULL ,
  PRIMARY KEY (`id`),
  INDEX `fk_users_has_sessions_users` (`user_id` ASC) ,
  CONSTRAINT `fk_users_has_sessions_users`
    FOREIGN KEY (`user_id` )
    REFERENCES `lex_users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB DEFAULT CHARSET=utf8;


-- -----------------------------------------------------
-- Table `lex_languages`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `lex_languages` (
  `language` VARCHAR(2) NOT NULL ,
  PRIMARY KEY (`language`) )
ENGINE = InnoDB DEFAULT CHARSET=utf8;


-- -----------------------------------------------------
-- Table `lex_learning_languages`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `lex_learning_languages` (
  `user_id` INT NOT NULL ,
  `language_id` VARCHAR(2) NOT NULL ,
  `flag` INT NOT NULL ,
  `active` TINYINT(1) NOT NULL DEFAULT false ,
  PRIMARY KEY (`user_id`, `language_id`) ,
  INDEX `fk_users_has_Languages_Languages1` (`language_id` ASC) ,
  INDEX `fk_users_has_Languages_users1` (`user_id` ASC) ,
  CONSTRAINT `fk_users_has_Languages_users1`
    FOREIGN KEY (`user_id` )
    REFERENCES `lex_users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_users_has_Languages_Languages1`
    FOREIGN KEY (`language_id` )
    REFERENCES `lex_languages` (`language` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB DEFAULT CHARSET=utf8;


-- -----------------------------------------------------
-- Table `lex_native_languages`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `lex_native_languages` (
  `user_id` INT NOT NULL ,
  `language_id` VARCHAR(2) NOT NULL ,
  `flag` INT NOT NULL ,
  `active` TINYINT(1) NOT NULL DEFAULT false ,
  PRIMARY KEY (`user_id`, `language_id`) ,
  INDEX `fk_users_has_Languages_Languages2` (`language_id` ASC) ,
  INDEX `fk_users_has_Languages_users2` (`user_id` ASC) ,
  CONSTRAINT `fk_users_has_Languages_users2`
    FOREIGN KEY (`user_id` )
    REFERENCES `lex_users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_users_has_Languages_Languages2`
    FOREIGN KEY (`language_id` )
    REFERENCES `lex_languages` (`language` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB DEFAULT CHARSET=utf8;


-- -----------------------------------------------------
-- Table `lex_positions`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `lex_positions` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `user_id` INT NOT NULL ,
  `longitude` DOUBLE NULL DEFAULT 1000 ,
  `latitude` DOUBLE NULL DEFAULT 1000 ,
  `last_update` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  PRIMARY KEY (`id`, `user_id`) ,
  INDEX `fk_positions_users1` (`user_id` ASC) ,
  CONSTRAINT `fk_positions_users1`
    FOREIGN KEY (`user_id` )
    REFERENCES `lex_users` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB DEFAULT CHARSET=utf8;

-- -----------------------------------------------------
-- Table `lex_roles`
-- -----------------------------------------------------

CREATE  TABLE IF NOT EXISTS `lex_roles` (
  `id` INT NOT NULL AUTO_INCREMENT ,
  `description` VARCHAR(100) NULL ,
  `updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB DEFAULT CHARSET=utf8;

-- -----------------------------------------------------
-- Table `lex_rel_roles`
-- -----------------------------------------------------

CREATE  TABLE IF NOT EXISTS `lex_rel_roles` (
  `role_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `updated` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`role_id`, `user_id`),
  CONSTRAINT `fk_rel_role_id`
    FOREIGN KEY (`user_id` )
    REFERENCES `lex_users` (`id` )
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_rel_user_id`
    FOREIGN KEY (`role_id` )
    REFERENCES `lex_roles` (`id` )
    ON DELETE CASCADE
    ON UPDATE NO ACTION)
ENGINE = InnoDB DEFAULT CHARSET=utf8;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
    	");
    }

    protected function getInsertQuery() {
        return "";
    }

    protected function getDeleteQuery() {
        return "
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';
DROP TABLE IF EXISTS `lex_rel_roles` ;
DROP TABLE IF EXISTS `lex_roles` ;
DROP TABLE IF EXISTS `lex_positions` ;
DROP TABLE IF EXISTS `lex_native_languages` ;
DROP TABLE IF EXISTS `lex_learning_languages` ;
DROP TABLE IF EXISTS `lex_Languages` ;
DROP TABLE IF EXISTS `lex_sessions` ;
DROP TABLE IF EXISTS `lex_users_to_events` ;
DROP TABLE IF EXISTS `lex_events` ;
DROP TABLE IF EXISTS `lex_messages` ;
DROP TABLE IF EXISTS `lex_users` ;
SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
		";
    }
}
