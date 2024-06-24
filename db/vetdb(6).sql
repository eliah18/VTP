-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 19, 2023 at 12:38 PM
-- Server version: 10.4.25-MariaDB
-- PHP Version: 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `vetdb`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `GetRank` (IN `xul_name` VARCHAR(100))   BEGIN

SELECT z.ID FROM (select
row_number() OVER (Order BY x.GrandTotal desc  ) as ID,
x.SchoolName,
FORMAT(x.Port,2) AS PortfolioValue,
FORMAT(x.cashValue, 2) AS cashValue,
FORMAT(x.GrandTotal,2) AS GrandTotal 
from (select 

				s.SchoolName,
				 (s.CashBalance - sum(case when isnull(b.BuyCosts )=0 then b.BuyCosts  else 0 end - case when isnull(a.SellCosts)=0 then  a.SellCosts else 0 end)) as cashValue,
sum(((case when isnull(PQuantity)=0 then PQuantity else 0 end) -(case when isnull(SQuantity)=0 then SQuantity else 0 end )) * cp.Price) as Port ,
((s.CashBalance - sum(case when isnull(b.BuyCosts )=0 then b.BuyCosts  else 0 end - case when isnull(a.SellCosts)=0 then  a.SellCosts else 0 end)) +  sum(((case when isnull(PQuantity)=0 then PQuantity else 0 end) -(case when isnull(SQuantity)=0 then SQuantity else 0 end )) * cp.Price)) as GrandTotal

	from 	(
				select 
 case when isnull(sum(Quantity))=0 then sum(Quantity) else 0 end as PQuantity, 
case when isnull(sum(DealTotal))=0 then sum(DealTotal)  else 0 end as BuyCosts,
						   CounterID ,SchoolID
			   from  Deals 
							where DealTypeID=2  and convert(valuedate,date)<=curdate()
							group by CounterID,SchoolID

							) b left outer join
							
				(
				select 
 case when isnull(sum(Quantity))=0 then sum(Quantity) else 0 end  as SQuantity,
 case when isnull(sum(DealTotal))=0 then sum(DealTotal)  else 0 end as SellCosts,
						   CounterID ,SchoolID
			   from  Deals 
							where DealTypeID=1 and convert(valuedate,date)<=curdate()
							group by CounterID,SchoolID

							) a on a.SchoolID=b.SchoolID and a.CounterID=b.CounterID
							
inner join 
			Counters c on b.CounterID=c.CounterID
inner join
			( 
					select a.ShortName,a.Price 
					
	from (

			select *,
			ROW_NUMBER() over (partition by shortname order by datecreated desc ) as rn
   from
		CounterPrices
								where convert(datecreated,date)<=curdate())a
								where a.rn =1   
								
								)cp on c.ShortName=cp.ShortName inner join Schools s on b.SchoolID=s.SchoolID group by s.SchoolName ,s.CashBalance )x)z where z.schoolname=xul_name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Graph` (IN `mySchoolID` INT)   BEGIN
select c.CounterName,(((case when isnull(PQuantity)=0 then PQuantity else 0 end) - (case when isnull(SQuantity)=0 then SQuantity else 0 end) )* cp.Price) as PortValue from (select sum(a.Quantity) as SQuantity,a.counterID from deals a where a.dealtypeID=1 and a.schoolID=mySchoolID group by a.counterID)a right join 
(select sum(b.Quantity) as PQuantity,b.counterID from deals b where b.dealtypeID=2 and b.schoolID=mySchoolID group by b.counterID)b on a.counterID=b.counterID join 	Counters c on b.CounterID=c.CounterID inner join
( 
					select a.ShortName,a.Price 
					
	from (

			select *,
			ROW_NUMBER() over (partition by shortname order by datecreated desc ) as rn
   from
		CounterPrices
								where convert(datecreated,date)<=curdate())a
								where a.rn =1   
								
								)cp on c.ShortName=cp.ShortName;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ClientPerfomance` (IN `mySchoolID` INT, IN `MYDATE` DATE)   BEGIN
    select
