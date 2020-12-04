
use DeliveryBackOffice

alter table InOutOfMoneyDetail
add io_canceledInSAP bit


alter table InOutOfMoneyDetail
add io_canceledInSAPDescription varchar(200)
