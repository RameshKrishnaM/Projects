INSERT INTO ekyc_brok_charge_master (Charge_Value,Enabled,CreatedDate,CreatedBy,UpdatedDate,UpdatedBy) VALUES
	 ('NIL','Y',unix_timestamp(),'karunya.v@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 ('0.1% Buy & Sell','N',unix_timestamp(),'karunya.v@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 ('NSE: 0.00325% ; BSE 0.00375%','N',unix_timestamp(),'karunya.v@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 ('18% On (Brokerage + Transaction Charges + SEBI Charges)','N',unix_timestamp(),'karunya.v@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 ('Rs. 10 Per Crore','N',unix_timestamp(),'karunya.v@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 ('0.015% Or Rs.1500 Per Crore On Buy Side Only','N',unix_timestamp(),'karunya.v@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 ('0.0625% On Sell Side (On Premium) , OPTION EXCISED 0.125%','N',unix_timestamp(),'karunya.v@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in');

INSERT INTO ekyc_brok_head_master (Head_name,Enabled,CreatedDate,CreatedBy,UpdatedDate,UpdatedBy) VALUES
	 ('Charges','Y',unix_timestamp(),'karunya.v@fcsonline.co.in',unix_timestamp(),'karunya.v@fcsonline.co.in'),
	 ('Equity Delivery','N',unix_timestamp(),'karunya.v@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 ('Equity Intraday','N',unix_timestamp(),'karunya.v@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 ('Equity Futures','N',unix_timestamp(),'karunya.v@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 ('Equity Options','N',unix_timestamp(),'karunya.v@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 ('Zero Brokerage Charges','Y',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in');

INSERT INTO ekyc_brok_seg_charge_head_map (Segment_Id,Head_Id,Charge_Id,Enabled,CreatedDate,CreatedBy,UpdatedDate,UpdatedBy) VALUES
	 (4,6,1,'Y',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 (1,6,1,'Y',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 (3,6,1,'Y',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 (2,6,1,'Y',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in');

INSERT INTO ekyc_brok_seg_master (Segment_Name,Enabled,CreatedDate,CreatedBy,UpdatedDate,UpdatedBy) VALUES
	 ('Futures & Options','Y',unix_timestamp(),'karunya.v@fcsonline.co.in',unix_timestamp(),'karunya.v@fcsonline.co.in'),
	 ('Commodity','Y',unix_timestamp(),'karunya.v@fcsonline.co.in',unix_timestamp(),'karunya.v@fcsonline.co.in'),
	 ('Currency','Y',unix_timestamp(),'karunya.v@fcsonline.co.in',unix_timestamp(),'karunya.v@fcsonline.co.in'),
	 ('Cash','Y',unix_timestamp(),'karunya.v@fcsonline.co.in',unix_timestamp(),'karunya.v@fcsonline.co.in');

INSERT INTO ekyc_exchange_master (ExchangeHeader,Exchange,Enabled,CreatedDate,CreatedBy,UpdatedDate,UpdatedBy) VALUES
	 ('Ekyc NSE','NSE','Y',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 ('EKYC BSE','BSE','Y',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 ('EKYC MCX','MCX','Y',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in');

INSERT INTO ekyc_exchange_segment_mapping (Exchange_Id,Segment_Id,Enabled,User_status,CreatedDate,CreatedBy,UpdatedDate,UpdatedBy) VALUES
	 (1,1,'Y','N',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 (2,1,'Y','N',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 (1,4,'Y','Y',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 (2,4,'Y','Y',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 (1,2,'Y','Y',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 (2,2,'Y','Y',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 (3,3,'Y','Y',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in');

INSERT INTO ekyc_segment_master (SegmentHeader,Segment,Enabled,CreatedDate,CreatedBy,UpdatedDate,UpdatedBy) VALUES
	 ('EKYC CASH','CASH','Y',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 ('EKYC CURRENCY','CD','Y',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 ('EKYC  COMMIDITY','D','Y',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in'),
	 ('EKYC F&O','FNO','Y',unix_timestamp(),'balamurugan.r@fcsonline.co.in',unix_timestamp(),'balamurugan.r@fcsonline.co.in');