row_number() OVER (Order BY x.GrandTotal desc  ) as ID,
x.SchoolName,
FORMAT(x.Port,2) AS PortfolioValue,
FORMAT(x.cashValue, 2) AS cashValue,
FORMAT(x.GrandTotal,2) AS GrandTotal 
from (select
s.SchoolName,
 (s.CashBalance) as cashValue,
sum(((case when isnull(PQuantity)=0 then PQuantity else 0 end) -(case when isnull(SQuantity)=0 then SQuantity else 0 end )) * cp.Price) as Port ,
((s.CashBalance ) +  sum(((case when isnull(PQuantity)=0 then PQuantity else 0 end) -(case when isnull(SQuantity)=0 then SQuantity else 0 end )) * cp.Price)) as GrandTotal
 from 
 (select
 case when isnull(sum(Quantity))=0 then sum(Quantity) else 0 end  as SQuantity,
 case when isnull(sum(DealTotal))=0 then sum(DealTotal)  else 0 end as SellCosts,
 counterID,SchoolID from deals 
 where dealtypeID=1 and schoolID=mySchoolID group by counterID,SchoolID)a right join 
(
select case when isnull(sum(Quantity))=0 then sum(Quantity) else 0 end as PQuantity, 
case when isnull(sum(DealTotal))=0 then sum(DealTotal)  else 0 end as BuyCosts,
counterID,SchoolID
 from deals where dealtypeID=2 and schoolID=mySchoolID group by counterID,SchoolID)b on a.counterID=b.counterID join 	Counters c on b.CounterID=c.CounterID inner join
( 
					select a.ShortName,a.Price 
					
	from (

			select *,
			ROW_NUMBER() over (partition by shortname order by datecreated desc ) as rn
   from
		CounterPrices
								where convert(datecreated,date)<=MYDATE)a
								where a.rn =1   
								
								)cp on c.ShortName=cp.ShortName join schools s on b.SchoolID=s.SchoolID )x ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CreateDeal` (IN `School_ID` INT, IN `Counter_ID` INT, IN `Deal_Type` INT, IN `MyQuantity` INT, IN `MyPrice` DECIMAL(10,6), IN `MyDealTotal` NUMERIC(18,4))   BEGIN

		INSERT INTO Deals
			(
				SchoolID,
				CounterID,
				DealTypeID,
				Quantity,
				Price,
				
				ValueDate,
				DealTotal
			)
		VALUES
			(
				School_ID,
				Counter_ID,
				Deal_Type,
				MyQuantity,
				 MyPrice,
				
				curdate(),
				MyDealTotal
			);
  
    
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CreateDealCharge` (IN `Deal_Type` VARCHAR(50), IN `DealCharge` INT)   BEGIN
INSERT INTO tbl_DealCharges
			(
				DealType,
				Charge
			)
		VALUES
			(
				Deal_Type,
				convert(DealCharge,decimal(18,4))/100
			);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CreatePieChart` ()   BEGIN
select
row_number() OVER (Order BY x.GrandTotal desc  ) as ID,
x.SchoolName,

FORMAT(x.GrandTotal,2) AS GrandTotal 
from (select 

s.SchoolName,
                   (s.CashBalance - sum(case when isnull(b.BuyCosts )=0 then b.BuyCosts  else 0 end - case when isnull(a.SellCosts)=0 then  a.SellCosts else 0 end)) as cashValue,
sum(((case when isnull(PQuantity)=0 then PQuantity else 0 end) -(case when isnull(SQuantity)=0 then SQuantity else 0 end )) * cp.Price) as Port ,
((s.CashBalance - sum(case when isnull(b.BuyCosts )=0 then b.BuyCosts  else 0 end - case when isnull(a.SellCosts)=0 then  a.SellCosts else 0 end)) +  sum(((case when isnull(PQuantity)=0 then PQuantity else 0 end) -(case when isnull(SQuantity)=0 then SQuantity else 0 end )) * cp.Price)) as GrandTotal
	from 	(
				select 
						 						     case when isnull(sum(Quantity))=0 then sum(Quantity) else 0 end as PQuantity,
						  case when isnull(sum(DealTotal))=0 then sum(DealTotal)  else 0 end as BuyCosts,
						   CounterID ,SchoolID
			   from  Deals 
							where DealTypeID=2 
							group by CounterID,SchoolID

							) b left outer join
							
				(
				select 
						 case when isnull(sum(Quantity))=0 then sum(Quantity) else 0 end  as SQuantity,
						    case when isnull(sum(DealTotal))=0 then sum(DealTotal)  else 0 end as SellCosts,
						   CounterID ,SchoolID
			   from  Deals 
							where DealTypeID=1 
							group by CounterID,SchoolID

							) a on a.SchoolID=b.SchoolID and a.CounterID=b.CounterID
							
inner join 
			Counters c on b.CounterID=c.CounterID
inner join
			( 
	select a.ShortName,a.Price 
					
	from (

			select *,
			ROW_NUMBER() over (partition by shortname order by datecreated desc ) as rn
   from
		CounterPrices
								where convert(datecreated,date)<=CURdate())a
								where a.rn =1   
								
								)cp on c.ShortName=cp.ShortName inner join Schools s on b.SchoolID=s.SchoolID group by s.SchoolName ,s.CashBalance )x;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CreateSchool` (IN `SchoolName` VARCHAR(100), IN `PhyAddress` VARCHAR(100), IN `City` VARCHAR(100), IN `Country` VARCHAR(100), IN `Email` VARCHAR(100), IN `Province` VARCHAR(100), IN `SchlHead` VARCHAR(100), IN `SchlRep` VARCHAR(100), IN `ContactNo` VARCHAR(100), IN `IntialCash` INT)   BEGIN
  insert into
						Schools 
									(SchoolName,
                                    PhysicalAddress,
                                    City,
                                    Province, 
									Country, 
                                    SchoolEmail,
                                    ContactNumber,
                                    SchoolHeadmaster,
                                    Representative,
                                    CashBalance) 
									
									values(
                                    SchoolName,
                                    PhyAddress, 
                                    City,
                                    Province,
                                    Country ,
                                    Email,
                                    ContactNo,
                                    SchlHead,
                                    SchlRep ,
                                    IntialCash
                                    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_CreateSystemUser` (IN `FirstName` VARCHAR(100), IN `MySurname` VARCHAR(100), IN `MyUsername` VARCHAR(100), IN `MyPassword` VARCHAR(100), IN `MyEmail` VARCHAR(100), IN `MyRoleId` INT, IN `MySchoolID` INT)   BEGIN
  insert into
						SystemUsers 
									(
                                    name,
                                    surname,
                                    SchoolID,
                                    Email,
                                    password,
                                    username, 
                                    role_id
                                    ) 
									
									values(
                                    FirstName,
                                    MySurname,
                                    MySchoolID, 
                                    MyEmail,
                                    MyPassword,
                                    MyUsername ,
                                    MyRoleId
                                    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_DealsView` (IN `School_ID` INT)   BEGIN
SELECT 
           d.DealID ,
		   
         d.ValueDate as ValueDate,
		
		 a.DealType as DealType,
		 x.CounterName as CounterName,
		 FORMAT(d.Price,4) as Price,
		
		FORMAT(d.Quantity,4) as Quantity,
		 FORMAT(d.DealTotal,4) as DealTotal
		 
 FROM DEALS d 
							 inner join
	Schools s on d.SchoolID=s.SchoolID
							inner join 
	DealTypes a on d.DealTypeID= a.DealTypeID
	                        inner join
	Counters x on d.CounterID=x.CounterID

	where d.SchoolID=School_ID order by d.DealID desc;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetAdminRole` ()   BEGIN
 select 
				RoleID,
				Role 
				
	  from Roles where RoleID in (1);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetCashValue` (IN `myschlID` INT)   BEGIN

set @totalPurchase =0;
set @totalSell =0;
set @totalcash =0;
set @cashvalue =0;



set @totalcash=(select CashBalance from Schools where SchoolID=myschlID);


select FORMAT(@totalcash,2) as CashValue;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetCounterDropdown` ()   BEGIN
 select 
				CounterID,
				ShortName 
				
	  from Counters;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetCounterPrices` ()   BEGIN
SELECT 
					  CounterPriceID,
					  ShortName,
					  BidPrice,
					  OfferPrice,
					  Price,
					  PriceDate
          from 

CounterPrices order by CounterPriceID desc;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetCountersTable` ()   BEGIN
SELECT
		 Counter,
		 CounterName,
         CounterPrice 
 from (SELECT
			 ShortName as Counter, 
			 Price as CounterPrice 
			 from counterprices) a
 join (SELECT
			 ShortName,
			 CounterName
 FROM counters) b
 on a.Counter = b.ShortName
           ORDER BY `a`.`Counter`;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetDealTypeCharges` ()   BEGIN
select 
				DealChargesID,
				DealType,
				Charge
				
	  from tbl_DealCharges;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetDealTypeDropdown` ()   BEGIN
   select 
              DealTypeID,
		      DealType 

       from DealTypes ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getMobileTransView` (IN `startDate` DATE, IN `endDate` DATE, IN `mySchlID` INT)   BEGIN
set @balance =0;

set @balance =(select cashbalance from schools where schoolID=mySchlID);
 select 
			   convert(d.ValueDate,date) as ValueDate,
			   c.ShortName as CounterName,
			   x.DealType, 
			   case when x.DealType='Purchase' then FORMAT(Quantity * Price,2) else 0 end as DebitAmount,
			   case when x.DealType='Sell' then FORMAT(Quantity * Price,2) else 0 end as CreditAmount,
			    case when x.DealType='Sell' then FORMAT(@balance:=@balance +( Quantity * Price),2) else FORMAT(@balance:=@balance -( Quantity * Price),2) end  as RunningBalance

 from Deals d 
                                 inner join 
								 
Counters c on d.CounterID=c.CounterID
						
								inner join 

DealTypes x on d.DealTypeID=x.DealTypeID

								where convert(valuedate,date) between startDate and endDate and SchoolID=mySchlID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetPortfolioValue` (IN `myschlID` INT)   BEGIN

set @totalPurchase =0;
set @totalSell =0;
set @totalcash =0;
set @cashvalue =0;

set @Port =0;

set @GrantTotal =0; 

set @totalcash=(select CashBalance from Schools where SchoolID=myschlID);

set @cashvalue=@totalcash;

set @Port=(select sum(((case when isnull(PQuantity)=0 then PQuantity else 0 end) -(case when isnull(SQuantity)=0 then SQuantity else 0 end )) * cp.Price)  from (select sum(Quantity) as SQuantity,counterID from deals where dealtypeID=1 and schoolID=myschlID group by counterID)a right join 
(select sum(Quantity) as PQuantity,counterID from deals where dealtypeID=2 and schoolID=myschlID group by counterID)b on a.counterID=b.counterID join 	Counters c on b.CounterID=c.CounterID inner join
( 
					select a.ShortName,a.Price 
					
	from (

			select *,
			ROW_NUMBER() over (partition by shortname order by datecreated desc ) as rn
   from
		CounterPrices
								where convert(datecreated,date)<=curdate())a
								where a.rn =1   
								
								)cp on c.ShortName=cp.ShortName);
SET @GrantTotal= (select  @cashvalue + case when isnull(@Port) = 0 then @Port else 0 end);

select FORMAT(@GrantTotal,2) as PortfolioValue;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetPortfolioView` (IN `mySchlID` INT, IN `VarDate` DATE)   BEGIN
select 
					row_number() OVER (ORDER BY CounterID, CounterID) as ID,
					x.CounterName,
					'0' as BookValue,
					(x.PortQuantity * x.Price) as MarketValue,
					x.Price as Price,
					x.PortQuantity as NumberOfShares 
from (
      select
				  (b.PQuantity)- (case when isnull(a.SQuantity)=0 then a.SQuantity else 0 end) as PortQuantity,
					 b.CounterID,
					 cp.Price,
					 c.CounterName 
		 from 
(
select 
			case when isnull(sum(Quantity))=0 then sum(Quantity) else 0 end as SQuantity,
			CounterID  

from Deals
             where DealTypeID=1 and 
			 convert(ValueDate,date)<=VarDate
			 and SchoolID=mySchlID
			 group by CounterID
) a 
			right join 

(
   select 
			  case when isnull(sum(Quantity))=0 then sum(Quantity) else 0 end as PQuantity,
			   CounterID  
			   from  Deals 
							where DealTypeID=2 and
							convert(ValueDate,date)<=VarDate
							and SchoolID=mySchlID
							group by CounterID
							) b 
							on a.CounterID=b.CounterID
inner join 
			Counters c on b.CounterID=c.CounterID
inner join
			( select a.ShortName,a.Price from (

select *,
ROW_NUMBER() over (partition by shortname order by datecreated desc ) as rn
from
CounterPrices
where convert(datecreated,date)<=VarDate)a
where a.rn =1   )cp on c.ShortName=cp.ShortName) x 
WHERE X.PortQuantity>0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetQuantity` (IN `myschlID` INT, IN `myCounter` INT)   BEGIN
 set @PQuantity =0;
 set @SQuantity =0;
 set @Quantity =0;


set @PQuantity=(select case when isnull(sum(quantity) )=0 then sum(quantity) else 0 end from deals where SchoolID=myschlID and DealTypeID=2 and CounterID=myCounter);

set @SQuantity=(select case when isnull(sum(quantity) )=0 then sum(quantity) else 0 end  from deals where SchoolID=myschlID and DealTypeID=1 and CounterID=myCounter);

set @Quantity=(select @PQuantity-@SQuantity);

select  @Quantity as Quantity;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetRoles` ()   BEGIN
 select 
				RoleID,
				Role 
				
	  from Roles where RoleID in (2,3);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetSchoolName` ()   BEGIN
 select 
				SchoolID,
				SchoolName 
				
	  from Schools;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetSchools` ()   BEGIN
 select 
			SchoolID,
			SchoolName,
			PhysicalAddress,
			City,
			Province, 
			Country, 
			SchoolEmail, 
			ContactNumber, 
			SchoolHeadmaster,
			Representative, 
			CashBalance
			
from Schools  order by SchoolID desc;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetSchoolUsers` ()   BEGIN
  select 
				s.UserID,
				s.name,
				s.surname,
				s.Email,
				r.Role,
				case when s.active =1 then 'Yes' else 'No' end as Active
				
	  from SystemUsers s 
	                                    inner join

			Roles r on s.role_id=r.RoleID

			WHERE s.role_id<>1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_GetSystemUsers` ()   BEGIN
 select 
				s.UserID,
				s.name,
				s.surname,
				s.Email,
				r.Role,
				case when s.active =1 then 'Yes' else 'No' end as Active
				
	  from SystemUsers s 
	                                    inner join

			Roles r on s.role_id=r.RoleID

			WHERE s.role_id=1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_Gettransactionview` (IN `startDate` DATE, IN `endDate` DATE, IN `mySchlID` INT)   BEGIN
set @balance =0;

set @balance =(select cashbalance from schools where schoolID=mySchlID);
 select 
			   convert(d.ValueDate,date) as ValueDate,
			   c.CounterName,
			   x.DealType, 
			   case when x.DealType='Purchase' then Quantity * Price else 0 end as DebitAmount,
			   case when x.DealType='Sell' then Quantity * Price else 0 end as CreditAmount,
			    case when x.DealType='Sell' then FORMAT(@balance:=@balance +( Quantity * Price),4) else FORMAT(@balance:=@balance -( Quantity * Price),4) end  as RunningBalance

 from Deals d 
                                 inner join 
								 
Counters c on d.CounterID=c.CounterID
						
								inner join 

DealTypes x on d.DealTypeID=x.DealTypeID

								where convert(valuedate,date) between startDate and endDate and SchoolID=mySchlID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_MobilePortView` (IN `mySchlID` INT, IN `VarDate` DATE)   BEGIN
select 
					row_number() OVER (ORDER BY CounterID, CounterID) as ID,
					x.ShortName as CounterName,
					'0' as BookValue,
					(x.PortQuantity * x.Price) as MarketValue,
					x.Price as Price,
					x.PortQuantity as NumberOfShares 
from (
      select
				  (b.PQuantity)- (case when isnull(a.SQuantity)=0 then a.SQuantity else 0 end) as PortQuantity,
					 b.CounterID,
					 cp.Price,
					 c.ShortName 
		 from 
(
select 
			case when isnull(sum(Quantity))=0 then sum(Quantity) else 0 end as SQuantity,
			CounterID  

from Deals
             where DealTypeID=1 and 
			 convert(ValueDate,date)<=VarDate
			 and SchoolID=mySchlID
			 group by CounterID
) a 
			right join 

(
   select 
			  case when isnull(sum(Quantity))=0 then sum(Quantity) else 0 end as PQuantity,
			   CounterID  
			   from  Deals 
							where DealTypeID=2 and
							convert(ValueDate,date)<=VarDate
							and SchoolID=mySchlID
							group by CounterID
							) b 
							on a.CounterID=b.CounterID
inner join 
			Counters c on b.CounterID=c.CounterID
inner join
			( select a.ShortName,a.Price from (

select *,
ROW_NUMBER() over (partition by shortname order by datecreated desc ) as rn
from
CounterPrices
where convert(datecreated,date)<=VarDate)a
where a.rn =1   )cp on c.ShortName=cp.ShortName) x 
WHERE X.PortQuantity>0;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_PricesList` ()   BEGIN
select 
					 ShortName as Counter,
					 Price as CounterPrice 
			 from counterprices ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_SchoolsPerfomanceView` (IN `ValueDate` DATE)   BEGIN
select
row_number() OVER (Order BY x.GrandTotal desc  ) as ID,
x.SchoolName,
FORMAT(x.Port,2) AS PortfolioValue,
FORMAT(x.cashValue, 2) AS cashValue,
FORMAT(x.GrandTotal,2) AS GrandTotal 
from (select 
s.SchoolName,
 (s.CashBalance - sum(case when isnull(b.BuyCosts )=0 then b.BuyCosts  else 0 end - case when isnull(a.SellCosts)=0 then  a.SellCosts else 0 end)) as cashValue,
sum(((case when isnull(PQuantity)=0 then PQuantity else 0 end) -(case when isnull(SQuantity)=0 then SQuantity else 0 end )) * cp.Price) as Port ,
((s.CashBalance - sum(case when isnull(b.BuyCosts )=0 then b.BuyCosts  else 0 end - case when isnull(a.SellCosts)=0 then  a.SellCosts else 0 end)) +  sum(((case when isnull(PQuantity)=0 then PQuantity else 0 end) -(case when isnull(SQuantity)=0 then SQuantity else 0 end )) * cp.Price)) as GrandTotal

	from 	(
				select 
						     case when isnull(sum(Quantity))=0 then sum(Quantity) else 0 end as PQuantity,
						  case when isnull(sum(DealTotal))=0 then sum(DealTotal)  else 0 end as BuyCosts,
						   CounterID ,SchoolID
			   from  Deals 
							where DealTypeID=2  and convert(valuedate,date)<=ValueDate
							group by CounterID,SchoolID

							) b left outer join
							
				(
				select 
						 case when isnull(sum(Quantity))=0 then sum(Quantity) else 0 end  as SQuantity,
						    case when isnull(sum(DealTotal))=0 then sum(DealTotal)  else 0 end as SellCosts,
						   CounterID ,SchoolID
			   from  Deals 
							where DealTypeID=1 and convert(valuedate,date)<=ValueDate
							group by CounterID,SchoolID

							) a on a.SchoolID=b.SchoolID and a.CounterID=b.CounterID
							
inner join 
			Counters c on b.CounterID=c.CounterID
inner join
			( 
					select a.ShortName,a.Price 
					
	from (

			select *,
			ROW_NUMBER() over (partition by shortname order by datecreated desc ) as rn
   from
		CounterPrices
								where convert(datecreated,date)<=ValueDate)a
								where a.rn =1   
								
								)cp on c.ShortName=cp.ShortName inner join Schools s on b.SchoolID=s.SchoolID group by s.SchoolName ,s.CashBalance )x;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_UpdateBalance` (IN `myschlID` INT, IN `DealTotal` DECIMAL(10,6))   BEGIN
set @availablecash =0;
set @totalcash = 0;

set @totalcash=(select CashBalance from Schools where SchoolID=myschlID);
set @availablecash = @totalcash - DealTotal;

  update Schools set CashBalance = @availablecash  where SchoolID=myschlID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_ValidateDealCash` (IN `myschlID` INT)   BEGIN
select CashBalance as CashValue from Schools where SchoolID=myschlID;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `test` ()   BEGIN
SET @SchoolID =2;
set @totalPurchase =0;
set @totalSell =0;
set @totalcash =0;
set @cashvalue =0;

set @BuyCosts =0;
set @SellCosts =0;
set @GrantTotal =0; 

set @totalcash=(select CashBalance from Schools where SchoolID=@SchoolID);

set @totalPurchase= (select sum(dealtotal) from Deals where SchoolID=@SchoolID and DealTypeID=2);
set @totalSell=(select sum(dealtotal) from Deals where SchoolID=@SchoolID and DealTypeID=1);

set @cashvalue=(select (@totalcash + @totalSell)-@totalPurchase);
set @SellCosts=(select sum((d.Quantity * p.offerprice)) as val from deals d join 	Counters c on d.CounterID=c.CounterID join counterprices p on c.shortname=p.shortname where d.DealTypeID=1 and d.SchoolID=2);
set @BuyCosts=(select sum((d.Quantity * p.offerprice)) as val from deals d join 	Counters c on d.CounterID=c.CounterID join counterprices p on c.shortname=p.shortname where d.DealTypeID=2 and d.SchoolID=2);
SET @GrantTotal= (select  @cashvalue +( @BuyCosts-@SellCosts));

select FORMAT(@GrantTotal,4) as GRANTTOTAL;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `auditedobjectweakreference`
--

CREATE TABLE `auditedobjectweakreference` (
  `Oid` varchar(64) NOT NULL,
  `GuidId` varchar(64) DEFAULT NULL,
  `IntId` int(11) DEFAULT NULL,
  `DisplayName` varchar(250) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `auditedobjectweakreference`
--

INSERT INTO `auditedobjectweakreference` (`Oid`, `GuidId`, `IntId`, `DisplayName`) VALUES
('260492E8-4C60-472A-8F17-3586BEA288F0', NULL, 1, '1'),
('2A63C9F8-3B81-4E80-BC94-0991779596EE', NULL, 2, '2'),
('AFADF54D-8EA3-40E1-B724-B8A5371E6345', NULL, 1, 'Econet'),
('E9C31BB6-0D11-4F2E-A4C1-C8410D35C79A', NULL, 1, 'ECO');

-- --------------------------------------------------------

--
-- Table structure for table `audit_tray`
--

CREATE TABLE `audit_tray` (
  `ID` int(11) NOT NULL,
  `Username` varchar(500) NOT NULL,
  `Operation` varchar(500) NOT NULL,
  `Date` varchar(30) NOT NULL,
  `Time` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `audit_tray`
--

INSERT INTO `audit_tray` (`ID`, `Username`, `Operation`, `Date`, `Time`) VALUES
(1, 'John Mulla', 'Logged In', '0000-00-00', '10:53:18.000000'),
(2, 'John Mulla', 'Logged In', '22-02-2023', '10:58:05'),
(3, 'John Mulla', 'Logged In', '22-02-2023', '11:09:00'),
(4, 'John Mulla', 'Logged In', '22-02-2023', '11:39:41'),
(5, 'John Mulla', 'Logged In', '22-02-2023', '11:40:53'),
(6, 'John Mulla', 'Logged In', '22-02-2023', '11:43:25'),
(7, 'John Mulla', 'Logged In', '22-02-2023', '12:01:48'),
(8, 'John Mulla', 'Logged In', '22-02-2023', '12:05:13'),
(9, 'John Mulla', 'Logged In', '22-02-2023', '12:09:10'),
(10, 'John Mulla', 'Logged In', '22-02-2023', '12:18:41'),
(11, 'John Mulla', 'Logged In', '22-02-2023', '13:11:38'),
(12, 'John Mulla', 'Logged In', '22-02-2023', '13:22:29'),
(13, 'John Mulla', 'Logged In', '22-02-2023', '13:24:16'),
(14, 'John Mulla', 'Logged Out', '22-02-2023', '13:55:37'),
(15, 'John Mulla', 'Logged In', '22-02-2023', '13:55:49'),
(16, 'John Mulla', 'Logged Out', '22-02-2023', '14:14:37'),
(17, 'John Mulla', 'Logged In', '22-02-2023', '14:16:03'),
(18, 'John Mulla', 'Logged Out', '22-02-2023', '14:16:08'),
(19, 'John Mulla', 'Logged In', '22-02-2023', '14:16:13'),
(20, 'John Mulla', 'Logged In', '27-02-2023', '12:21:44'),
(21, 'John Mulla', 'Logged Out', '27-02-2023', '12:21:51'),
(22, 'John Mulla', 'Logged In', '27-02-2023', '12:28:15'),
(23, 'John Mulla', 'Logged Out', '27-02-2023', '12:48:32'),
(24, 'John Mulla', 'Logged In', '27-02-2023', '12:48:37'),
(25, 'John Mulla', 'Logged Out', '27-02-2023', '13:03:41'),
(26, 'John Mulla', 'Logged In', '27-02-2023', '13:08:49'),
(27, 'John Mulla', 'Logged Out', '27-02-2023', '13:11:05'),
(28, 'John Mulla', 'Logged In', '27-02-2023', '13:11:09'),
(29, 'John Mulla', 'Logged Out', '27-02-2023', '13:14:23'),
(30, 'John Mulla', 'Logged In', '27-02-2023', '13:14:31'),
(31, 'John Mulla', 'Logged Out', '27-02-2023', '16:15:41'),
(32, 'John Mulla', 'Logged In', '27-02-2023', '16:15:45'),
(33, 'John Mulla', 'Logged Out', '27-02-2023', '16:23:30'),
(34, 'John Mulla', 'Logged In', '27-02-2023', '16:23:33'),
(35, 'John Mulla', 'Logged In', '27-02-2023', '18:58:48'),
(36, 'John Mulla', 'Logged Out', '27-02-2023', '19:38:25'),
(37, 'John Mulla', 'Logged In', '27-02-2023', '19:38:28'),
(38, 'John Mulla', 'Logged Out', '27-02-2023', '19:41:02'),
(39, 'John Mulla', 'Logged In', '27-02-2023', '19:41:13'),
(40, 'John Mulla', 'Logged Out', '27-02-2023', '20:53:51'),
(41, 'John Mulla', 'Logged In', '27-02-2023', '20:54:00'),
(42, 'John Mulla', 'Logged Out', '27-02-2023', '21:29:54'),
(43, 'John Mulla', 'Logged In', '27-02-2023', '21:29:57'),
(44, 'John Mulla', 'Logged In', '01-03-2023', '09:15:20'),
(45, 'John Mulla', 'Logged In', '01-03-2023', '20:44:01'),
(46, 'John Mulla', 'Logged Out', '01-03-2023', '21:45:58'),
(47, 'John Mulla', 'Logged In', '01-03-2023', '21:46:02'),
(48, 'John Mulla', 'Logged Out', '01-03-2023', '22:06:32'),
(49, 'John Mulla', 'Logged In', '01-03-2023', '22:06:35'),
(50, 'John Mulla', 'Logged In', '02-03-2023', '00:45:59'),
(51, 'John Mulla', 'Logged Out', '02-03-2023', '02:20:21'),
(52, 'John Mulla', 'Logged In', '02-03-2023', '02:21:19'),
(53, 'John Mulla', 'Logged Out', '02-03-2023', '02:21:25'),
(54, 'John Mulla', 'Logged In', '02-03-2023', '02:21:29'),
(55, 'John Mulla', 'Logged Out', '02-03-2023', '02:26:16'),
(56, 'Gee soft', 'Logged In', '02-03-2023', '02:26:27'),
(57, 'Gee soft', 'Logged In', '02-03-2023', '02:28:26'),
(58, 'Gee soft', 'Logged In', '02-03-2023', '02:28:43'),
(59, 'Gee soft', 'Logged In', '02-03-2023', '03:00:26'),
(60, 'Gee soft', 'Logged In', '02-03-2023', '03:17:26'),
(61, 'Gee soft', 'Logged In', '02-03-2023', '03:38:45'),
(62, 'Gee soft', 'Logged In', '02-03-2023', '10:41:58'),
(63, 'Gee soft', 'Logged In', '02-03-2023', '16:48:29'),
(64, 'Gee soft', 'Logged In', '02-03-2023', '22:08:32'),
(65, 'Gee soft', 'Logged In', '02-03-2023', '23:02:10'),
(66, 'Gee soft', 'Logged In', '04-03-2023', '10:04:24'),
(67, 'Gee soft', 'Logged In', '04-03-2023', '23:04:20'),
(68, 'Gee soft', 'Logged In', '04-03-2023', '23:35:18'),
(69, 'Gee soft', 'Logged Out', '05-03-2023', '02:30:01'),
(70, 'Gee soft', 'Logged In', '05-03-2023', '02:30:05'),
(71, 'Gee soft', 'Logged Out', '05-03-2023', '02:30:11'),
(72, 'Gee soft', 'Logged In', '05-03-2023', '02:31:17'),
(73, 'Gee soft', 'Logged Out', '05-03-2023', '02:32:06'),
(74, 'Gee soft', 'Logged In', '05-03-2023', '02:32:12'),
(75, 'Gee soft', 'Logged Out', '05-03-2023', '02:32:18'),
(76, 'Gee soft', 'Logged In', '05-03-2023', '02:34:27'),
(77, 'Gee soft', 'Logged Out', '05-03-2023', '02:34:32'),
(78, 'Gee soft', 'Logged In', '05-03-2023', '02:34:36'),
(79, 'Gee soft', 'Logged Out', '05-03-2023', '02:34:40'),
(80, 'Gee soft', 'Logged In', '05-03-2023', '02:34:44'),
(81, 'Gee soft', 'Logged Out', '05-03-2023', '02:34:51'),
(82, 'Gee soft', 'Logged In', '05-03-2023', '02:35:00'),
(83, 'Gee soft', 'Logged Out', '05-03-2023', '02:35:09'),
(84, 'Gee soft', 'Logged In', '05-03-2023', '02:35:12'),
(85, 'Gee soft', 'Logged Out', '05-03-2023', '02:36:59'),
(86, 'John Mulla', 'Logged In', '05-03-2023', '02:37:02'),
(87, 'John Mulla', 'Logged Out', '05-03-2023', '02:56:56'),
(88, 'Gee soft', 'Logged In', '05-03-2023', '02:57:00'),
(89, 'Gee soft', 'Logged In', '05-03-2023', '16:26:02'),
(90, 'John Mulla', 'Logged In', '06-03-2023', '09:29:19'),
(91, 'John Mulla', 'Logged Out', '06-03-2023', '10:15:49'),
(92, 'Gee soft', 'Logged In', '06-03-2023', '10:15:53'),
(93, 'John Mulla', 'Logged In', '20-06-2023', '10:52:31'),
(94, '', 'Logged In', '17-07-2023', '14:00:48'),
(95, 'mulla07', 'Logged In', '17-07-2023', '14:08:24'),
(96, 'mulla07', 'Logged In', '17-07-2023', '14:40:18'),
(97, 'mulla07', 'Logged In', '17-07-2023', '14:50:49'),
(98, 'mulla07', 'Logged In', '17-07-2023', '14:53:07'),
(99, 'mulla07', 'Logged In', '17-07-2023', '14:54:01'),
(100, 'mulla07', 'Logged In', '17-07-2023', '14:57:20'),
(101, 'mulla07', 'Logged In', '17-07-2023', '14:59:14'),
(102, 'John Mulla', 'Logged In', '19-07-2023', '10:51:59');

-- --------------------------------------------------------

--
-- Table structure for table `cities`
--

CREATE TABLE `cities` (
  `CityID` int(11) NOT NULL,
  `CityName` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `counterprices`
--

CREATE TABLE `counterprices` (
  `CounterPriceID` int(11) NOT NULL,
  `ShortName` varchar(50) NOT NULL,
  `BidPrice` decimal(10,2) DEFAULT NULL,
  `OfferPrice` decimal(10,2) DEFAULT NULL,
  `Price` decimal(10,2) DEFAULT NULL,
  `PriceDate` date NOT NULL,
  `DateCreated` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `counterprices`
--

INSERT INTO `counterprices` (`CounterPriceID`, `ShortName`, `BidPrice`, `OfferPrice`, `Price`, `PriceDate`, `DateCreated`) VALUES
(3, 'CBZ', '124.00', '128.00', '128.00', '2022-12-26', '2022-12-26'),
(4, 'DLTA', '245.00', '244.00', '245.00', '2022-12-26', '2022-12-26'),
(5, 'ECO', '73.74', '73.42', '73.74', '2022-12-26', '2022-12-26'),
(6, 'INN', '345.80', '348.15', '345.80', '2022-12-26', '2022-12-26');

-- --------------------------------------------------------

--
-- Table structure for table `counterpricestest`
--

CREATE TABLE `counterpricestest` (
  `CounterPriceID` int(11) NOT NULL,
  `ShortName` varchar(50) NOT NULL,
  `BidPrice` decimal(10,2) DEFAULT NULL,
  `OfferPrice` decimal(10,2) DEFAULT NULL,
  `Price` decimal(10,2) DEFAULT NULL,
  `PriceDate` date NOT NULL,
  `DateCreated` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `counters`
--

CREATE TABLE `counters` (
  `CounterID` int(11) NOT NULL,
  `CounterName` varchar(50) NOT NULL,
  `ShortName` varchar(20) NOT NULL,
  `Sector` varchar(20) DEFAULT NULL,
  `Category` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `counters`
--

INSERT INTO `counters` (`CounterID`, `CounterName`, `ShortName`, `Sector`, `Category`) VALUES
(2, 'Delta Corporation Limited', 'DLTA', NULL, NULL),
(3, 'Econet Wireless Zimbabwe Limited', 'ECO', 'Telecommunications', NULL),
(4, 'Innscor Africa Limited', 'INN', NULL, NULL),
(5, 'CBZ Holdings Limited', 'CBZ', 'Banking', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `countries`
--

CREATE TABLE `countries` (
  `CountryID` int(11) NOT NULL,
  `CountryName` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `deals`
--

CREATE TABLE `deals` (
  `DealID` int(11) NOT NULL,
  `SchoolID` int(11) NOT NULL,
  `CounterID` int(11) NOT NULL,
  `DealTypeID` int(11) NOT NULL,
  `Quantity` int(11) NOT NULL,
  `Price` decimal(18,4) DEFAULT NULL,
  `ValueDate` datetime NOT NULL,
  `DealTotal` decimal(18,4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `deals`
--

INSERT INTO `deals` (`DealID`, `SchoolID`, `CounterID`, `DealTypeID`, `Quantity`, `Price`, `ValueDate`, `DealTotal`) VALUES
(2047, 1012, 3, 2, 10, '73.7400', '2023-01-18 00:00:00', '752.1480'),
(2048, 1012, 3, 1, 5, '73.7400', '2023-01-18 00:00:00', '361.3260'),
(2049, 1008, 2, 2, 100, '245.0000', '2023-01-18 00:00:00', '24990.0000'),
(2074, 1, 3, 2, 100, '73.7400', '2023-01-19 00:00:00', '7521.4800'),
(2076, 1010, 3, 2, 50, '73.7400', '2023-01-19 00:00:00', '3760.7400'),
(2077, 1010, 2, 2, 70, '245.0000', '2023-01-19 00:00:00', '17493.0000'),
(2078, 1010, 4, 2, 150, '345.8000', '2023-01-19 00:00:00', '52907.4000'),
(2079, 1006, 2, 2, 100, '245.0000', '2023-01-19 00:00:00', '24990.0000'),
(2081, 1010, 5, 2, 150, '128.0000', '2023-01-19 00:00:00', '19584.0000'),
(2082, 1006, 2, 1, 20, '245.0000', '2023-01-19 00:00:00', '4802.0000'),
(2083, 1006, 2, 1, 20, '245.0000', '2023-01-19 00:00:00', '4802.0000'),
(2084, 1007, 2, 2, 100, '245.0000', '2023-01-19 00:00:00', '24990.0000'),
(2085, 1007, 3, 2, 200, '73.7400', '2023-01-19 00:00:00', '15042.9600'),
(2086, 1006, 4, 2, 10, '345.8000', '2023-01-19 00:00:00', '3527.1600'),
(2087, 1007, 5, 2, 150, '128.0000', '2023-01-19 00:00:00', '19584.0000'),
(2088, 1006, 5, 2, 10, '128.0000', '2023-01-19 00:00:00', '1305.6000'),
(2089, 1007, 4, 2, 35, '345.8000', '2023-01-19 00:00:00', '12345.0600'),
(2090, 1007, 4, 2, 45, '345.8000', '2023-01-19 00:00:00', '15872.2200'),
(2091, 1006, 4, 1, 10, '345.8000', '2023-01-19 00:00:00', '3388.8400'),
(2092, 1007, 2, 1, 50, '245.0000', '2023-01-19 00:00:00', '12005.0000'),
(2093, 1005, 2, 2, 100, '245.0000', '2023-01-19 00:00:00', '24990.0000'),
(2094, 1006, 3, 2, 100, '73.7400', '2023-01-19 00:00:00', '7521.4800'),
(2095, 1005, 3, 2, 50, '73.7400', '2023-01-19 00:00:00', '3760.7400'),
(2096, 1006, 4, 2, 200, '345.8000', '2023-01-19 00:00:00', '70543.2000'),
(2097, 1005, 4, 2, 25, '345.8000', '2023-01-19 00:00:00', '8817.9000'),
(2098, 1005, 4, 2, 25, '345.8000', '2023-01-19 00:00:00', '8817.9000'),
(2099, 1007, 3, 1, 150, '73.7400', '2023-01-19 00:00:00', '10839.7800'),
(2100, 1005, 5, 2, 100, '128.0000', '2023-01-19 00:00:00', '13056.0000'),
(2101, 1006, 3, 1, 40, '73.7400', '2023-01-19 00:00:00', '2890.6080'),
(2102, 1005, 2, 1, 50, '245.0000', '2023-01-19 00:00:00', '12005.0000'),
(2103, 1005, 3, 1, 25, '73.7400', '2023-01-19 00:00:00', '1806.6300'),
(2104, 1007, 5, 1, 100, '128.0000', '2023-01-19 00:00:00', '12544.0000'),
(2105, 1006, 4, 1, 90, '345.8000', '2023-01-19 00:00:00', '30499.5600'),
(2106, 1005, 4, 1, 50, '345.8000', '2023-01-19 00:00:00', '16944.2000'),
(2107, 1005, 5, 1, 75, '128.0000', '2023-01-19 00:00:00', '9408.0000'),
(2108, 1007, 2, 1, 50, '245.0000', '2023-01-19 00:00:00', '12005.0000'),
(2109, 1005, 5, 1, 25, '128.0000', '2023-01-19 00:00:00', '3136.0000'),
(2110, 1007, 4, 1, 50, '345.8000', '2023-01-19 00:00:00', '16944.2000'),
(2111, 1011, 5, 2, 100, '128.0000', '2023-01-19 00:00:00', '13056.0000'),
(2112, 1011, 5, 1, 50, '128.0000', '2023-01-19 00:00:00', '6272.0000'),
(2113, 1011, 3, 2, 100, '73.7400', '2023-01-19 00:00:00', '7521.4800'),
(2114, 1011, 2, 2, 20, '245.0000', '2023-01-19 00:00:00', '4998.0000'),
(2115, 1011, 3, 2, 20, '73.7400', '2023-01-19 00:00:00', '1504.2960'),
(2116, 1011, 4, 2, 20, '345.8000', '2023-01-19 00:00:00', '7054.3200'),
(2117, 1011, 5, 2, 20, '128.0000', '2023-01-19 00:00:00', '2611.2000'),
(2118, 1011, 2, 2, 5, '245.0000', '2023-01-19 00:00:00', '1249.5000'),
(2119, 1011, 3, 2, 5, '73.7400', '2023-01-19 00:00:00', '376.0740'),
(2120, 1011, 4, 2, 5, '345.8000', '2023-01-19 00:00:00', '1763.5800'),
(2121, 1011, 5, 2, 5, '128.0000', '2023-01-19 00:00:00', '652.8000'),
(2122, 1011, 2, 2, 25, '245.0000', '2023-01-19 00:00:00', '6247.5000'),
(2123, 1011, 4, 2, 25, '345.8000', '2023-01-19 00:00:00', '8817.9000'),
(2124, 1011, 2, 1, 15, '245.0000', '2023-01-19 00:00:00', '3601.5000'),
(2125, 1011, 4, 1, 15, '345.8000', '2023-01-19 00:00:00', '5083.2600'),
(2126, 1011, 3, 1, 15, '73.7400', '2023-01-19 00:00:00', '1083.9780'),
(2127, 1011, 5, 1, 15, '128.0000', '2023-01-19 00:00:00', '1881.6000'),
(2128, 1011, 2, 1, 4, '245.0000', '2023-01-19 00:00:00', '960.4000'),
(2129, 1011, 4, 1, 4, '345.8000', '2023-01-19 00:00:00', '1355.5360'),
(2130, 1011, 3, 1, 3, '73.7400', '2023-01-19 00:00:00', '216.7956'),
(2131, 1011, 5, 1, 20, '128.0000', '2023-01-19 00:00:00', '2508.8000'),
(2132, 1011, 2, 1, 5, '245.0000', '2023-01-19 00:00:00', '1200.5000'),
(2133, 1011, 4, 1, 5, '345.8000', '2023-01-19 00:00:00', '1694.4200'),
(2134, 1012, 2, 2, 10, '245.0000', '2023-01-19 00:00:00', '2499.0000'),
(2135, 1012, 2, 2, 100, '245.0000', '2023-01-20 00:00:00', '24990.0000'),
(2136, 1012, 3, 2, 35, '73.7400', '2023-01-20 00:00:00', '2632.5180'),
(2160, 2, 2, 2, 10, '245.0000', '2023-06-20 00:00:00', '2499.0000'),
(2161, 2, 5, 2, 45, '128.0000', '2023-07-14 00:00:00', '5875.2000'),
(2162, 2, 4, 2, 35, '345.8000', '2023-07-14 00:00:00', '12345.0600'),
(2163, 2, 2, 2, 100, '245.0000', '2023-07-18 00:00:00', '24990.0000'),
(2164, 2, 0, 0, 0, '0.0000', '2023-07-18 00:00:00', '0.0000'),
(2165, 2, 0, 0, 0, '0.0000', '2023-07-18 00:00:00', '0.0000');

-- --------------------------------------------------------

--
-- Table structure for table `dealtypes`
--

CREATE TABLE `dealtypes` (
  `DealTypeID` int(11) NOT NULL,
  `DealType` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `dealtypes`
--

INSERT INTO `dealtypes` (`DealTypeID`, `DealType`) VALUES
(1, 'Sell'),
(2, 'Purchase');

-- --------------------------------------------------------

--
-- Table structure for table `emailcredentials`
--

CREATE TABLE `emailcredentials` (
  `SMTPCLIENT` varchar(100) DEFAULT NULL,
  `PORT` int(11) DEFAULT NULL,
  `USERNAME` varchar(100) DEFAULT NULL,
  `PASSWORD` varchar(100) DEFAULT NULL,
  `FromAddress` varchar(100) NOT NULL,
  `DisplayName` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `emailcredentials`
--

INSERT INTO `emailcredentials` (`SMTPCLIENT`, `PORT`, `USERNAME`, `PASSWORD`, `FromAddress`, `DisplayName`) VALUES
('mail.geesoftsystems.co.zw', 587, 'lissah@geesoftsystems.co.zw', '@MagwenL345', 'lissah@geesoftsystems.co.zw', 'no-eply@virtualTradingPlatform.co.zw');

-- --------------------------------------------------------

--
-- Table structure for table `gendertypes`
--

CREATE TABLE `gendertypes` (
  `GenderID` int(11) NOT NULL,
  `GenderName` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `graph`
--

CREATE TABLE `graph` (
  `graph_id` int(11) NOT NULL,
  `x_axis` varchar(200) NOT NULL,
  `y_axis` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `graph`
--

INSERT INTO `graph` (`graph_id`, `x_axis`, `y_axis`) VALUES
(1, 'Allan WIlson', 99),
(1, 'Tatenda High School', 99),
(1, 'Eliah High School', 99),
(1, 'Takudzwa High School', 98),
(1, 'Israel High School ', 98),
(1, 'Vovo High School', 97),
(1, 'Abigail High School ', 96),
(1, 'Lissah High School', 96),
(1, 'Girls High School', 74);

-- --------------------------------------------------------

--
-- Table structure for table `graph2`
--

CREATE TABLE `graph2` (
  `id` int(11) NOT NULL,
  `x_axis` varchar(45) NOT NULL,
  `y_axis` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `graph2`
--

INSERT INTO `graph2` (`id`, `x_axis`, `y_axis`) VALUES
(1, 'Allan WIlson', 99),
(1, 'Tatenda High School', 99),
(1, 'Eliah High School', 99),
(1, 'Takudzwa High School', 98),
(1, 'Israel High School ', 98),
(1, 'Vovo High School', 97),
(1, 'Abigail High School ', 96),
(1, 'Lissah High School', 96),
(1, 'Girls High School', 74);

-- --------------------------------------------------------

--
-- Table structure for table `identificationtype`
--

CREATE TABLE `identificationtype` (
  `IdentityID` int(11) NOT NULL,
  `TypeOfID` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `portfolio`
--

CREATE TABLE `portfolio` (
  `PortfolioID` int(11) NOT NULL,
  `SchoolID` int(11) NOT NULL,
  `CounterID` int(11) NOT NULL,
  `ValueDate` datetime DEFAULT NULL,
  `NumberOfShares` int(11) NOT NULL,
  `BookValue` decimal(10,2) NOT NULL,
  `CurrentPrice` decimal(10,2) NOT NULL,
  `MarketValue` decimal(10,2) DEFAULT NULL,
  `CashBalance` decimal(18,4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `provinces`
--

CREATE TABLE `provinces` (
  `ProvinceID` int(11) NOT NULL,
  `ProvinceName` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `RoleID` int(11) NOT NULL,
  `Role` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`RoleID`, `Role`) VALUES
(1, 'Admin'),
(2, 'Head'),
(3, 'Representative');

-- --------------------------------------------------------

--
-- Table structure for table `salutations`
--

CREATE TABLE `salutations` (
  `SalutationID` int(11) NOT NULL,
  `Salutation` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `schools`
--

CREATE TABLE `schools` (
  `SchoolID` int(11) NOT NULL,
  `SchoolName` varchar(100) NOT NULL,
  `PhysicalAddress` varchar(100) DEFAULT NULL,
  `City` varchar(50) DEFAULT NULL,
  `Province` varchar(50) DEFAULT NULL,
  `Country` varchar(50) DEFAULT NULL,
  `SchoolEmail` varchar(50) DEFAULT NULL,
  `ContactNumber` varchar(25) DEFAULT NULL,
  `SchoolHeadmaster` varchar(50) DEFAULT NULL,
  `Representative` varchar(50) DEFAULT NULL,
  `CashBalance` decimal(18,4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `schools`
--

INSERT INTO `schools` (`SchoolID`, `SchoolName`, `PhysicalAddress`, `City`, `Province`, `Country`, `SchoolEmail`, `ContactNumber`, `SchoolHeadmaster`, `Representative`, `CashBalance`) VALUES
(1, 'Allan WIlson', '1 Harare', 'Harare', 'Harare', 'Zimbabwe', 'hs@ht.com', '7.12346e+008', 'Mr Mudimu', 'Mrs Nyakudya', '100000.0000'),
(2, 'Girls High School', '111 Belllighum Road Harare', 'Harare', 'Harare', 'Zimbabwe', 'girlshigh@gmail.com', '0739266501', 'Mr Ndlovu', 'Mr Jena', '46625.8000'),
(3, 'Churchill Boys High', '53CJ+JXG, Nigel Philip Ave, Harare', 'Harare', 'Harare', 'Zimbabwe', 'churchillBoysHigh@gmail.com', '04747117', 'E.J. \'Jeeves\' Hougaard', 'Muzeya', '150000.0000'),
(1003, 'Kuwadzana high 1 school', '201 kuwadzana 3 \nDzivarasekwa \nHarare', 'Harare', 'Harare', 'Zimbabwe', 'khs1@gamil.com', '0789266432', 'Mr Mutetwa', 'Mr mberengwa', '100000.0000'),
(1005, 'Vovo High School', 'Kuwadzana Extension ', 'Harare', 'Harare', 'Zimbabwe', 'yvonne@geesoftsystems.co.zw', '0719253505', 'Yvonne', 'Yv', '100000.0000'),
(1006, 'Lissah High School', 'Highfield harare', 'Harare', 'Harare', 'Zimbabwe', 'lissah@geesoftsystems.co.zw', '0786668295', 'Lissah', 'Lilly', '100000.0000'),
(1007, 'Abigail High School ', 'Kambuzuma Harare', 'Harare', 'Harare', 'Zimbabwe', 'abigail@geesoftsystems.co.zw', '0786668295', 'Abigail', 'Abi', '100000.0000'),
(1008, 'Tatenda High School', '12334 Borrowdale Harare', 'Harare', 'Harare', 'Zimbabwe', 'tatenda@geesoftsystems.co.zw', '0789266432', 'Tatenda', 'Tats', '100000.0000'),
(1009, 'Pamela High School', 'Harare', 'Harare', 'Harare', 'Zimbabwe', 'pamela@geesoftsystems.co.zw', '0789266432', 'Pamela', 'Pem', '100000.0000'),
(1010, 'Israel High School ', 'Harare', 'Harare', 'Harare', 'Zimbabwe', 'israel@geesoftsystems.co.zw', '0739266501', 'Israel', 'Issy', '100000.0000'),
(1011, 'Takudzwa High School', 'Harare', 'Harare', 'Harare', 'Zimbabwe', 'takudzwa@geesoftsystems.co.zw', '0786668295', 'Takudzwa', 'taku', '100000.0000'),
(1012, 'Eliah High School', 'Harare', 'Harare', 'Harare', 'Zimbabwe', 'eliah@geesoftsystems.co.zw', '0739266501', 'Mr Muda', 'Edza', '100000.0000'),
(1013, 'Nataly Girls High', ' 7711 kuwadzana 3 harare', 'Harare', ' Harare', 'Zimbabwe', 'Natie@gmail.com', '0773326939', 'Nataly Kavhumbura', 'Mufaro Luciano', '100000.0000');

-- --------------------------------------------------------

--
-- Table structure for table `schoolstartupcash`
--

CREATE TABLE `schoolstartupcash` (
  `ID` int(11) NOT NULL,
  `initialCash` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `schoolstartupcash`
--

INSERT INTO `schoolstartupcash` (`ID`, `initialCash`) VALUES
(3, 100000);

-- --------------------------------------------------------

--
-- Table structure for table `systemusers`
--

CREATE TABLE `systemusers` (
  `UserID` int(11) NOT NULL,
  `name` varchar(50) DEFAULT NULL,
  `surname` varchar(50) DEFAULT NULL,
  `SchoolID` varchar(50) DEFAULT NULL,
  `Email` varchar(50) DEFAULT NULL,
  `password` varchar(50) DEFAULT NULL,
  `username` varchar(50) DEFAULT NULL,
  `role_id` varchar(50) DEFAULT NULL,
  `active` varchar(50) DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `systemusers`
--

INSERT INTO `systemusers` (`UserID`, `name`, `surname`, `SchoolID`, `Email`, `password`, `username`, `role_id`, `active`) VALUES
(1, 'John', 'Mulla', '2', 'john@gmail.com', 'password123', 'mulla07', '2', '1'),
(2, 'Jeeves', 'Hougaard', '3', 'churchillboyshigh@gmail.com', 'jeeves123', 'EJ.Jeeves', '2', '1'),
(3, 'John', 'Smith', '1', 'jay.smith@allanwilson.com', 'pass1234', 'jay.Smith', '2', '1'),
(6, 'Gee', 'soft', NULL, 'geesoft@gmail.com', 'admin', 'geesoft', '1', '1'),
(18, 'Abigail', 'Mwoyoweshumba', '1007', 'abigail@gmail.com', 'abi', 'Abigail', '2', '0'),
(19, 'Yvonne', 'vovo', '1005', 'yvonne@geesoftsystems.co.zw', 'vovo', 'yvonne', '2', '1'),
(20, 'tatenda', 'tats', '1008', 'tatenda@geesoftsystems.co.zw', 'pass', 'tatenda', '2', '1'),
(21, 'Pamela', 'Pem', '1009', 'pamela@geesoftsystems.co.zw', 'pass', 'pamela', '2', '1'),
(22, 'Israel', 'chitsa', '1010', 'israel@geesoftsystems.co.zw', 'pass123', 'Israel', '2', '1'),
(23, 'Lissah', 'Gee', '1006', 'lissah@geesoftsystems.co.zw', 'pass', 'lissah', '2', '1'),
(24, 'Takudzwa', 'Nyakutambwa', '1011', 'takudzwa@geesoftsystems.co.zw', 'taku', 'takudzwa', '2', '1'),
(25, 'Eliah', 'Muda', '1012', 'eliah@geesoftsystems.co.zw', 'fire', 'King', '2', '1'),
(26, 'Kudzanai', ' Mudakureva', '0', 'KD@gmail.com', 'admin', 'KD@123', '1', '1'),
(27, 'Nataly', ' Kavhumbura', '1003', 'Natie@gmail.com', 'pass123', 'Natty', '2', '1'),
(28, 'Eliah', ' Muda', '0', 'eliah@geesoftsystems.com', 'muda', 'edza', '1', '0');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_dealcharges`
--

CREATE TABLE `tbl_dealcharges` (
  `DealChargesID` int(11) NOT NULL,
  `DealType` varchar(50) DEFAULT NULL,
  `Charge` decimal(18,4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `tbl_dealcharges`
--

INSERT INTO `tbl_dealcharges` (`DealChargesID`, `DealType`, `Charge`) VALUES
(7, 'Buy', '0.0200'),
(9, 'Sell', '0.0200');

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `TransactionID` int(11) NOT NULL,
  `SchoolID` int(11) NOT NULL,
  `ValueDate` datetime NOT NULL,
  `Price` decimal(10,2) NOT NULL,
  `DealValue` decimal(10,2) NOT NULL,
  `CreationDate` datetime NOT NULL,
  `DealType` varchar(50) DEFAULT NULL,
  `Counter` varchar(50) DEFAULT NULL,
  `DealTypeID` int(11) DEFAULT NULL,
  `CounterID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `UserID` int(11) NOT NULL,
  `Salutation` varchar(50) DEFAULT NULL,
  `FirstName` varchar(100) NOT NULL,
  `MiddleName` varchar(100) NOT NULL,
  `LastName` varchar(100) NOT NULL,
  `TypeOfID` varchar(50) DEFAULT NULL,
  `IDNumber` varchar(100) NOT NULL,
  `Gender` varchar(50) DEFAULT NULL,
  `DOB` datetime NOT NULL,
  `Email` varchar(100) NOT NULL,
  `HomeAddress` varchar(200) NOT NULL,
  `MobileNumber` varchar(25) NOT NULL,
  `Nationality` varchar(100) NOT NULL,
  `SchoolName` varchar(100) DEFAULT NULL,
  `City` varchar(50) DEFAULT NULL,
  `Province` varchar(50) DEFAULT NULL,
  `Country` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `auditedobjectweakreference`
--
ALTER TABLE `auditedobjectweakreference`
  ADD PRIMARY KEY (`Oid`);

--
-- Indexes for table `audit_tray`
--
ALTER TABLE `audit_tray`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `cities`
--
ALTER TABLE `cities`
  ADD PRIMARY KEY (`CityID`);

--
-- Indexes for table `counterprices`
--
ALTER TABLE `counterprices`
  ADD PRIMARY KEY (`CounterPriceID`);

--
-- Indexes for table `counterpricestest`
--
ALTER TABLE `counterpricestest`
  ADD PRIMARY KEY (`CounterPriceID`);

--
-- Indexes for table `counters`
--
ALTER TABLE `counters`
  ADD PRIMARY KEY (`CounterID`);

--
-- Indexes for table `countries`
--
ALTER TABLE `countries`
  ADD PRIMARY KEY (`CountryID`);

--
-- Indexes for table `deals`
--
ALTER TABLE `deals`
  ADD PRIMARY KEY (`DealID`);

--
-- Indexes for table `dealtypes`
--
ALTER TABLE `dealtypes`
  ADD PRIMARY KEY (`DealTypeID`);

--
-- Indexes for table `gendertypes`
--
ALTER TABLE `gendertypes`
  ADD PRIMARY KEY (`GenderID`);

--
-- Indexes for table `identificationtype`
--
ALTER TABLE `identificationtype`
  ADD PRIMARY KEY (`IdentityID`);

--
-- Indexes for table `portfolio`
--
ALTER TABLE `portfolio`
  ADD PRIMARY KEY (`PortfolioID`);

--
-- Indexes for table `provinces`
--
ALTER TABLE `provinces`
  ADD PRIMARY KEY (`ProvinceID`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`RoleID`);

--
-- Indexes for table `salutations`
--
ALTER TABLE `salutations`
  ADD PRIMARY KEY (`SalutationID`);

--
-- Indexes for table `schools`
--
ALTER TABLE `schools`
  ADD PRIMARY KEY (`SchoolID`);

--
-- Indexes for table `schoolstartupcash`
--
ALTER TABLE `schoolstartupcash`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `systemusers`
--
ALTER TABLE `systemusers`
  ADD PRIMARY KEY (`UserID`);

--
-- Indexes for table `tbl_dealcharges`
--
ALTER TABLE `tbl_dealcharges`
  ADD PRIMARY KEY (`DealChargesID`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`TransactionID`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`UserID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `audit_tray`
--
ALTER TABLE `audit_tray`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=103;

--
-- AUTO_INCREMENT for table `cities`
--
ALTER TABLE `cities`
  MODIFY `CityID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `counterprices`
--
ALTER TABLE `counterprices`
  MODIFY `CounterPriceID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `counterpricestest`
--
ALTER TABLE `counterpricestest`
  MODIFY `CounterPriceID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `counters`
--
ALTER TABLE `counters`
  MODIFY `CounterID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `countries`
--
ALTER TABLE `countries`
  MODIFY `CountryID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `deals`
--
ALTER TABLE `deals`
  MODIFY `DealID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2166;

--
-- AUTO_INCREMENT for table `dealtypes`
--
ALTER TABLE `dealtypes`
  MODIFY `DealTypeID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `gendertypes`
--
ALTER TABLE `gendertypes`
  MODIFY `GenderID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `identificationtype`
--
ALTER TABLE `identificationtype`
  MODIFY `IdentityID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `portfolio`
--
ALTER TABLE `portfolio`
  MODIFY `PortfolioID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2015;

--
-- AUTO_INCREMENT for table `provinces`
--
ALTER TABLE `provinces`
  MODIFY `ProvinceID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `roles`
--
ALTER TABLE `roles`
  MODIFY `RoleID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `salutations`
--
ALTER TABLE `salutations`
  MODIFY `SalutationID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `schools`
--
ALTER TABLE `schools`
  MODIFY `SchoolID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1014;

--
-- AUTO_INCREMENT for table `schoolstartupcash`
--
ALTER TABLE `schoolstartupcash`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `systemusers`
--
ALTER TABLE `systemusers`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT for table `tbl_dealcharges`
--
ALTER TABLE `tbl_dealcharges`
  MODIFY `DealChargesID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `TransactionID` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `UserID` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
