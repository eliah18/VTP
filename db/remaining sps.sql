

CREATE  PROCEDURE `sp_getMobileTransView`
(IN `startDate` DATE,
 IN `endDate` DATE,
 IN `mySchlID` INT)
 AS
BEGIN
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

CREATE  PROCEDURE `sp_GetPortfolioValue` (IN `myschlID` INT) 
as 
BEGIN

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

CREATE PROCEDURE `sp_GetPortfolioView` (IN `mySchlID` INT, IN `VarDate` DATE)   BEGIN
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

CREATE PROCEDURE `sp_GetQuantity` (IN `myschlID` INT, IN `myCounter` INT)   BEGIN
 set @PQuantity =0;
 set @SQuantity =0;
 set @Quantity =0;


set @PQuantity=(select case when isnull(sum(quantity) )=0 then sum(quantity) else 0 end from deals where SchoolID=myschlID and DealTypeID=2 and CounterID=myCounter);

set @SQuantity=(select case when isnull(sum(quantity) )=0 then sum(quantity) else 0 end  from deals where SchoolID=myschlID and DealTypeID=1 and CounterID=myCounter);

set @Quantity=(select @PQuantity-@SQuantity);

select  @Quantity as Quantity;
END$$

CREATE  PROCEDURE `sp_GetRoles` ()   BEGIN
 select 
				RoleID,
				Role 
				
	  from Roles where RoleID in (2,3);
END$$

CREATE  PROCEDURE `sp_GetSchoolName` ()   BEGIN
 select 
				SchoolID,
				SchoolName 
				
	  from Schools;
END$$

CREATE PROCEDURE `sp_GetSchools` ()   BEGIN
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

CREATE  PROCEDURE `sp_GetSchoolUsers` ()   BEGIN
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

CREATE PROCEDURE `sp_GetSystemUsers` ()   BEGIN
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

CREATE PROCEDURE `sp_Gettransactionview` (IN `startDate` DATE, IN `endDate` DATE, IN `mySchlID` INT)   BEGIN
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

CREATE  PROCEDURE `sp_MobilePortView` (IN `mySchlID` INT, IN `VarDate` DATE)   BEGIN
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

CREATE  PROCEDURE `sp_PricesList` ()   BEGIN
select 
					 ShortName as Counter,
					 Price as CounterPrice 
			 from counterprices ;
END$$

CREATE  PROCEDURE `sp_SchoolsPerfomanceView` (IN `ValueDate` DATE)   BEGIN
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

CREATE  PROCEDURE `sp_UpdateBalance` (IN `myschlID` INT, IN `DealTotal` DECIMAL(10,6))   BEGIN
set @availablecash =0;
set @totalcash = 0;

set @totalcash=(select CashBalance from Schools where SchoolID=myschlID);
set @availablecash = @totalcash - DealTotal;

  update Schools set CashBalance = @availablecash  where SchoolID=myschlID;
END$$

CREATE  PROCEDURE `sp_ValidateDealCash` (IN `myschlID` INT)   BEGIN
select CashBalance as CashValue from Schools where SchoolID=myschlID;
END$$

CREATE  PROCEDURE `test` ()   BEGIN
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
