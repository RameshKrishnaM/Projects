INSERT INTO ekyc_router_info (Router_Name,Router_EndPoint,`Desc`,OldPosition,NewPosition,CreatedBy,CreatedDate,UpdatedBy,UpdatedDate) VALUES
	 ('PanDetails','/Pan-Details','PanDetails',1,1,'ekyc',unix_timestamp(),'ekyc',unix_timestamp()),
	 ('AddressVerification','/Address-Verification','AddressVerification',2,2,'ekyc',unix_timestamp(),'ekyc',unix_timestamp()),
	 ('ProfileDetails','/Profile-Details','ProfileDetails',3,3,'ekyc',unix_timestamp(),'ekyc',unix_timestamp()),
	 ('NomineeDetails','/Nominee-Details','NomineeDetails',4,4,'ekyc',unix_timestamp(),'ekyc',unix_timestamp()),
	 ('BankDetails','/Bank-Details','BankDetails',5,5,'ekyc',unix_timestamp(),'ekyc',unix_timestamp()),
	 ('DematDetails','/Demat-Details','DematDetails',6,6,'ekyc',unix_timestamp(),'ekyc',unix_timestamp()),
	 ('IPV','/IPV','IPV',7,7,'ekyc',unix_timestamp(),'ekyc',unix_timestamp()),
	 ('DocumentUpload','/Document-Upload','DocumentUpload',8,8,'ekyc',unix_timestamp(),'ekyc',unix_timestamp()),
	 ('ReviewDetails','/Review-Details','ReviewDetails',9,9,'ekyc',unix_timestamp(),'ekyc',unix_timestamp());
