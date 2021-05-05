---===========================================================================
--- Se retorna a su estado original los SP
---===========================================================================
--1--
EXEC RenameforBackup 'spg_lstFacturasToSAP','BK_05052021',1
EXEC RenameforBackup 'SetInvoiceLog','BK_05052021',1

--2--
DROP TABLE InvoiceRestriction;
DROP TABLE InvoiceLog;