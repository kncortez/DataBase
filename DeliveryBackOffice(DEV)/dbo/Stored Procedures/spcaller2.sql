
create procedure spcaller2
as
begin
begin transaction 
BEGIN TRY
	--error A
	exec SAPCALLER1

	--error C
	PRINT(1/0)
END TRY
BEGIN CATCH
	--ERRORA
		--XSTATE()=1
		PRINT('xact2')
		PRINT(XACT_STATE())
END CATCH
	

end