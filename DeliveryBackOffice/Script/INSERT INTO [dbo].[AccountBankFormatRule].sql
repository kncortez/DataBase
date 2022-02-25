USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[AccountBankFormatRule]
           ([DeliveryBankId]
           ,[CatBankAccountTypeId]
           ,[MinimumLength]
           ,[MaximumLength]
           ,[StartsWith]
		   ,[Complete]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated])
     VALUES
           (102, 2, 7, 7, NULL, 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (100, 2, 12, 12, '01,02,03', 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (100, 1, 12, 12, '50', 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (2, 2, 8, 10, '1,2,3,5,6,7,8,9', 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (2, 1, 4, 10, '1,2,3,4,5,6,7,8,9', 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (97, 2, 11, 11, '17,18,19,20', 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (97, 1, 11, 11, '10,11,12,13,14', 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (33, 2, 10, 10, NULL, 'TRUE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (33, 1, 7, 7, NULL, 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (5, 2, 10, 10, '3', 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (5, 2, 14, 14, '0', 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (5, 1, 10, 10, '4', 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (5, 1, 14, 14, '0', 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (96, 2, 10, 10, NULL, 'TRUE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (101, 2, 10, 10, NULL, 'TRUE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (101, 1, 16, 16, NULL, 'TRUE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (28, 2, 11, 11, '5', 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (28, 1, 11, 11, '5', 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (93, 2, 14, 14, NULL, 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (93, 1, 14, 14, NULL, 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (103, 1, 13, 13, '4127', 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (31, 2, 9, 9, NULL, 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (31, 2, 11, 11, NULL, 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (31, 1, 9, 9, '96', 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (31, 1, 10, 10, '1', 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (31, 1, 11, 11, NULL, 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (1, 2, 10, 10, NULL, 'TRUE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (1, 1, 10, 10, NULL, 'TRUE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (3, 2, 11, 11, NULL, 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (3, 1, 11, 11, NULL, 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (32, 2, 14, 14, NULL, 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (106, 2, 12, 12, '0', 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL),
		   (106, 1, 12, 12, '2', 'FALSE', 'TRUE', 'SYS-OMORALES', GETDATE(), NULL, NULL)
GO