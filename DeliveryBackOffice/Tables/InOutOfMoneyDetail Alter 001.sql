
use DeliveryBackOffice;

alter table InOutOfMoneyDetail
add io_SAPDocEntryPaymentDetail int;

alter table InOutOfMoneyDetail
add io_SAPErrorPaymentDetail varchar(500);
