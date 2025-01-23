-- acceptence_history definition

CREATE TABLE acceptence_history (
  id int(11) NOT NULL AUTO_INCREMENT,
  Request_Uid varchar(100) DEFAULT NULL,
  deviceType varchar(100) DEFAULT NULL,
  deviceIp varchar(100) DEFAULT NULL,
  contentId int(11) DEFAULT NULL,
  acceptDateTime datetime DEFAULT NULL,
  acceptenceType varchar(15) DEFAULT NULL,
  CreatedBy varchar(100) DEFAULT NULL,
  CreatedDate datetime DEFAULT NULL,
  updatedBy varchar(100) DEFAULT NULL,
  updatedDate datetime DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;

-- boid_data_collection definition

CREATE TABLE boid_data_collection (
  id int(11) NOT NULL AUTO_INCREMENT,
  bo_id varchar(25) DEFAULT NULL,
  request_uid varchar(50) DEFAULT NULL,
  client_id varchar(20) DEFAULT NULL,
  mapping_flag char(1) DEFAULT NULL,
  mapping_date bigint(20) DEFAULT NULL,
  success_flag char(1) DEFAULT NULL,
  success_date bigint(20) DEFAULT NULL,
  createdBy varchar(50) DEFAULT NULL,
  createdDate bigint(20) DEFAULT NULL,
  updatedBy varchar(50) DEFAULT NULL,
  updatedDate bigint(20) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY boid_data_collection_unique (bo_id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- cdsl_boupload_log definition

CREATE TABLE cdsl_boupload_log (
  id int(11) NOT NULL AUTO_INCREMENT,
  requestUid varchar(100) DEFAULT NULL,
  Refid varchar(30) DEFAULT NULL,
  raw_file_name varchar(50) DEFAULT NULL,
  raw_doc_id varchar(10) DEFAULT NULL,
  enc_file_name varchar(50) DEFAULT NULL,
  enc_doc_id varchar(10) DEFAULT NULL,
  zip_file_doc_id varchar(50) DEFAULT NULL,
  upload_status varchar(100) DEFAULT NULL,
  enquiry_staus varchar(100) DEFAULT NULL,
  response_status varchar(20) DEFAULT NULL,
  acknowledgemnet_id varchar(50) DEFAULT NULL,
  upload_response varchar(100) DEFAULT NULL,
  active_state varchar(1) DEFAULT NULL,
  response_type varchar(25) DEFAULT NULL,
  error_message longtext DEFAULT NULL,
  CreatedBy varchar(100) NOT NULL,
  CreatedDate bigint(20) NOT NULL,
  UpdatedBy varchar(100) NOT NULL,
  UpdatedDate bigint(20) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- cdsl_dp59_log definition

CREATE TABLE cdsl_dp59_log (
  id int(11) NOT NULL AUTO_INCREMENT,
  requestUid varchar(50) DEFAULT NULL,
  acknowledgement_id varchar(50) DEFAULT NULL,
  file_name varchar(50) DEFAULT NULL,
  uploade_file_name varchar(50) DEFAULT NULL,
  Response longtext DEFAULT NULL,
  status varchar(20) DEFAULT NULL,
  error_message varchar(240) DEFAULT NULL,
  createdBy varchar(50) DEFAULT NULL,
  createdDate bigint(20) DEFAULT NULL,
  updatedBy varchar(50) DEFAULT NULL,
  updatedDate bigint(20) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- cdsl_dpa2_log definition

CREATE TABLE cdsl_dpa2_log (
  id int(11) NOT NULL AUTO_INCREMENT,
  requestUid varchar(50) DEFAULT NULL,
  acknowledgement_id varchar(30) DEFAULT NULL,
  file_name varchar(50) DEFAULT NULL,
  uploade_file_name varchar(50) DEFAULT NULL,
  line_no int(11) DEFAULT NULL,
  date_generated varchar(20) DEFAULT NULL,
  time_generated varchar(20) DEFAULT NULL,
  error_message varchar(100) DEFAULT NULL,
  createdBy varchar(50) DEFAULT NULL,
  createdDate bigint(20) DEFAULT NULL,
  updatedBy varchar(50) DEFAULT NULL,
  updatedDate bigint(20) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- cdsl_pincode_master definition

CREATE TABLE cdsl_pincode_master (
  id int(11) NOT NULL AUTO_INCREMENT,
  Pincode varchar(100) NOT NULL,
  pincode_prefix varchar(100) NOT NULL,
  city_name varchar(100) NOT NULL,
  city_sequence_no varchar(100) NOT NULL,
  StateName varchar(100) NOT NULL,
  Status_Del_Flag varchar(100) NOT NULL,
  CreatedDate bigint(20) NOT NULL,
  CreatedBy varchar(100) NOT NULL,
  UpdatedDate bigint(20) NOT NULL,
  UpdatedBy varchar(100) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;



-- document_sign_coordinates definition

CREATE TABLE document_sign_coordinates (
  id int(11) NOT NULL AUTO_INCREMENT,
  DocType varchar(100) NOT NULL,
  PageNo varchar(100) NOT NULL,
  llx varchar(100) NOT NULL,
  lly varchar(100) NOT NULL,
  urx varchar(100) NOT NULL,
  ury varchar(100) NOT NULL,
  CreatedDate datetime DEFAULT NULL,
  CreatedBy varchar(100) DEFAULT NULL,
  UpdatedDate datetime DEFAULT NULL,
  UpdatedBy varchar(100) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_address definition

CREATE TABLE ekyc_address (
  id int(11) NOT NULL AUTO_INCREMENT,
  Request_Uid varchar(75) DEFAULT NULL,
  Source_Of_Address varchar(20) DEFAULT NULL,
  PerAddress1 varchar(100) DEFAULT NULL,
  PerAddress2 varchar(100) DEFAULT NULL,
  PerAddress3 varchar(100) DEFAULT NULL,
  PerCity varchar(50) DEFAULT NULL,
  PerState varchar(30) DEFAULT NULL,
  PerPincode int(6) DEFAULT NULL,
  PerCountry varchar(50) DEFAULT NULL,
  SameAsPermenentAddress char(1) DEFAULT NULL,
  CorAddress1 varchar(100) DEFAULT NULL,
  CorAddress2 varchar(100) DEFAULT NULL,
  CorAddress3 varchar(100) DEFAULT NULL,
  CorCity varchar(50) DEFAULT NULL,
  CorState varchar(30) DEFAULT NULL,
  CorPincode int(6) DEFAULT NULL,
  CorCountry varchar(50) DEFAULT NULL,
  dateofProofIssue varchar(19) DEFAULT NULL,
  proofType varchar(100) DEFAULT NULL,
  Proof_No varchar(100) DEFAULT NULL,
  ProofOfIssue varchar(100) DEFAULT NULL,
  ProofExpriyDate varchar(100) DEFAULT NULL,
  Proof_Doc_Id1 varchar(100) DEFAULT NULL,
  Proof_Doc_Id2 varchar(100) DEFAULT NULL,
  Kra_docid varchar(30) DEFAULT NULL,
  Digilocker_docid varchar(30) DEFAULT NULL,
  U_PerAddress1 varchar(100) DEFAULT NULL,
  U_PerAddress2 varchar(100) DEFAULT NULL,
  U_PerAddress3 varchar(100) DEFAULT NULL,
  U_CorAddress1 varchar(100) DEFAULT NULL,
  U_CorAddress2 varchar(100) DEFAULT NULL,
  U_CorAddress3 varchar(100) DEFAULT NULL,
  Session_Id varchar(75) DEFAULT NULL,
  KraVerified char(1) DEFAULT NULL,
  KRA_Reference_Id varchar(50) DEFAULT NULL,
  KraStatusCode varchar(100) DEFAULT NULL,
  Digilockerreferenceid int(11) DEFAULT NULL,
  Updated_Session_Id varchar(75) DEFAULT NULL,
  CreatedDate bigint(20) NOT NULL,
  UpdatedDate bigint(20) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_attachmentlog_history definition

CREATE TABLE ekyc_attachmentlog_history (
  id int(11) NOT NULL AUTO_INCREMENT,
  Reqid varchar(100) NOT NULL,
  Filetype varchar(30) DEFAULT NULL,
  isActive char(1) DEFAULT NULL,
  DocId varchar(30) DEFAULT NULL,
  CreatedDate bigint(20) DEFAULT NULL,
  CreatedBy varchar(30) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_attachments definition

CREATE TABLE ekyc_attachments (
  id int(11) NOT NULL AUTO_INCREMENT,
  Request_id varchar(100) DEFAULT NULL,
  Bank_proof varchar(20) DEFAULT NULL,
  Income_proof varchar(20) DEFAULT NULL,
  Signature varchar(20) DEFAULT NULL,
  Pan_proof varchar(20) DEFAULT NULL,
  Kra_XML_Id varchar(20) DEFAULT NULL,
  Digilocker_XML_Id varchar(20) DEFAULT NULL,
  GenerateNew_KRAXML_file varchar(20) DEFAULT NULL,
  KRA_agency_Name varchar(20) DEFAULT NULL,
  KRADownload_file_docid varchar(20) DEFAULT NULL,
  KRADownload_file_Status varchar(20) DEFAULT NULL,
  AadhaarimageDocId varchar(20) DEFAULT NULL,
  Income_prooftype varchar(20) DEFAULT NULL,
  Session_Id varchar(100) DEFAULT NULL,
  UpdatedSesion_Id varchar(100) DEFAULT NULL,
  CreatedDate bigint(20) DEFAULT NULL,
  UpdatedDate bigint(20) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_bank definition

CREATE TABLE ekyc_bank (
  id int(11) NOT NULL AUTO_INCREMENT,
  Request_Uid varchar(75) NOT NULL,
  Acc_Number varchar(50) DEFAULT NULL,
  Acctype varchar(100) DEFAULT NULL,
  IFSC varchar(15) DEFAULT NULL,
  MICR varchar(11) DEFAULT NULL,
  Bank_Name varchar(100) DEFAULT NULL,
  Bank_Branch varchar(100) DEFAULT NULL,
  Bank_Address longtext DEFAULT NULL,
  U_BankAddress longtext DEFAULT NULL,
  Bank_Proof_Doc_Id int(11) DEFAULT NULL,
  Bank_Proof_Type varchar(5) DEFAULT NULL,
  Penny_Drop varchar(10) DEFAULT NULL,
  Penny_Drop_Status varchar(10) DEFAULT NULL,
  Status varchar(10) DEFAULT NULL,
  Name_As_Per_PennyDrop varchar(100) DEFAULT NULL,
  Session_Id varchar(75) DEFAULT NULL,
  Updated_Session_Id varchar(75) DEFAULT NULL,
  CreatedDate bigint(20) DEFAULT NULL,
  UpdatedDate bigint(20) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_brok_charge_master definition

CREATE TABLE ekyc_brok_charge_master (
  id int(11) NOT NULL AUTO_INCREMENT,
  Charge_Value varchar(255) NOT NULL,
  Enabled char(1) NOT NULL,
  CreatedDate bigint(20) NOT NULL,
  CreatedBy varchar(100) NOT NULL,
  UpdatedDate bigint(20) NOT NULL,
  UpdatedBy varchar(100) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_brok_head_master definition

CREATE TABLE ekyc_brok_head_master (
  id int(11) NOT NULL AUTO_INCREMENT,
  Head_name varchar(50) NOT NULL,
  Enabled char(1) NOT NULL,
  CreatedDate bigint(20) NOT NULL,
  CreatedBy varchar(100) NOT NULL,
  UpdatedDate bigint(20) NOT NULL,
  UpdatedBy varchar(100) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_brok_seg_charge_head_map definition

CREATE TABLE ekyc_brok_seg_charge_head_map (
  id int(11) NOT NULL AUTO_INCREMENT,
  Segment_Id int(11) NOT NULL,
  Head_Id int(11) NOT NULL,
  Charge_Id int(11) NOT NULL,
  Enabled char(1) NOT NULL,
  CreatedDate bigint(20) NOT NULL,
  CreatedBy varchar(100) NOT NULL,
  UpdatedDate bigint(20) NOT NULL,
  UpdatedBy varchar(100) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_brok_seg_master definition

CREATE TABLE ekyc_brok_seg_master (
  id int(11) NOT NULL AUTO_INCREMENT,
  Segment_Name varchar(50) NOT NULL,
  Enabled char(1) NOT NULL,
  CreatedDate bigint(20) NOT NULL,
  CreatedBy varchar(100) NOT NULL,
  UpdatedDate bigint(20) NOT NULL,
  UpdatedBy varchar(100) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_brokerage definition

CREATE TABLE ekyc_brokerage (
  id int(11) NOT NULL AUTO_INCREMENT,
  Request_Uid varchar(75) DEFAULT NULL,
  Mapping varchar(20) DEFAULT NULL,
  Enabled varchar(20) DEFAULT NULL,
  Session_Id varchar(75) DEFAULT NULL,
  Updated_Session_Id varchar(75) DEFAULT NULL,
  CreatedDate bigint(20) NOT NULL,
  UpdatedDate bigint(20) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_comments_and_config_mapping definition

CREATE TABLE ekyc_comments_and_config_mapping (
  id int(11) NOT NULL AUTO_INCREMENT,
  CommentCategory_Id varchar(50) NOT NULL,
  Comments_Id varchar(200) NOT NULL,
  CommentMappingStatus char(1) NOT NULL,
  CreatedDate bigint(20) NOT NULL,
  CreatedBy varchar(100) NOT NULL,
  UpdatedDate bigint(20) NOT NULL,
  UpdatedBy varchar(100) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_comments_category_config definition

CREATE TABLE ekyc_comments_category_config (
  id int(11) NOT NULL AUTO_INCREMENT,
  CommentCategory varchar(50) NOT NULL,
  CommentCategoryStatus char(1) NOT NULL,
  CreatedDate bigint(20) NOT NULL,
  CreatedBy varchar(100) NOT NULL,
  UpdatedDate bigint(20) NOT NULL,
  UpdatedBy varchar(100) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_comments_config definition

CREATE TABLE ekyc_comments_config (
  id int(11) NOT NULL AUTO_INCREMENT,
  Comments varchar(255) NOT NULL,
  CommentType varchar(100) NOT NULL,
  CommentStatus char(50) NOT NULL,
  CreatedDate bigint(20) NOT NULL,
  CreatedBy varchar(100) NOT NULL,
  UpdatedDate bigint(20) NOT NULL,
  UpdatedBy varchar(100) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_demat_details definition

CREATE TABLE ekyc_demat_details (
  id int(11) NOT NULL AUTO_INCREMENT,
  requestuid varchar(75) DEFAULT NULL,
  DP_scheme varchar(30) DEFAULT NULL,
  DIS char(1) DEFAULT NULL,
  EDIS char(1) DEFAULT NULL,
  Created_Session_Id varchar(75) DEFAULT NULL,
  Updated_Session_Id varchar(75) DEFAULT NULL,
  CreatedDate bigint(20) DEFAULT NULL,
  UpdatedData bigint(20) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_digioesign_request_status definition

CREATE TABLE ekyc_digioesign_request_status (
  id int(11) NOT NULL AUTO_INCREMENT,
  Request_Uid varchar(75) DEFAULT NULL,
  esign_requestid varchar(75) DEFAULT NULL,
  accessToken varchar(75) DEFAULT NULL,
  validity datetime DEFAULT NULL,
  req_status char(1) DEFAULT NULL,
  Session_Id varchar(75) DEFAULT NULL,
  Updated_Session_Id varchar(75) DEFAULT NULL,
  CreatedDate bigint(20) DEFAULT NULL,
  UpdatedDate bigint(20) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_exchange_master definition

CREATE TABLE ekyc_exchange_master (
  id int(11) NOT NULL AUTO_INCREMENT,
  ExchangeHeader varchar(100) DEFAULT NULL,
  Exchange varchar(15) NOT NULL,
  Enabled char(1) NOT NULL,
  CreatedDate bigint(20) NOT NULL,
  CreatedBy varchar(100) NOT NULL,
  UpdatedDate bigint(20) NOT NULL,
  UpdatedBy varchar(100) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_exchange_segment_mapping definition

CREATE TABLE ekyc_exchange_segment_mapping (
  id int(11) NOT NULL AUTO_INCREMENT,
  Exchange_Id int(11) NOT NULL,
  Segment_Id int(11) NOT NULL,
  Enabled char(1) NOT NULL,
  User_status char(1) DEFAULT NULL,
  CreatedDate bigint(20) NOT NULL,
  CreatedBy varchar(100) NOT NULL,
  UpdatedDate bigint(20) NOT NULL,
  UpdatedBy varchar(100) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_ipv definition

CREATE TABLE ekyc_ipv (
  id int(11) NOT NULL AUTO_INCREMENT,
  Request_Uid varchar(75) DEFAULT NULL,
  ipv_otp varchar(6) DEFAULT NULL,
  video_Doc_Id varchar(20) DEFAULT NULL,
  image_Doc_Id varchar(20) DEFAULT NULL,
  latitude varchar(20) DEFAULT NULL,
  longitude varchar(20) DEFAULT NULL,
  Current_Address varchar(100) DEFAULT NULL,
  time_stamp varchar(20) DEFAULT NULL,
  Session_Id varchar(75) DEFAULT NULL,
  Updated_Session_Id varchar(75) DEFAULT NULL,
  CreatedDate bigint(20) DEFAULT NULL,
  UpdatedDate bigint(20) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_ipv_link definition

CREATE TABLE ekyc_ipv_link (
  id int(11) NOT NULL AUTO_INCREMENT,
  Request_Uid varchar(75) DEFAULT NULL,
  ipv_session varchar(75) DEFAULT NULL,
  use_status varchar(1) DEFAULT NULL,
  complit_Status varchar(1) DEFAULT NULL,
  Session_Id varchar(75) DEFAULT NULL,
  Updated_Session_Id varchar(75) DEFAULT NULL,
  Createdtime bigint(20) DEFAULT NULL,
  Updatedtime bigint(20) DEFAULT NULL,
  Expiretime bigint(20) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_ipv_request_status definition

CREATE TABLE ekyc_ipv_request_status (
  id int(11) NOT NULL AUTO_INCREMENT,
  Request_Uid varchar(75) DEFAULT NULL,
  ipv_requestid varchar(75) DEFAULT NULL,
  accessToken varchar(75) DEFAULT NULL,
  validity datetime DEFAULT NULL,
  req_status char(1) DEFAULT NULL,
  Session_Id varchar(75) DEFAULT NULL,
  Updated_Session_Id varchar(75) DEFAULT NULL,
  CreatedDate bigint(20) DEFAULT NULL,
  UpdatedDate bigint(20) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_nominee_details definition

CREATE TABLE ekyc_nominee_details (
  Id bigint(20) NOT NULL AUTO_INCREMENT,
  Request_Table_Id int(11) NOT NULL,
  RequestId varchar(50) NOT NULL,
  Nominee_Title varchar(10) DEFAULT NULL,
  NomineeName varchar(50) NOT NULL,
  NomineeRelationship varchar(50) NOT NULL,
  NomineeShare int(11) NOT NULL,
  NomineeDOB varchar(50) NOT NULL,
  NomineeAddress1 varchar(100) NOT NULL,
  NomineeAddress2 varchar(100) NOT NULL,
  NomineeAddress3 varchar(100) DEFAULT NULL,
  U_NomineeAddress1 varchar(100) DEFAULT NULL,
  U_NomineeAddress2 varchar(100) DEFAULT NULL,
  U_NomineeAddress3 varchar(100) DEFAULT NULL,
  NomineeCity varchar(50) NOT NULL,
  NomineeState varchar(50) NOT NULL,
  NomineeCountry varchar(50) NOT NULL,
  NomineePincode varchar(20) NOT NULL,
  NomineeMobileNo varchar(20) NOT NULL,
  NomineeEmailId varchar(100) NOT NULL,
  NomineeProofOfIdentity varchar(50) NOT NULL,
  NomineeProofNumber varchar(50) NOT NULL,
  NomineeProofPlaceOfIssue varchar(100) DEFAULT NULL,
  NomineeProofDateOfIssue varchar(100) DEFAULT NULL,
  NomineeProofExpriyDate varchar(100) DEFAULT NULL,
  NomineeFileUploadDocIds varchar(50) NOT NULL,
  GuardianVisible varchar(1) NOT NULL,
  Guardian_Title varchar(10) DEFAULT NULL,
  GuardianName varchar(50) DEFAULT NULL,
  GuardianRelationship varchar(50) DEFAULT NULL,
  GuardianAddress1 varchar(100) DEFAULT NULL,
  GuardianAddress2 varchar(100) DEFAULT NULL,
  GuardianAddress3 varchar(100) DEFAULT NULL,
  U_GuardianAddress1 varchar(100) DEFAULT NULL,
  U_GuardianAddress2 varchar(100) DEFAULT NULL,
  U_GuardianAddress3 varchar(100) DEFAULT NULL,
  GuardianCity varchar(50) DEFAULT NULL,
  GuardianState varchar(50) DEFAULT NULL,
  GuardianCountry varchar(50) DEFAULT NULL,
  GuardianPincode varchar(20) DEFAULT NULL,
  GuardianMobileNo varchar(20) DEFAULT NULL,
  GuardianEmailId varchar(100) DEFAULT NULL,
  GuardianProofOfIdentity varchar(50) DEFAULT NULL,
  GuardianProofNumber varchar(50) DEFAULT NULL,
  GuardianProofPlaceOfIssue varchar(100) DEFAULT NULL,
  GuardianProofDateOfIssue varchar(100) DEFAULT NULL,
  GuardianProofExpriyDate varchar(100) DEFAULT NULL,
  GuardianFileUploadDocIds varchar(50) DEFAULT NULL,
  ActionState varchar(50) NOT NULL,
  deleteFlag tinyint(1) NOT NULL,
  Active tinyint(1) NOT NULL,
  CreatedBy varchar(100) NOT NULL,
  CreatedDate datetime NOT NULL,
  ModifiedBy varchar(100) NOT NULL,
  ModifiedDate datetime NOT NULL,
  PRIMARY KEY (Id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_onboarding_status definition

CREATE TABLE ekyc_onboarding_status (
  id int(11) NOT NULL AUTO_INCREMENT,
  Request_id varchar(75) DEFAULT NULL,
  Page_Name varchar(20) DEFAULT NULL,
  Status char(1) DEFAULT NULL,
  Created_Session_Id varchar(75) DEFAULT NULL,
  CreatedDate bigint(20) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_owner_history definition

CREATE TABLE ekyc_owner_history (
  id int(11) NOT NULL AUTO_INCREMENT,
  requestUid varchar(100) DEFAULT NULL,
  Owner varchar(100) DEFAULT NULL,
  Status varchar(100) DEFAULT NULL,
  Reason varchar(250) DEFAULT NULL,
  CreatedBy varchar(100) DEFAULT NULL,
  CreatedDate bigint(20) DEFAULT NULL,
  UpdatedBy varchar(100) DEFAULT NULL,
  UpdatedDate bigint(20) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_personal definition

CREATE TABLE ekyc_personal (
  id int(11) NOT NULL AUTO_INCREMENT,
  Request_Uid varchar(75) DEFAULT NULL,
  Father_Title varchar(10) DEFAULT NULL,
  Father_SpouceName varchar(100) DEFAULT NULL,
  Mother_Title varchar(10) DEFAULT NULL,
  Mother_Name varchar(100) DEFAULT NULL,
  Gender varchar(10) DEFAULT NULL,
  Occupation varchar(25) DEFAULT NULL,
  Occupation_Others varchar(50) DEFAULT NULL,
  Annual_Income varchar(50) DEFAULT NULL,
  Politically_Exposed char(1) DEFAULT NULL,
  Trading_Experience varchar(15) DEFAULT NULL,
  Edu_Qualification varchar(20) DEFAULT NULL,
  Education_Others varchar(100) DEFAULT NULL,
  Phone_Owner varchar(50) DEFAULT NULL,
  Phone_Owner_Name varchar(100) DEFAULT NULL,
  Email_Owner varchar(50) DEFAULT NULL,
  Email_Owner_Name varchar(100) DEFAULT NULL,
  Marital_Status varchar(15) DEFAULT NULL,
  Facta varchar(1) DEFAULT NULL,
  Nominee char(1) DEFAULT NULL,
  Session_Id varchar(75) DEFAULT NULL,
  Updated_Session_Id varchar(75) DEFAULT NULL,
  CreatedDate bigint(20) DEFAULT NULL,
  UpdatedDate bigint(20) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_request definition

CREATE TABLE ekyc_request (
  id int(11) NOT NULL AUTO_INCREMENT,
  Uid varchar(75) DEFAULT NULL,
  Client_Id varchar(10) DEFAULT NULL,
  bo_id varchar(25) DEFAULT NULL,
  applicationNo varchar(30) DEFAULT NULL,
  app varchar(30) DEFAULT NULL,
  Given_Name varchar(100) DEFAULT NULL,
  Phone varchar(10) DEFAULT NULL,
  Email varchar(100) DEFAULT NULL,
  Given_State varchar(20) DEFAULT NULL,
  Aadhar_Linked char(1) DEFAULT NULL,
  Pan varchar(10) DEFAULT NULL,
  AadhraNo varchar(100) DEFAULT NULL,
  Name_As_Per_Pan varchar(100) DEFAULT NULL,
  Name_As_Per_Aadhar varchar(100) DEFAULT NULL,
  NameonthePanCard varchar(100) DEFAULT NULL,
  DOB varchar(100) DEFAULT NULL,
  ValidPan_Status char(2) DEFAULT NULL,
  UtmSource varchar(100) DEFAULT NULL,
  UtmMedium varchar(100) DEFAULT NULL,
  UtmCampaign varchar(100) DEFAULT NULL,
  UtmContent varchar(100) DEFAULT NULL,
  gclid varchar(100) DEFAULT NULL,
  Created_Session_Id varchar(75) DEFAULT NULL,
  Updated_Session_Id varchar(75) DEFAULT NULL,
  CreatedDate bigint(20) DEFAULT NULL,
  UpdatedDate bigint(20) DEFAULT NULL,
  Form_Status varchar(20) DEFAULT NULL,
  Process_Status varchar(20) DEFAULT NULL,
  Owner varchar(100) DEFAULT NULL,
  Staff varchar(100) DEFAULT NULL,
  unsignedDocid varchar(10) DEFAULT NULL,
  eSignedDocid varchar(10) DEFAULT NULL,
  submitted_date bigint(20) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_router_info definition

CREATE TABLE ekyc_router_info (
  id int(11) NOT NULL AUTO_INCREMENT,
  Router_Name varchar(50) DEFAULT NULL,
  Router_EndPoint varchar(50) DEFAULT NULL,
  Desc varchar(100) DEFAULT NULL,
  OldPosition int(11) DEFAULT NULL,
  NewPosition int(11) DEFAULT NULL,
  CreatedBy varchar(75) DEFAULT NULL,
  CreatedDate bigint(20) DEFAULT NULL,
  UpdatedBy varchar(75) DEFAULT NULL,
  UpdatedDate bigint(20) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_segment_master definition

CREATE TABLE ekyc_segment_master (
  id int(11) NOT NULL AUTO_INCREMENT,
  SegmentHeader varchar(100) DEFAULT NULL,
  Segment varchar(50) NOT NULL,
  Enabled char(1) NOT NULL,
  CreatedDate bigint(20) NOT NULL,
  CreatedBy varchar(100) NOT NULL,
  UpdatedDate bigint(20) NOT NULL,
  UpdatedBy varchar(100) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_services definition

CREATE TABLE ekyc_services (
  id int(11) NOT NULL AUTO_INCREMENT,
  Request_Uid varchar(75) DEFAULT NULL,
  segement_id int(11) DEFAULT NULL,
  exchange_id int(11) DEFAULT NULL,
  Mapping varchar(20) DEFAULT NULL,
  Selected varchar(20) DEFAULT NULL,
  Session_Id varchar(75) DEFAULT NULL,
  Updated_Session_Id varchar(75) DEFAULT NULL,
  CreatedDate bigint(20) NOT NULL,
  UpdatedDate bigint(20) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_session definition

CREATE TABLE ekyc_session (
  Id int(11) NOT NULL AUTO_INCREMENT,
  requestuid varchar(75) NOT NULL,
  sessionid varchar(100) NOT NULL,
  createdtime bigint(20) NOT NULL,
  expiretime bigint(20) NOT NULL,
  realip varchar(100) DEFAULT NULL,
  forwardedip varchar(200) DEFAULT NULL,
  method varchar(20) DEFAULT NULL,
  path varchar(240) DEFAULT NULL,
  host varchar(240) DEFAULT NULL,
  remoteaddr varchar(240) DEFAULT NULL,
  PRIMARY KEY (Id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- ekyc_staff_history definition

CREATE TABLE ekyc_staff_history (
  id int(11) NOT NULL AUTO_INCREMENT,
  requestUid varchar(100) DEFAULT NULL,
  Staff varchar(100) DEFAULT NULL,
  Status varchar(100) DEFAULT NULL,
  Reason varchar(250) DEFAULT NULL,
  CreatedBy varchar(100) DEFAULT NULL,
  CreatedDate bigint(20) DEFAULT NULL,
  UpdatedBy varchar(100) DEFAULT NULL,
  UpdatedDate bigint(20) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;

-- kra_insert_update_log definition

CREATE TABLE kra_insert_update_log (
  id int(11) NOT NULL AUTO_INCREMENT,
  ReqId varchar(100) NOT NULL,
  RefId varchar(30) DEFAULT NULL,
  AckId varchar(30) DEFAULT NULL,
  ProcessType varchar(100) DEFAULT NULL,
  RequestJson longtext DEFAULT NULL,
  ResponseJson longtext DEFAULT NULL,
  Status varchar(100) DEFAULT NULL,
  ErrorType varchar(50) DEFAULT NULL,
  ErrorMessage longtext DEFAULT NULL,
  CreatedDate bigint(20) NOT NULL,
  CreatedBy varchar(100) DEFAULT NULL,
  UpdatedDate bigint(20) NOT NULL,
  UpdatedBy varchar(100) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- lookup_additional_setup definition

CREATE TABLE lookup_additional_setup (
  id int(11) NOT NULL AUTO_INCREMENT,
  lookup_header_id int(10) NOT NULL,
  lookup_Type varchar(15) NOT NULL,
  createdBy varchar(100) DEFAULT NULL,
  createdDate datetime NOT NULL,
  updatedBy varchar(100) DEFAULT NULL,
  updatedDate datetime NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


-- lookup_additional_setup_details definition

CREATE TABLE lookup_additional_setup_details (
  id int(11) NOT NULL AUTO_INCREMENT,
  SetupId int(10) NOT NULL,
  FieldName varchar(15) NOT NULL,
  AttrType varchar(20) NOT NULL,
  DefaultValue varchar(100) DEFAULT NULL,
  Prompt varchar(100) NOT NULL,
  RequiredField varchar(1) NOT NULL,
  createdDate datetime NOT NULL,
  updatedDate datetime NOT NULL,
  createdBy varchar(100) DEFAULT NULL,
  updatedBy varchar(100) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


-- lookup_details definition

CREATE TABLE lookup_details (
  id int(11) NOT NULL AUTO_INCREMENT,
  headerid int(11) DEFAULT NULL,
  isScreenVisible char(1) DEFAULT NULL,
  DisplayOrder int(11) DEFAULT NULL,
  Code varchar(100) DEFAULT NULL,
  description longtext DEFAULT NULL,
  Attr1 varchar(100) DEFAULT NULL,
  Attr2 varchar(100) DEFAULT NULL,
  Attr3 varchar(100) DEFAULT NULL,
  Attr4 varchar(100) DEFAULT NULL,
  Attr5 varchar(100) DEFAULT NULL,
  Attr6 varchar(100) DEFAULT NULL,
  Attr7 varchar(100) DEFAULT NULL,
  Attr8 varchar(100) DEFAULT NULL,
  Attr9 varchar(100) DEFAULT NULL,
  Attr10 varchar(100) DEFAULT NULL,
  createdDate datetime NOT NULL,
  updatedDate datetime NOT NULL,
  createdBy varchar(100) DEFAULT NULL,
  updatedBy varchar(100) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;


-- lookup_header definition

CREATE TABLE lookup_header (
  id int(11) NOT NULL AUTO_INCREMENT,
  Code varchar(50) NOT NULL,
  description longtext NOT NULL,
  Attr1 varchar(100) DEFAULT NULL,
  Attr2 varchar(100) DEFAULT NULL,
  Attr3 varchar(100) DEFAULT NULL,
  Attr4 varchar(100) DEFAULT NULL,
  Attr5 varchar(100) DEFAULT NULL,
  Attr6 varchar(100) DEFAULT NULL,
  Attr7 varchar(100) DEFAULT NULL,
  Attr8 varchar(100) DEFAULT NULL,
  Attr9 varchar(100) DEFAULT NULL,
  Attr10 varchar(100) DEFAULT NULL,
  createdDate datetime NOT NULL,
  updatedDate datetime NOT NULL,
  createdBy varchar(100) DEFAULT NULL,
  updatedBy varchar(100) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- newekyc_attachmentview_history definition

CREATE TABLE newekyc_attachmentview_history (
  id int(11) NOT NULL AUTO_INCREMENT,
  requestUid varchar(100) NOT NULL,
  Stage varchar(50) NOT NULL,
  attachmentId varchar(10) NOT NULL,
  CreatedBy varchar(100) DEFAULT NULL,
  CreatedDate bigint(20) NOT NULL,
  UpdatedBy varchar(100) NOT NULL,
  UpdatedDate bigint(20) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- newekyc_comments_history definition

CREATE TABLE newekyc_comments_history (
  id int(11) NOT NULL AUTO_INCREMENT,
  requestUid varchar(100) NOT NULL,
  stage varchar(50) NOT NULL,
  comments longtext NOT NULL,
  commentstatusId int(11) NOT NULL,
  attachmentId int(11) DEFAULT NULL,
  role varchar(50) NOT NULL,
  replycommentId varchar(100) DEFAULT NULL,
  CreatedBy varchar(100) DEFAULT NULL,
  CreatedDate bigint(20) NOT NULL,
  UpdatedBy varchar(100) NOT NULL,
  UpdatedDate bigint(20) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- newekyc_commentstatus definition

CREATE TABLE newekyc_commentstatus (
  id int(11) NOT NULL AUTO_INCREMENT,
  requestUid varchar(100) NOT NULL,
  stage varchar(100) DEFAULT NULL,
  commentstatus varchar(100) DEFAULT NULL,
  CreatedBy varchar(100) DEFAULT NULL,
  CreatedDate varchar(100) DEFAULT NULL,
  UpdatedBy varchar(100) DEFAULT NULL,
  UpdatedDate varchar(100) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- newekyc_formstatus_history definition

CREATE TABLE newekyc_formstatus_history (
  id int(11) NOT NULL AUTO_INCREMENT,
  requestUid varchar(100) NOT NULL,
  stage varchar(50) DEFAULT NULL,
  status varchar(50) DEFAULT NULL,
  assignTo varchar(100) DEFAULT NULL,
  CreatedBy varchar(100) DEFAULT NULL,
  CreatedDate bigint(20) NOT NULL,
  UpdatedBy varchar(100) DEFAULT NULL,
  UpdatedDate bigint(20) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- newekyc_integration_history definition

CREATE TABLE newekyc_integration_history (
  id int(11) NOT NULL AUTO_INCREMENT,
  requestUid varchar(100) NOT NULL,
  RefId varchar(30) DEFAULT NULL,
  Stage varchar(50) NOT NULL,
  Status varchar(50) NOT NULL,
  CreatedBy varchar(100) DEFAULT NULL,
  CreatedDate bigint(20) NOT NULL,
  UpdatedBy varchar(100) NOT NULL,
  UpdatedDate bigint(20) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- riskdisclosure_master definition

CREATE TABLE riskdisclosure_master (
  id int(11) NOT NULL AUTO_INCREMENT,
  Title varchar(100) DEFAULT NULL,
  TitleRGBColor varchar(20) DEFAULT NULL,
  Content longtext DEFAULT NULL,
  startDateTime datetime DEFAULT NULL,
  endDateTime datetime DEFAULT NULL,
  mandatory varchar(1) DEFAULT NULL,
  buttonRGBColor varchar(20) DEFAULT NULL,
  buttonText varchar(30) DEFAULT NULL,
  DisplayStyle varchar(10) DEFAULT NULL,
  createdBy varchar(100) DEFAULT NULL,
  createdDate datetime DEFAULT NULL,
  updatedBy varchar(100) DEFAULT NULL,
  updatedTime datetime DEFAULT NULL,
  Enable varchar(1) DEFAULT NULL,
  contentType varchar(30) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- techexcel_api_log definition

CREATE TABLE techexcel_api_log (
  id int(11) NOT NULL AUTO_INCREMENT,
  ReqUid varchar(100) NOT NULL,
  RefId varchar(30) NOT NULL,
  RequestData longtext DEFAULT NULL,
  ResponseData longtext DEFAULT NULL,
  RespStatus char(5) DEFAULT NULL,
  RespSr varchar(30) DEFAULT NULL,
  RespLabel varchar(240) DEFAULT NULL,
  RespFieldName varchar(240) DEFAULT NULL,
  RespErrorDesc varchar(240) DEFAULT NULL,
  CreatedDate bigint(20) NOT NULL,
  CreatedBy varchar(100) DEFAULT NULL,
  UpdatedDate bigint(20) NOT NULL,
  UpdatedBy varchar(100) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- xxapi_log definition

CREATE TABLE xxapi_log (
  Id bigint(20) NOT NULL AUTO_INCREMENT,
  request_id varchar(100) NOT NULL,
  token varchar(100) NOT NULL,
  requesteddate datetime NOT NULL,
  realip varchar(240) DEFAULT NULL,
  forwardedip varchar(200) DEFAULT NULL,
  method varchar(20) DEFAULT NULL,
  path longtext DEFAULT NULL,
  host varchar(240) DEFAULT NULL,
  remoteaddr varchar(240) DEFAULT NULL,
  header longtext DEFAULT NULL,
  body longtext DEFAULT NULL,
  endpoint varchar(100) DEFAULT NULL,
  PRIMARY KEY (Id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- xxapi_resp_log definition

CREATE TABLE xxapi_resp_log (
  Id bigint(20) NOT NULL AUTO_INCREMENT,
  request_id varchar(100) DEFAULT NULL,
  response longtext DEFAULT NULL,
  responseStatus int(11) DEFAULT NULL,
  requesteddate datetime NOT NULL,
  realip varchar(240) DEFAULT NULL,
  forwardedip varchar(200) DEFAULT NULL,
  method varchar(20) DEFAULT NULL,
  path longtext DEFAULT NULL,
  host varchar(240) DEFAULT NULL,
  remoteaddr varchar(240) DEFAULT NULL,
  header longtext DEFAULT NULL,
  body longtext DEFAULT NULL,
  endpoint varchar(100) DEFAULT NULL,
  PRIMARY KEY (Id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- xxexternal_apicall_log definition

CREATE TABLE xxexternal_apicall_log (
  Id int(11) NOT NULL AUTO_INCREMENT,
  Method varchar(50) NOT NULL,
  EndPoint varchar(120) NOT NULL,
  RequestType varchar(50) DEFAULT NULL,
  RequestJson longtext NOT NULL,
  ResponseJson longtext NOT NULL,
  ErrMsg varchar(200) DEFAULT NULL,
  CreatedBy varchar(100) DEFAULT NULL,
  CreatedDate datetime DEFAULT NULL,
  UpdatedBy varchar(100) DEFAULT NULL,
  UpdatedDate datetime DEFAULT NULL,
  PRIMARY KEY (Id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;


-- zohocrm_deals_info definition

CREATE TABLE zohocrm_deals_info (
  Id int(11) NOT NULL AUTO_INCREMENT,
  RequestUid varchar(100) DEFAULT NULL,
  CallType varchar(100) DEFAULT NULL,
  ClientName varchar(100) DEFAULT NULL,
  Pan varchar(100) DEFAULT NULL,
  Email varchar(100) DEFAULT NULL,
  Phone varchar(100) DEFAULT NULL,
  Lang varchar(100) DEFAULT NULL,
  RmCode varchar(240) DEFAULT NULL,
  BrCode varchar(240) DEFAULT NULL,
  EmpCode varchar(240) DEFAULT NULL,
  UtmSource varchar(240) DEFAULT NULL,
  UtmMedium varchar(240) DEFAULT NULL,
  UtmCampaign varchar(240) DEFAULT NULL,
  UtmTerm varchar(240) DEFAULT NULL,
  UtmContent varchar(240) DEFAULT NULL,
  Mode varchar(240) DEFAULT NULL,
  RefferalCode varchar(240) DEFAULT NULL,
  Gclid varchar(240) DEFAULT NULL,
  Stage varchar(100) DEFAULT NULL,
  CreatedSId varchar(100) DEFAULT NULL,
  CreatedDate bigint(20) DEFAULT NULL,
  PRIMARY KEY (Id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;

-- zohodepartmentmapping definition

CREATE TABLE zohodepartmentmapping (
  Id int(11) NOT NULL AUTO_INCREMENT,
  STCode varchar(10) NOT NULL,
  EmailId varchar(100) DEFAULT NULL,
  LastName varchar(50) DEFAULT NULL,
  FirstName varchar(50) DEFAULT NULL,
  Mobile varchar(15) DEFAULT NULL,
  Status varchar(50) DEFAULT NULL,
  lang varchar(50) DEFAULT NULL,
  lang2 varchar(50) DEFAULT NULL,
  lang3 varchar(50) DEFAULT NULL,
  lang4 varchar(50) DEFAULT NULL,
  lang5 varchar(50) DEFAULT NULL,
  branch_id int(11) DEFAULT NULL,
  CreatedBy varchar(50) DEFAULT NULL,
  CreatedProgram varchar(50) DEFAULT NULL,
  CreatedDate datetime DEFAULT NULL,
  UpdatedBy varchar(50) DEFAULT NULL,
  UpdatedProgram varchar(50) DEFAULT NULL,
  UpdatedDate datetime DEFAULT NULL,
  DateOfJoin date DEFAULT NULL,
  SecretCode varchar(200) DEFAULT NULL,
  QRCode longtext DEFAULT NULL,
  PRIMARY KEY (Id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;

-- branches definition

CREATE TABLE branches (
  id int(11) NOT NULL AUTO_INCREMENT,
  branchname varchar(50) NOT NULL,
  active varchar(1) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;

-- users definition

CREATE TABLE users (
  id int(11) NOT NULL AUTO_INCREMENT,
  userName varchar(100) DEFAULT NULL,
  displayName varchar(240) DEFAULT NULL,
  emailId varchar(240) DEFAULT NULL,
  enabled varchar(1) DEFAULT NULL,
  createdDate datetime DEFAULT NULL,
  createdProgram varchar(50) DEFAULT NULL,
  updatedBy varchar(50) DEFAULT NULL,
  updatedDate datetime DEFAULT NULL,
  updatedProgram varchar(50) DEFAULT NULL,
  createdBy varchar(50) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8mb3;