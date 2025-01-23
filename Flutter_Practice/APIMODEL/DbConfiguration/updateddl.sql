CREATE TABLE `ekyc_version_controller` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(100) DEFAULT NULL,
  `os` varchar(50) DEFAULT NULL,
  `force_update` char(1) DEFAULT NULL,
  `version` varchar(50) DEFAULT NULL,
  `status` char(1) DEFAULT NULL,
  `createdBy` varchar(50) DEFAULT NULL,
  `createdDate` bigint(20) DEFAULT NULL,
  `updatedBy` varchar(50) DEFAULT NULL,
  `updatedDate` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;

UPDATE riskdisclosure_master
SET contentType='Risk Disclosure'
WHERE id=1;

UPDATE riskdisclosure_master
SET contentType='Politically Exposed Person'
WHERE id=2;

INSERT INTO ekyc_version_controller (url,os,force_update,version,status,createdBy,createdDate,updatedBy,updatedDate) VALUES
	 ('https://flattrade.in/','Android','Y','1.0.0','Y','ayyanar.b@fcsonline.co.in',unix_timestamp(),'ayyanar.b@fcsonline.co.in',unix_timestamp()),
	 ('https://flattrade.in/','iOS','Y','1.0.0','Y','ayyanar.b@fcsonline.co.in',unix_timestamp(),'ayyanar.b@fcsonline.co.in',unix_timestamp());
