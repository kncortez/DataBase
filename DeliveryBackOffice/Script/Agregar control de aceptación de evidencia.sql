USE DeliveryBackOffice;

ALTER TABLE DeliveryAttempt ADD Accepted BIT NULL
ALTER TABLE DeliveryAttempt ADD User_Verified NVARCHAR(50) NULL
ALTER TABLE DeliveryAttempt ADD Date_Verified DATETIME NULL