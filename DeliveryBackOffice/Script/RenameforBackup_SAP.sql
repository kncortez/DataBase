---===========================================================================
--- Se renombran los stored procedures que existen en el ambiente para poder
--- tener una copia de seguridad, para el rollback
---===========================================================================
--2--
EXEC RenameforBackup 'spg_lstFacturasToSAP','BK_05052021',1
EXEC RenameforBackup 'SetInvoiceLog','BK_05052021',1

