package common

var (
	AppRunMode        = ""
	EKYCDomain        = ""
	EKYCAllowedOrigin = ""
	EKYCAppName       = ""
	// Development & Testing Purpose
	MobileOtpSend    = ""
	EmailOtpSend     = ""
	BOCheck          = ""
	CRMDeal          = ""
	InformCRM        = ""
	MobileVerified   = ""
	EmailVerified    = ""
	PanVerified      = ""
	AddressVerified  = ""
	BankVerified     = ""
	SegmentVerified  = ""
	DocumnetVerified = ""
	IPVVerified      = ""
	Rejected         = ""
	InProgress       = ""
	Completed        = ""
	TestAllow        = ""
	TestEmail        = ""
	TestMobile       = ""
	TestOTP          = ""
	TestPan          = ""
	TestDOB          = ""
)

const (
	//--------------EKYC APPLICATION CONSTANTS ------------------------
	EKYCCookieName     = "ftek_yc_ck"
	CookieMaxAge       = 5 * 60 * 60
	AppCookieMaxAge    = 30 * 24 * 60 * 60
	NomineeRequestType = "NOMINEEADDITION"
	NomineeProcessType = "NOMINEE"
	UtmMaxAge          = 30 * 24 * 60 * 60
	//--------------OTHER COMMON CONSTANTS -------------

	TechExcelPrefix = "TECHEXCELPROD.capsfo.dbo."

	SuccessCode  = "S" //success
	ErrorCode    = "E" //error
	LoginFailure = "I" //??

	StatusPending = "P" //pending
	StatusApprove = "A" //Approve
	StatusReject  = "R" //Reject
	StatusNew     = "N" //new

	// new Constants for new statusCode
	StatusYes = "Y"
	

	Statement = "1"
	Detail    = "2"
	Panic     = "P"
	NoPanic   = "NP"
	INSERT    = "INSERT"
	UPDATE    = "UPDATE"

	BasePattern   = "/api"
	FileJsonLimit = 10
	//Ifsc
	AppName = "InstaKYC"
)
