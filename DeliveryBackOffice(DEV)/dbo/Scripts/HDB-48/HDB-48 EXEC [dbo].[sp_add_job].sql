USE msdb;  
GO  

EXEC dbo.sp_add_job  
    @job_name = N'CheckTelemarketingClientCutoff' ;  
GO  
EXEC sp_add_jobstep  
    @job_name = N'CheckTelemarketingClientCutoff',  
    @step_name = N'Proccess Client Cutoffs',  
    @subsystem = N'TSQL',  
    @command = N'EXEC [DeliveryBackOffice].[dbo].[SPTM_UpdateRejectedClient];',   
    @retry_attempts = 0,  
    @retry_interval = 0 ;  
GO  

EXEC dbo.sp_add_schedule  
    @schedule_name = N'CheckTelemarketingClientCutoffSchedule',  
    @freq_type = 16,				-- Mensualmente
    @freq_interval = 1,				-- Cada día 1
	@freq_recurrence_factor = 1,	-- Recurrencia 1 cada mes
    @active_start_time = 070000 ;	-- 07:00:00
GO  
EXEC sp_attach_schedule  
   @job_name = N'CheckTelemarketingClientCutoff',  
   @schedule_name = N'CheckTelemarketingClientCutoffSchedule';  
GO  

EXEC dbo.sp_add_jobserver  
    @job_name = N'CheckTelemarketingClientCutoff';  
GO  

EXEC dbo.sp_start_job
	N'CheckTelemarketingClientCutoff';
GO

--EXEC dbo.sp_delete_job  
--	@job_name = N'CheckTelemarketingClientCutoff';
--GO