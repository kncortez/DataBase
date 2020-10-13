CREATE TABLE historic_updateaddress (historic_id INT IDENTITY(1,1), 
									token NVARCHAR(50), 
									name_receiver NVARCHAR(1000),
									original_address NVARCHAR(200),
									updated_address NVARCHAR(200), 
									datetochange DateTime,
									phone_receiver NVARCHAR(100),
									guide_number nvarchar(50))